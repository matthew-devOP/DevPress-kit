#!/bin/bash

# WordPress Fast Docker - Startup Script
# This script provides a comprehensive startup solution for the WordPress development environment
# Features: Docker checks, service startup, health monitoring, WordPress initialization, and browser launching

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration variables
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
INIT_SCRIPT="scripts/init.sh"
LOGS_DIR="logs"

# Service URLs (based on docker-compose.yml and .env)
WORDPRESS_URL="http://localhost:80"
PHPMYADMIN_URL="http://localhost:8080"
MAILHOG_URL="http://localhost:8025"

# Required directories
REQUIRED_DIRS=(
    "src"
    "config/apache"
    "config/php" 
    "config/mysql"
    "config/phpmyadmin"
    "sql/init"
    "logs"
    "scripts"
)

# Service health check endpoints
SERVICES=(
    "apache:80:/index.php"
    "phpmyadmin:8080:/"
    "mailhog:8025/"
    "mariadb:3306"
)

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}  WordPress Fast Docker - Startup Script  ${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${CYAN}=== $1 ===${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Docker installation
check_docker() {
    print_header "Checking Docker Installation"
    
    if ! command_exists docker; then
        print_error "Docker is not installed or not in PATH"
        echo "Please install Docker from: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running"
        echo "Please start Docker daemon and try again"
        exit 1
    fi
    
    DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
    print_status "Docker is installed and running (version: $DOCKER_VERSION)"
}

# Function to check Docker Compose installation
check_docker_compose() {
    print_header "Checking Docker Compose Installation"
    
    # Check for Docker Compose V2 (docker compose) or V1 (docker-compose)
    if docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD="docker compose"
        COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || echo "v2.x")
        print_status "Docker Compose V2 is available (version: $COMPOSE_VERSION)"
    elif command_exists docker-compose; then
        COMPOSE_CMD="docker-compose"
        COMPOSE_VERSION=$(docker-compose --version | cut -d ' ' -f3 | cut -d ',' -f1)
        print_status "Docker Compose V1 is available (version: $COMPOSE_VERSION)"
    else
        print_error "Docker Compose is not installed"
        echo "Please install Docker Compose from: https://docs.docker.com/compose/install/"
        exit 1
    fi
}

# Function to check required files
check_required_files() {
    print_header "Checking Required Files"
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        print_error "Docker Compose file not found: $COMPOSE_FILE"
        exit 1
    fi
    print_status "Docker Compose file found: $COMPOSE_FILE"
    
    if [ ! -f "$ENV_FILE" ]; then
        print_warning "Environment file not found: $ENV_FILE"
        print_status "Creating default .env file..."
        create_default_env_file
    else
        print_status "Environment file found: $ENV_FILE"
    fi
    
    if [ ! -f "$INIT_SCRIPT" ]; then
        print_warning "WordPress initialization script not found: $INIT_SCRIPT"
    else
        print_status "WordPress initialization script found: $INIT_SCRIPT"
        # Make sure the init script is executable
        chmod +x "$INIT_SCRIPT"
    fi
}

# Function to create default .env file if it doesn't exist
create_default_env_file() {
    cat > "$ENV_FILE" << 'EOF'
# Database Configuration
MYSQL_DATABASE=webapp_db
MYSQL_USER=webapp_user
MYSQL_PASSWORD=webapp_pass
MYSQL_ROOT_PASSWORD=root_password

# WordPress Configuration
WP_DEBUG=true
WP_HOME=http://localhost:80
WP_SITEURL=http://localhost:80

# WordPress Admin Credentials for Auto-Installation
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=admin_password
WP_ADMIN_EMAIL=admin@localhost.local
WP_SITE_TITLE=WordPress Development Site
EOF
    print_status "Created default .env file"
}

# Function to create necessary directories
create_directories() {
    print_header "Creating Necessary Directories"
    
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_status "Created directory: $dir"
        else
            print_status "Directory already exists: $dir"
        fi
    done
    
    # Set proper permissions for web directories
    if [ -d "src" ]; then
        chmod -R 755 src
        print_status "Set permissions for src directory"
    fi
    
    # Create logs directory with proper structure
    mkdir -p "$LOGS_DIR/apache" "$LOGS_DIR/php" "$LOGS_DIR/mysql"
    print_status "Created log directories"
}

# Function to load environment variables
load_environment() {
    if [ -f "$ENV_FILE" ]; then
        print_status "Loading environment variables from $ENV_FILE"
        set -a  # automatically export all variables
        source "$ENV_FILE"
        set +a
        
        # Update service URLs based on environment variables
        if [ -n "$WP_PORT" ]; then
            WORDPRESS_URL="http://localhost:$WP_PORT"
        fi
        if [ -n "$PHPMYADMIN_PORT" ]; then
            PHPMYADMIN_URL="http://localhost:$PHPMYADMIN_PORT"
        fi
    fi
}

# Function to stop existing containers
stop_existing_containers() {
    print_header "Stopping Existing Containers"
    
    if $COMPOSE_CMD ps --services 2>/dev/null | grep -q .; then
        print_status "Stopping existing Docker Compose services..."
        $COMPOSE_CMD down --remove-orphans
        print_status "Existing containers stopped"
    else
        print_status "No existing containers to stop"
    fi
}

# Function to start Docker Compose services
start_services() {
    print_header "Starting Docker Compose Services"
    
    print_status "Building and starting services..."
    $COMPOSE_CMD up -d --build
    
    if [ $? -eq 0 ]; then
        print_success "Services started successfully"
    else
        print_error "Failed to start services"
        exit 1
    fi
}

# Function to wait for service to be ready
wait_for_service() {
    local service_name=$1
    local port=$2
    local endpoint=${3:-""}
    local max_attempts=30
    local attempt=1
    
    print_status "Waiting for $service_name to be ready on port $port..."
    
    while [ $attempt -le $max_attempts ]; do
        if [ "$service_name" = "mariadb" ]; then
            # Special check for MariaDB using Docker exec
            if $COMPOSE_CMD exec -T mariadb mysql -u root -p"${MYSQL_ROOT_PASSWORD:-root_password}" -e "SELECT 1" >/dev/null 2>&1; then
                print_success "$service_name is ready!"
                return 0
            fi
        else
            # HTTP service check
            if curl -f -s "http://localhost:$port$endpoint" >/dev/null 2>&1; then
                print_success "$service_name is ready!"
                return 0
            fi
        fi
        
        printf "${YELLOW}Attempt %d/%d: %s not ready, waiting 5 seconds...${NC}\n" "$attempt" "$max_attempts" "$service_name"
        sleep 5
        ((attempt++))
    done
    
    print_error "$service_name failed to become ready after $max_attempts attempts"
    return 1
}

# Function to wait for all services to be ready
wait_for_services() {
    print_header "Waiting for Services to be Ready"
    
    # Wait for MariaDB first (other services depend on it)
    wait_for_service "mariadb" "3306"
    
    # Wait for other services
    wait_for_service "apache" "80" "/index.php"
    wait_for_service "phpmyadmin" "8080" "/"
    wait_for_service "mailhog" "8025" "/"
    
    print_success "All services are ready!"
}

# Function to run WordPress initialization
run_wordpress_init() {
    print_header "Running WordPress Initialization"
    
    if [ -f "$INIT_SCRIPT" ]; then
        print_status "Running WordPress initialization script..."
        
        # Run the initialization script inside the php-fpm container
        if $COMPOSE_CMD exec -T php-fpm /bin/bash -c "
            # Source environment variables
            export DB_HOST=mariadb
            export DB_NAME=\${MYSQL_DATABASE:-webapp_db}
            export DB_USER=\${MYSQL_USER:-webapp_user}
            export DB_PASSWORD=\${MYSQL_PASSWORD:-webapp_pass}
            export WP_URL=http://localhost
            export WP_ADMIN_USER=\${WP_ADMIN_USER:-admin}
            export WP_ADMIN_PASSWORD=\${WP_ADMIN_PASSWORD:-admin_password}
            export WP_ADMIN_EMAIL=\${WP_ADMIN_EMAIL:-admin@localhost.local}
            export WP_TITLE=\"\${WP_SITE_TITLE:-WordPress Development Site}\"
            
            cd /var/www/html
            
            # Copy and run the initialization script
            if [ -f /tmp/init.sh ]; then
                chmod +x /tmp/init.sh
                /tmp/init.sh
            else
                echo 'Initialization script not found in container'
            fi
        "; then
            # Copy the init script to the container first
            $COMPOSE_CMD cp "$INIT_SCRIPT" php-fpm:/tmp/init.sh
            
            # Run the initialization
            $COMPOSE_CMD exec -T php-fpm /bin/bash /tmp/init.sh
            
            print_success "WordPress initialization completed"
        else
            print_warning "Failed to run WordPress initialization script"
        fi
    else
        print_warning "WordPress initialization script not found, skipping..."
        print_status "You may need to manually configure WordPress"
    fi
}

# Function to open browser
open_browser() {
    print_header "Opening Browser"
    
    # Check if we should open browser (can be disabled by setting NO_BROWSER=1)
    if [ "$NO_BROWSER" = "1" ]; then
        print_status "Browser opening disabled by NO_BROWSER environment variable"
        return 0
    fi
    
    # Detect OS and open browser accordingly
    case "$(uname -s)" in
        Darwin*)
            # macOS
            print_status "Opening WordPress in browser (macOS)..."
            open "$WORDPRESS_URL" 2>/dev/null || print_warning "Could not open WordPress URL"
            sleep 2
            print_status "Opening phpMyAdmin in browser (macOS)..."
            open "$PHPMYADMIN_URL" 2>/dev/null || print_warning "Could not open phpMyAdmin URL"
            ;;
        Linux*)
            # Linux
            if command_exists xdg-open; then
                print_status "Opening WordPress in browser (Linux)..."
                xdg-open "$WORDPRESS_URL" 2>/dev/null || print_warning "Could not open WordPress URL"
                sleep 2
                print_status "Opening phpMyAdmin in browser (Linux)..."
                xdg-open "$PHPMYADMIN_URL" 2>/dev/null || print_warning "Could not open phpMyAdmin URL"
            else
                print_warning "xdg-open not found. Please open $WORDPRESS_URL manually"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            # Windows (Git Bash, MSYS2, Cygwin)
            print_status "Opening WordPress in browser (Windows)..."
            start "$WORDPRESS_URL" 2>/dev/null || print_warning "Could not open WordPress URL"
            sleep 2
            print_status "Opening phpMyAdmin in browser (Windows)..."
            start "$PHPMYADMIN_URL" 2>/dev/null || print_warning "Could not open phpMyAdmin URL"
            ;;
        *)
            print_warning "Unknown OS. Please open $WORDPRESS_URL manually"
            ;;
    esac
}

