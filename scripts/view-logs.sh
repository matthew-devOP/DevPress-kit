#!/bin/bash

# View logs script for WordPress Fast Docker
# Tails logs from all containers or specific services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
FOLLOW=true
LINES=100
SERVICES=""
TIMESTAMPS=true

# Function to show usage
show_usage() {
    echo -e "${YELLOW}WordPress Docker Logs Viewer${NC}"
    echo "Usage: $0 [OPTIONS] [SERVICE...]"
    echo
    echo "Options:"
    echo "  -f, --follow      Follow log output (default: true)"
    echo "  --no-follow      Don't follow log output"
    echo "  -n, --lines N    Number of lines to show (default: 100)"
    echo "  -t, --timestamps Show timestamps (default: true)"
    echo "  --no-timestamps  Don't show timestamps"
    echo "  -h, --help       Show this help message"
    echo
    echo "Services:"
    echo "  wordpress        WordPress/PHP application"
    echo "  mysql           MySQL database"
    echo "  nginx           Nginx web server (if available)"
    echo "  redis           Redis cache (if available)"
    echo "  mailhog         Mailhog mail catcher (if available)"
    echo
    echo "Examples:"
    echo "  $0                           # View all logs (last 100 lines, follow)"
    echo "  $0 wordpress                # View only WordPress logs"
    echo "  $0 mysql wordpress          # View MySQL and WordPress logs"
    echo "  $0 -n 50 --no-follow        # Show last 50 lines without following"
    echo "  $0 --no-timestamps wordpress # View WordPress logs without timestamps"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--follow)
            FOLLOW=true
            shift
            ;;
        --no-follow)
            FOLLOW=false
            shift
            ;;
        -n|--lines)
            LINES="$2"
            if ! [[ "$LINES" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Error: Lines must be a number${NC}"
                exit 1
            fi
            shift 2
            ;;
        -t|--timestamps)
            TIMESTAMPS=true
            shift
            ;;
        --no-timestamps)
            TIMESTAMPS=false
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_usage
            exit 1
            ;;
        *)
            SERVICES="$SERVICES $1"
            shift
            ;;
    esac
done

echo -e "${YELLOW}Docker Logs Viewer${NC}"
echo "=================="

# Check if docker-compose is available and containers exist
if ! command -v docker-compose >/dev/null 2>&1; then
    echo -e "${RED}Error: docker-compose not found${NC}"
    exit 1
fi

# Get list of available services
AVAILABLE_SERVICES=$(docker-compose -f "$PROJECT_ROOT/docker-compose.yml" config --services 2>/dev/null | sort)

if [ -z "$AVAILABLE_SERVICES" ]; then
    echo -e "${RED}Error: No services found in docker-compose.yml${NC}"
    exit 1
fi

echo -e "${BLUE}Available services:${NC} $(echo $AVAILABLE_SERVICES | tr '\n' ' ')"

# If no services specified, use all available services
if [ -z "$SERVICES" ]; then
    SERVICES="$AVAILABLE_SERVICES"
    echo -e "${GREEN}Viewing logs for all services${NC}"
else
    # Validate specified services
    for service in $SERVICES; do
        if ! echo "$AVAILABLE_SERVICES" | grep -q "^${service}$"; then
            echo -e "${RED}Error: Service '$service' not found${NC}"
            echo -e "${YELLOW}Available services: $(echo $AVAILABLE_SERVICES | tr '\n' ' ')${NC}"
            exit 1
        fi
    done
    echo -e "${GREEN}Viewing logs for services:${NC} $SERVICES"
fi

# Check if any of the specified services are running
RUNNING_SERVICES=""
for service in $SERVICES; do
    if docker-compose -f "$PROJECT_ROOT/docker-compose.yml" ps "$service" 2>/dev/null | grep -q "Up"; then
        RUNNING_SERVICES="$RUNNING_SERVICES $service"
    else
        echo -e "${YELLOW}Warning: Service '$service' is not running${NC}"
    fi
done

if [ -z "$RUNNING_SERVICES" ]; then
    echo -e "${RED}Error: None of the specified services are running${NC}"
    echo "Start services with: docker-compose up -d"
    exit 1
fi

# Build docker-compose logs command
CMD="docker-compose -f $PROJECT_ROOT/docker-compose.yml logs"

if [ "$TIMESTAMPS" = "true" ]; then
    CMD="$CMD -t"
fi

if [ "$FOLLOW" = "true" ]; then
    CMD="$CMD -f"
fi

CMD="$CMD --tail=$LINES"

# Add services to command
for service in $RUNNING_SERVICES; do
    CMD="$CMD $service"
done

echo
echo -e "${BLUE}Configuration:${NC}"
echo "  Lines: $LINES"
echo "  Follow: $FOLLOW"
echo "  Timestamps: $TIMESTAMPS"
echo "  Services: $RUNNING_SERVICES"

echo
echo -e "${CYAN}Starting log viewer... (Press Ctrl+C to stop)${NC}"
echo "=================================================="

# Add some helpful information for the user
if [ "$FOLLOW" = "true" ]; then
    echo -e "${YELLOW}Tip: Press Ctrl+C to stop following logs${NC}"
fi

echo

# Execute the logs command
exec $CMD
