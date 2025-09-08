#!/bin/bash

# Database restoration script for WordPress Fast Docker
# Restores database from backup files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load environment variables
if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
fi

# Configuration
BACKUP_DIR="${PROJECT_ROOT}/backups"
DB_NAME="${MYSQL_DATABASE:-wordpress}"
DB_USER="${MYSQL_USER:-wordpress}"
DB_PASSWORD="${MYSQL_PASSWORD:-wordpress}"
DB_HOST="${MYSQL_HOST:-mysql}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}WordPress Database Restoration${NC}"
echo "=================================="

# Check if MySQL container is running
if ! docker-compose -f "$PROJECT_ROOT/docker-compose.yml" ps mysql | grep -q "Up"; then
    echo -e "${RED}Error: MySQL container is not running${NC}"
    echo "Please start the containers first: docker-compose up -d"
    exit 1
fi

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}Error: Backup directory not found: $BACKUP_DIR${NC}"
    echo "Please run a backup first using: ./scripts/backup-db.sh"
    exit 1
fi

# Find available backup files
BACKUP_FILES=($(ls -t "$BACKUP_DIR"/wordpress_db_*.sql.gz 2>/dev/null || true))

if [ ${#BACKUP_FILES[@]} -eq 0 ]; then
    echo -e "${RED}Error: No backup files found in $BACKUP_DIR${NC}"
    echo "Please run a backup first using: ./scripts/backup-db.sh"
    exit 1
fi

# If backup file specified as argument
if [ $# -eq 1 ]; then
    BACKUP_FILE="$1"
    if [ ! -f "$BACKUP_FILE" ]; then
        echo -e "${RED}Error: Backup file not found: $BACKUP_FILE${NC}"
        exit 1
    fi
else
    # Show available backups and let user choose
    echo -e "${BLUE}Available backup files:${NC}"
    echo
    for i in "${!BACKUP_FILES[@]}"; do
        FILE="${BACKUP_FILES[$i]}"
        BASENAME=$(basename "$FILE")
        SIZE=$(ls -lh "$FILE" | awk '{print $5}')
        DATE=$(echo "$BASENAME" | grep -o '[0-9]\{8\}_[0-9]\{6\}' | sed 's/_/ /' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\) \([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
        printf "%2d) %-30s %8s  %s\n" $((i+1)) "$BASENAME" "$SIZE" "$DATE"
    done
    echo
    
    # Get user selection
    while true; do
        read -p "Select backup file (1-${#BACKUP_FILES[@]}): " selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#BACKUP_FILES[@]} ]; then
            BACKUP_FILE="${BACKUP_FILES[$((selection-1))]}"
            break
        else
            echo -e "${RED}Invalid selection. Please enter a number between 1 and ${#BACKUP_FILES[@]}${NC}"
        fi
    done
fi

echo
echo -e "${YELLOW}Selected backup file: $(basename "$BACKUP_FILE")${NC}"

# Final confirmation
echo -e "${RED}WARNING: This will completely replace the current database!${NC}"
echo -e "${RED}All current data in '$DB_NAME' will be lost!${NC}"
echo
read -p "Are you sure you want to continue? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo -e "${YELLOW}Database restoration cancelled.${NC}"
    exit 0
fi

echo
echo -e "${YELLOW}Starting database restoration...${NC}"

# Create a safety backup of current database
SAFETY_BACKUP_FILE="/tmp/wordpress_pre_restore_$(date +%Y%m%d_%H%M%S).sql"
echo -e "${YELLOW}Creating safety backup of current database...${NC}"

if docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T mysql mysqldump \
    -u"$DB_USER" \
    -p"$DB_PASSWORD" \
    -h"$DB_HOST" \
    --single-transaction \
    "$DB_NAME" > "$SAFETY_BACKUP_FILE" 2>/dev/null; then
    echo -e "${GREEN}✓ Safety backup created: $SAFETY_BACKUP_FILE${NC}"
else
    echo -e "${YELLOW}Warning: Could not create safety backup${NC}"
fi

# Restore database
echo -e "${YELLOW}Restoring database from backup...${NC}"

# Handle compressed files
if [[ "$BACKUP_FILE" == *.gz ]]; then
    RESTORE_CMD="zcat '$BACKUP_FILE'"
else
    RESTORE_CMD="cat '$BACKUP_FILE'"
fi

if eval "$RESTORE_CMD" | docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T mysql mysql \
    -u"$DB_USER" \
    -p"$DB_PASSWORD" \
    -h"$DB_HOST" \
    "$DB_NAME"; then
    
    echo -e "${GREEN}✓ Database restoration completed successfully!${NC}"
    echo
    echo -e "${GREEN}Database '$DB_NAME' has been restored from:${NC}"
    echo -e "  $(basename "$BACKUP_FILE")"
    
    if [ -f "$SAFETY_BACKUP_FILE" ]; then
        echo
        echo -e "${BLUE}Safety backup of previous database saved to:${NC}"
        echo -e "  $SAFETY_BACKUP_FILE"
        echo -e "${BLUE}You can remove it manually if no longer needed.${NC}"
    fi
    
else
    echo -e "${RED}✗ Database restoration failed!${NC}"
    
    if [ -f "$SAFETY_BACKUP_FILE" ]; then
        echo -e "${YELLOW}Attempting to restore from safety backup...${NC}"
        if cat "$SAFETY_BACKUP_FILE" | docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T mysql mysql \
            -u"$DB_USER" \
            -p"$DB_PASSWORD" \
            -h"$DB_HOST" \
            "$DB_NAME"; then
            echo -e "${GREEN}✓ Database restored from safety backup${NC}"
        else
            echo -e "${RED}✗ Failed to restore from safety backup!${NC}"
        fi
    fi
    
    exit 1
fi

echo -e "${GREEN}Database restoration process completed!${NC}"