# Function to show connection information
show_connection_info() {
    print_header "Connection Information & Access URLs"
    
    echo ""
    echo -e "${PURPLE}🌐 Web Services:${NC}"
    echo -e "   ${BLUE}WordPress:${NC}     $WORDPRESS_URL"
    echo -e "   ${BLUE}WordPress Admin:${NC} $WORDPRESS_URL/wp-admin"
    echo -e "   ${BLUE}phpMyAdmin:${NC}    $PHPMYADMIN_URL"
    echo -e "   ${BLUE}MailHog Web UI:${NC} $MAILHOG_URL"
    
    echo ""
    echo -e "${PURPLE}🗄️  Database Connection:${NC}"
    echo -e "   ${BLUE}Host:${NC}     localhost"
    echo -e "   ${BLUE}Port:${NC}     3306"
    echo -e "   ${BLUE}Database:${NC} ${MYSQL_DATABASE:-webapp_db}"
    echo -e "   ${BLUE}Username:${NC} ${MYSQL_USER:-webapp_user}"
    echo -e "   ${BLUE}Root User:${NC} root"
    
    echo ""
    echo -e "${PURPLE}📧 SMTP Configuration (MailHog):${NC}"
    echo -e "   ${BLUE}SMTP Host:${NC} localhost"
    echo -e "   ${BLUE}SMTP Port:${NC} 1025"
    echo -e "   ${BLUE}Web UI:${NC}    $MAILHOG_URL"
    
    echo ""
    echo -e "${PURPLE}📊 WordPress Admin Credentials:${NC}"
    echo -e "   ${BLUE}Username:${NC} ${WP_ADMIN_USER:-admin}"
    echo -e "   ${BLUE}Email:${NC}    ${WP_ADMIN_EMAIL:-admin@localhost.local}"
    echo -e "   ${YELLOW}Password:${NC} Check your .env file or init script"
    
    echo ""
    echo -e "${PURPLE}📁 Important Directories:${NC}"
    echo -e "   ${BLUE}WordPress Files:${NC} ./src/"
    echo -e "   ${BLUE}Apache Config:${NC}   ./config/apache/"
    echo -e "   ${BLUE}PHP Config:${NC}      ./config/php/"
    echo -e "   ${BLUE}MySQL Config:${NC}    ./config/mysql/"
    echo -e "   ${BLUE}Logs:${NC}            ./logs/"
    
    echo ""
    echo -e "${PURPLE}📋 Container Status:${NC}"
    $COMPOSE_CMD ps
    
    echo ""
}

