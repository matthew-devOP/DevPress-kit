#!/bin/bash

# Database backup script for WordPress Fast Docker
# Automatically backs up the database with timestamp

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load environment variables
if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
fi

# Configuration
BACKUP_DIR="${PROJECT_ROOT}/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DB_NAME="${MYSQL_DATABASE:-wordpress}"
DB_USER="${MYSQL_USER:-wordpress}"
DB_PASSWORD="${MYSQL_PASSWORD:-wordpress}"
DB_HOST="${MYSQL_HOST:-mysql}"
BACKUP_FILE="wordpress_db_${TIMESTAMP}.sql"
COMPRESSED_FILE="${BACKUP_FILE}.gz"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting database backup...${NC}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if MySQL container is running
if ! docker-compose -f "$PROJECT_ROOT/docker-compose.yml" ps mysql | grep -q "Up"; then
    echo -e "${RED}Error: MySQL container is not running${NC}"
    echo "Please start the containers first: docker-compose up -d"
    exit 1
fi

# Create database backup
echo -e "${YELLOW}Backing up database '$DB_NAME'...${NC}"

if docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T mysql mysqldump \
    -u"$DB_USER" \
    -p"$DB_PASSWORD" \
    -h"$DB_HOST" \
    --single-transaction \
    --routines \
    --triggers \
    --add-drop-table \
    "$DB_NAME" > "$BACKUP_DIR/$BACKUP_FILE"; then
    
    # Compress the backup
    echo -e "${YELLOW}Compressing backup...${NC}"
    gzip "$BACKUP_DIR/$BACKUP_FILE"
    
    # Get file size
    FILE_SIZE=$(ls -lh "$BACKUP_DIR/$COMPRESSED_FILE" | awk '{print $5}')
    
    echo -e "${GREEN}✓ Database backup completed successfully!${NC}"
    echo -e "  File: ${COMPRESSED_FILE}"
    echo -e "  Size: ${FILE_SIZE}"
    echo -e "  Location: ${BACKUP_DIR}/${COMPRESSED_FILE}"
else
    echo -e "${RED}✗ Database backup failed!${NC}"
    # Clean up incomplete backup file
    [ -f "$BACKUP_DIR/$BACKUP_FILE" ] && rm "$BACKUP_DIR/$BACKUP_FILE"
    exit 1
fi

# Optional: Keep only the last 10 backups
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/wordpress_db_*.sql.gz 2>/dev/null | wc -l || echo 0)
if [ "$BACKUP_COUNT" -gt 10 ]; then
    echo -e "${YELLOW}Cleaning up old backups (keeping last 10)...${NC}"
    ls -t "$BACKUP_DIR"/wordpress_db_*.sql.gz | tail -n +11 | xargs rm -f
    echo -e "${GREEN}✓ Old backups cleaned up${NC}"
fi

echo -e "${GREEN}Database backup process completed!${NC}"
