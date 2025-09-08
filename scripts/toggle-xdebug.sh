#!/bin/bash

# Toggle Xdebug script for WordPress Fast Docker
# Enables or disables Xdebug in the PHP container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Xdebug Toggle Utility${NC}"
echo "===================="

# Check if WordPress/PHP container is running
if ! docker-compose -f "$PROJECT_ROOT/docker-compose.yml" ps wordpress | grep -q "Up"; then
    echo -e "${RED}Error: WordPress container is not running${NC}"
    echo "Please start the containers first: docker-compose up -d"
    exit 1
fi

# Function to check Xdebug status
check_xdebug_status() {
    if docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress php -m | grep -q "xdebug"; then
        return 0  # Xdebug is enabled
    else
        return 1  # Xdebug is disabled
    fi
}

# Function to get current Xdebug status
get_xdebug_status() {
    if check_xdebug_status; then
        echo "enabled"
    else
        echo "disabled"
    fi
}

# Function to display Xdebug configuration
show_xdebug_config() {
    echo -e "${BLUE}Current Xdebug configuration:${NC}"
    docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress php -i | grep -E "xdebug\.(mode|client_host|client_port|start_with_request)" | sed 's/^/  /' || echo "  No Xdebug configuration found"
}

# Get current status
CURRENT_STATUS=$(get_xdebug_status)
echo -e "${BLUE}Current Xdebug status: ${NC}${CURRENT_STATUS}"

# If argument provided, use it. Otherwise, toggle current state
if [ $# -eq 1 ]; then
    case "$1" in
        "on"|"enable"|"1"|"true")
            ACTION="enable"
            ;;
        "off"|"disable"|"0"|"false")
            ACTION="disable"
            ;;
        "status"|"check")
            echo
            show_xdebug_config
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid argument: $1${NC}"
            echo "Usage: $0 [on|off|enable|disable|status]"
            echo "  on/enable  - Enable Xdebug"
            echo "  off/disable - Disable Xdebug"
            echo "  status     - Show Xdebug configuration"
            echo "  (no args)  - Toggle current state"
            exit 1
            ;;
    esac
else
    # Toggle current state
    if [ "$CURRENT_STATUS" = "enabled" ]; then
        ACTION="disable"
    else
        ACTION="enable"
    fi
fi

echo
echo -e "${YELLOW}Action: ${ACTION^} Xdebug${NC}"

if [ "$ACTION" = "enable" ]; then
    if [ "$CURRENT_STATUS" = "enabled" ]; then
        echo -e "${GREEN}✓ Xdebug is already enabled${NC}"
    else
        echo -e "${YELLOW}Enabling Xdebug...${NC}"
        
        # Enable Xdebug by creating/modifying configuration
        docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress bash -c "
            echo 'zend_extension=xdebug.so
xdebug.mode=debug
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.start_with_request=yes
xdebug.discover_client_host=true
xdebug.idekey=PHPSTORM' > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
        "
        
        # Restart PHP-FPM to apply changes
        echo -e "${YELLOW}Restarting PHP-FPM...${NC}"
        docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress pkill -USR2 php-fpm || true
        
        # Wait a moment for the restart
        sleep 2
        
        # Verify Xdebug is enabled
        if check_xdebug_status; then
            echo -e "${GREEN}✓ Xdebug enabled successfully!${NC}"
        else
            echo -e "${RED}✗ Failed to enable Xdebug${NC}"
            exit 1
        fi
    fi
else
    if [ "$CURRENT_STATUS" = "disabled" ]; then
        echo -e "${GREEN}✓ Xdebug is already disabled${NC}"
    else
        echo -e "${YELLOW}Disabling Xdebug...${NC}"
        
        # Disable Xdebug by removing/commenting out the extension
        docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress bash -c "
            if [ -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini ]; then
                mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.disabled
            fi
        "
        
        # Restart PHP-FPM to apply changes
        echo -e "${YELLOW}Restarting PHP-FPM...${NC}"
        docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T wordpress pkill -USR2 php-fpm || true
        
        # Wait a moment for the restart
        sleep 2
        
        # Verify Xdebug is disabled
        if ! check_xdebug_status; then
            echo -e "${GREEN}✓ Xdebug disabled successfully!${NC}"
        else
            echo -e "${RED}✗ Failed to disable Xdebug${NC}"
            exit 1
        fi
    fi
fi

echo
echo -e "${BLUE}Final Xdebug status: ${NC}$(get_xdebug_status)"

# Show configuration if enabled
if [ "$(get_xdebug_status)" = "enabled" ]; then
    echo
    show_xdebug_config
    echo
    echo -e "${BLUE}IDE Configuration:${NC}"
    echo "  Host: host.docker.internal (or 172.17.0.1 on Linux)"
    echo "  Port: 9003"
    echo "  IDE Key: PHPSTORM"
fi

echo -e "${GREEN}Xdebug toggle completed!${NC}"