# Function to show logs location and useful commands
show_logs_info() {
    print_header "Logs Location & Useful Commands"
    
    echo ""
    echo -e "${PURPLE}📊 Log Locations:${NC}"
    echo -e "   ${BLUE}Application Logs:${NC} ./logs/"
    echo -e "   ${BLUE}Container Logs:${NC}   Use 'docker-compose logs [service]'"
    
    echo ""
    echo -e "${PURPLE}🛠️  Useful Commands:${NC}"
    echo -e "   ${BLUE}View all logs:${NC}        $COMPOSE_CMD logs -f"
    echo -e "   ${BLUE}View specific service:${NC} $COMPOSE_CMD logs -f [apache|php-fpm|mariadb|phpmyadmin]"
    echo -e "   ${BLUE}Stop services:${NC}        $COMPOSE_CMD down"
    echo -e "   ${BLUE}Restart services:${NC}     $COMPOSE_CMD restart"
    echo -e "   ${BLUE}Rebuild services:${NC}     $COMPOSE_CMD up -d --build"
    echo -e "   ${BLUE}Access container:${NC}     $COMPOSE_CMD exec [service] /bin/bash"
    
    echo ""
    echo -e "${PURPLE}🔧 Development Commands:${NC}"
    echo -e "   ${BLUE}WordPress CLI:${NC}        $COMPOSE_CMD exec php-fpm wp --allow-root [command]"
    echo -e "   ${BLUE}MySQL CLI:${NC}            $COMPOSE_CMD exec mariadb mysql -u root -p"
    echo -e "   ${BLUE}View PHP logs:${NC}        $COMPOSE_CMD logs -f php-fpm"
    
    echo ""
}

