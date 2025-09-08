#!/bin/bash

# WP-CLI wrapper script for WordPress Fast Docker
# Provides direct access to WP-CLI commands in the WordPress container

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if WordPress container is running
if ! docker-compose -f "$PROJECT_ROOT/docker-compose.yml" ps wordpress | grep -q "Up"; then
    echo -e "${RED}Error: WordPress container is not running${NC}"
    echo "Please start the containers first: docker-compose up -d"
    exit 1
fi

# Function to show WP-CLI status and info
show_wp_info() {
    echo -e "${YELLOW}WordPress CLI Information${NC}"
    echo "=========================="
    
    echo -e "${BLUE}WP-CLI Version:${NC}"
    docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress wp --version 2>/dev/null || echo "  WP-CLI not available"
    
    echo
    echo -e "${BLUE}WordPress Installation:${NC}"
    if docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress wp core is-installed 2>/dev/null; then
        echo "  ✓ WordPress is installed"
        
        # Get WordPress version and URL
        WP_VERSION=$(docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress wp core version 2>/dev/null | tr -d '\r')
        WP_URL=$(docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress wp option get siteurl 2>/dev/null | tr -d '\r')
        
        echo "  Version: $WP_VERSION"
        echo "  URL: $WP_URL"
        
        # Check if user can connect to database
        if docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress wp db check 2>/dev/null | grep -q "Success"; then
            echo "  ✓ Database connection successful"
        else
            echo "  ✗ Database connection failed"
        fi
    else
        echo "  ✗ WordPress is not installed"
        echo "  Run: $0 core install --url=http://localhost --title='My Site' --admin_user=admin --admin_email=admin@example.com"
    fi
    
    echo
    echo -e "${BLUE}Available Commands:${NC}"
    echo "  Core commands: install, download, update, version"
    echo "  Plugin commands: list, install, activate, deactivate, delete"
    echo "  Theme commands: list, install, activate, delete"
    echo "  Database commands: create, drop, reset, export, import"
    echo "  User commands: list, create, delete, update"
    echo "  Post commands: list, create, delete, update"
    echo "  Option commands: get, set, delete, list"
    echo "  Search-replace: search-replace old_url new_url"
    echo
    echo "  For full command list: $0 help"
}

# If no arguments provided, show info
if [ $# -eq 0 ]; then
    show_wp_info
    exit 0
fi

# Special handling for common commands
case "$1" in
    "info"|"status")
        show_wp_info
        exit 0
        ;;
    "install-wordpress")
        echo -e "${YELLOW}Quick WordPress Installation${NC}"
        echo "=============================="
        
        # Check if already installed
        if docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress wp core is-installed 2>/dev/null; then
            echo -e "${GREEN}WordPress is already installed${NC}"
            exit 0
        fi
        
        # Default installation parameters
        DEFAULT_URL="http://localhost"
        DEFAULT_TITLE="WordPress Fast Docker"
        DEFAULT_ADMIN_USER="admin"
        DEFAULT_ADMIN_EMAIL="admin@example.com"
        
        # Get installation parameters
        read -p "Site URL [$DEFAULT_URL]: " SITE_URL
        SITE_URL=${SITE_URL:-$DEFAULT_URL}
        
        read -p "Site Title [$DEFAULT_TITLE]: " SITE_TITLE
        SITE_TITLE=${SITE_TITLE:-$DEFAULT_TITLE}
        
        read -p "Admin Username [$DEFAULT_ADMIN_USER]: " ADMIN_USER
        ADMIN_USER=${ADMIN_USER:-$DEFAULT_ADMIN_USER}
        
        read -p "Admin Email [$DEFAULT_ADMIN_EMAIL]: " ADMIN_EMAIL
        ADMIN_EMAIL=${ADMIN_EMAIL:-$DEFAULT_ADMIN_EMAIL}
        
        # Generate random password
        ADMIN_PASSWORD=$(openssl rand -base64 12)
        
        echo
        echo -e "${YELLOW}Installing WordPress...${NC}"
        
        # Install WordPress
        if docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress wp core install \
            --url="$SITE_URL" \
            --title="$SITE_TITLE" \
            --admin_user="$ADMIN_USER" \
            --admin_password="$ADMIN_PASSWORD" \
            --admin_email="$ADMIN_EMAIL" \
            --skip-email; then
            
            echo -e "${GREEN}✓ WordPress installed successfully!${NC}"
            echo
            echo -e "${BLUE}Login Details:${NC}"
            echo "  URL: $SITE_URL/wp-admin"
            echo "  Username: $ADMIN_USER"
            echo "  Password: $ADMIN_PASSWORD"
            echo "  Email: $ADMIN_EMAIL"
            echo
            echo -e "${YELLOW}Please save these credentials!${NC}"
        else
            echo -e "${RED}✗ WordPress installation failed${NC}"
            exit 1
        fi
        exit 0
        ;;
    "shell"|"bash")
        echo -e "${YELLOW}Opening WordPress container shell...${NC}"
        docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec wordpress bash
        exit 0
        ;;
    "logs")
        echo -e "${YELLOW}WordPress container logs:${NC}"
        docker-compose -f "$PROJECT_ROOT/docker-compose.yml" logs -f wordpress
        exit 0
        ;;
esac

# For all other commands, pass through to WP-CLI
echo -e "${BLUE}Executing WP-CLI command:${NC} wp $*"
echo

# Execute the WP-CLI command in the container
# Use -T flag to avoid TTY allocation issues when piping output
if [ -t 0 ] && [ -t 1 ]; then
    # Interactive terminal
    docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec wordpress wp "$@"
else
    # Non-interactive (piped input/output)
    docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress wp "$@"
fi

# Capture the exit code from the WP-CLI command
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo
    echo -e "${RED}WP-CLI command failed with exit code: $EXIT_CODE${NC}"
    echo -e "${YELLOW}Tip: Run '$0 help' to see available commands${NC}"
fi

exit $EXIT_CODE