# Function to handle cleanup on script exit
cleanup() {
    if [ $? -ne 0 ]; then
        print_error "Startup script failed. Cleaning up..."
        print_status "You can check logs with: $COMPOSE_CMD logs"
    fi
}

# Function to show final success message
show_success_message() {
    echo ""
    echo -e "${GREEN}🎉 SUCCESS! WordPress development environment is ready!${NC}"
    echo ""
    echo -e "${YELLOW}Quick Start:${NC}"
    echo -e "1. Visit ${BLUE}$WORDPRESS_URL${NC} to see your WordPress site"
    echo -e "2. Admin panel: ${BLUE}$WORDPRESS_URL/wp-admin${NC}"
    echo -e "3. Database management: ${BLUE}$PHPMYADMIN_URL${NC}"
    echo -e "4. Email testing: ${BLUE}$MAILHOG_URL${NC}"
    echo ""
    echo -e "${YELLOW}To stop the environment:${NC} ${BLUE}$COMPOSE_CMD down${NC}"
    echo -e "${YELLOW}To view logs:${NC} ${BLUE}$COMPOSE_CMD logs -f${NC}"
    echo ""
}

# Main execution function
main() {
    # Set up error handling
    trap cleanup EXIT
    
    # Load environment variables early
    load_environment
    
    # Run all checks and setup steps
    check_docker
    check_docker_compose
    check_required_files
    create_directories
    
    # Stop any existing containers
    stop_existing_containers
    
    # Start services
    start_services
    
    # Wait for services to be ready
    wait_for_services
    
    # Run WordPress initialization if script exists
    run_wordpress_init
    
    # Open browser
    open_browser
    
    # Show connection information
    show_connection_info
    
    # Show logs information
    show_logs_info
    
    # Show final success message
    show_success_message
}

# Handle script interruption
trap 'print_error "Script interrupted by user"; exit 130' INT

# Check if script is being sourced or executed
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Script is being executed directly
    main "$@"
fi
