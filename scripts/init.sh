#!/bin/bash

# WordPress Initialization Script
# This script sets up WordPress using WP-CLI with all necessary configurations

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables (can be overridden by environment variables)
DB_HOST="${DB_HOST:-db}"
DB_NAME="${DB_NAME:-wordpress}"
DB_USER="${DB_USER:-wordpress}"
DB_PASSWORD="${DB_PASSWORD:-wordpress}"
DB_PREFIX="${DB_PREFIX:-wp_}"

# WordPress configuration
WP_URL="${WP_URL:-http://localhost:8080}"
WP_TITLE="${WP_TITLE:-WordPress Fast Docker}"
WP_ADMIN_USER="${WP_ADMIN_USER:-admin}"
WP_ADMIN_PASSWORD="${WP_ADMIN_PASSWORD:-admin123}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@example.com}"

# MailHog configuration
MAILHOG_HOST="${MAILHOG_HOST:-mailhog}"
MAILHOG_PORT="${MAILHOG_PORT:-1025}"

# Essential plugins to install
ESSENTIAL_PLUGINS=(
    "wp-mail-smtp"
    "classic-editor"
    "akismet"
    "wordpress-seo"
    "wordfence"
)

echo -e "${BLUE}Starting WordPress initialization...${NC}"

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

# Function to wait for database availability
wait_for_database() {
    print_status "Waiting for database to be ready..."
    
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if wp db check --allow-root 2>/dev/null; then
            print_status "Database is ready!"
            return 0
        fi
        
        echo -e "${YELLOW}Attempt $attempt/$max_attempts: Database not ready, waiting 5 seconds...${NC}"
        sleep 5
        ((attempt++))
    done
    
    print_error "Database failed to become ready after $max_attempts attempts"
    exit 1
}

# Function to download WordPress core
download_wordpress() {
    if [ -f "wp-config.php" ] || [ -f "index.php" ]; then
        print_warning "WordPress files already exist, skipping download"
        return 0
    fi
    
    print_status "Downloading WordPress core..."
    wp core download --allow-root --force
    print_status "WordPress core downloaded successfully"
}

# Function to create wp-config.php
create_wp_config() {
    if [ -f "wp-config.php" ]; then
        print_warning "wp-config.php already exists"
        
        # Check if we need to update database credentials
        if ! wp config get DB_NAME --allow-root >/dev/null 2>&1; then
            print_status "Updating wp-config.php with database credentials..."
            wp config create \
                --dbname="$DB_NAME" \
                --dbuser="$DB_USER" \
                --dbpass="$DB_PASSWORD" \
                --dbhost="$DB_HOST" \
                --dbprefix="$DB_PREFIX" \
                --allow-root \
                --force
        fi
    else
        print_status "Creating wp-config.php..."
        wp config create \
            --dbname="$DB_NAME" \
            --dbuser="$DB_USER" \
            --dbpass="$DB_PASSWORD" \
            --dbhost="$DB_HOST" \
            --dbprefix="$DB_PREFIX" \
            --allow-root
        
        # Add additional security configurations
        wp config set WP_DEBUG true --raw --allow-root
        wp config set WP_DEBUG_LOG true --raw --allow-root
        wp config set WP_DEBUG_DISPLAY false --raw --allow-root
        wp config set SCRIPT_DEBUG true --raw --allow-root
        wp config set WP_MEMORY_LIMIT '512M' --allow-root
        
        print_status "wp-config.php created successfully"
    fi
}

# Function to install WordPress
install_wordpress() {
    if wp core is-installed --allow-root 2>/dev/null; then
        print_warning "WordPress is already installed"
        return 0
    fi
    
    print_status "Installing WordPress..."
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
    
    print_status "WordPress installed successfully"
}

# Function to set permalinks
set_permalinks() {
    print_status "Setting permalinks structure..."
    wp rewrite structure '/%postname%/' --allow-root
    wp rewrite flush --allow-root
    print_status "Permalinks structure set to '/%postname%/'"
}

# Function to configure MailHog SMTP settings
configure_mailhog() {
    print_status "Configuring MailHog SMTP settings..."
    
    # Set WordPress mail configuration for MailHog
    wp config set WPMS_ON true --raw --allow-root
    wp config set WPMS_MAIL_FROM "$WP_ADMIN_EMAIL" --allow-root
    wp config set WPMS_MAIL_FROM_NAME "$WP_TITLE" --allow-root
    wp config set WPMS_MAILER 'smtp' --allow-root
    wp config set WPMS_SMTP_HOST "$MAILHOG_HOST" --allow-root
    wp config set WPMS_SMTP_PORT "$MAILHOG_PORT" --raw --allow-root
    wp config set WPMS_SMTP_AUTH false --raw --allow-root
    wp config set WPMS_SMTP_AUTOTLS false --raw --allow-root
    
    print_status "MailHog SMTP configuration completed"
}

# Function to install and activate plugins
install_plugins() {
    print_status "Installing and activating essential plugins..."
    
    for plugin in "${ESSENTIAL_PLUGINS[@]}"; do
        if wp plugin is-installed "$plugin" --allow-root; then
            print_warning "Plugin '$plugin' is already installed"
            if ! wp plugin is-active "$plugin" --allow-root; then
                wp plugin activate "$plugin" --allow-root
                print_status "Plugin '$plugin' activated"
            else
                print_status "Plugin '$plugin' is already active"
            fi
        else
            print_status "Installing plugin: $plugin"
            if wp plugin install "$plugin" --activate --allow-root; then
                print_status "Plugin '$plugin' installed and activated successfully"
            else
                print_error "Failed to install plugin: $plugin"
            fi
        fi
    done
}

# Function to configure WP Mail SMTP plugin
configure_wp_mail_smtp() {
    if wp plugin is-active wp-mail-smtp --allow-root; then
        print_status "Configuring WP Mail SMTP plugin for MailHog..."
        
        # Configure WP Mail SMTP options
        wp option update wp_mail_smtp '{"mail":{"from_email":"'$WP_ADMIN_EMAIL'","from_name":"'$WP_TITLE'","mailer":"smtp","return_path":true},"smtp":{"autotls":false,"auth":false,"host":"'$MAILHOG_HOST'","encryption":"none","port":'$MAILHOG_PORT',"user":"","pass":""},"license":{"type":""},"logs":{"enabled":true}}' --format=json --allow-root
        
        print_status "WP Mail SMTP configured for MailHog"
    fi
}

# Function to set up development environment
setup_development() {
    print_status "Setting up development environment..."
    
    # Install additional development plugins if not in production
    if [ "$WP_ENVIRONMENT_TYPE" != "production" ]; then
        dev_plugins=("query-monitor" "debug-bar" "wp-crontrol")
        
        for plugin in "${dev_plugins[@]}"; do
            if ! wp plugin is-installed "$plugin" --allow-root; then
                print_status "Installing development plugin: $plugin"
                wp plugin install "$plugin" --activate --allow-root || print_warning "Failed to install $plugin"
            fi
        done
    fi
    
    # Create uploads directory with proper permissions
    mkdir -p wp-content/uploads
    chmod 755 wp-content/uploads
    
    print_status "Development environment setup completed"
}

# Function to display summary
display_summary() {
    echo ""
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}WordPress Setup Complete!${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo -e "${BLUE}WordPress URL:${NC} $WP_URL"
    echo -e "${BLUE}Admin URL:${NC} $WP_URL/wp-admin"
    echo -e "${BLUE}Admin Username:${NC} $WP_ADMIN_USER"
    echo -e "${BLUE}Admin Email:${NC} $WP_ADMIN_EMAIL"
    echo -e "${BLUE}Database:${NC} $DB_NAME on $DB_HOST"
    echo -e "${BLUE}MailHog:${NC} http://localhost:8025 (Web UI)"
    echo ""
    echo -e "${YELLOW}Installed Plugins:${NC}"
    wp plugin list --status=active --allow-root --format=table
    echo ""
}

# Main execution
main() {
    echo -e "${BLUE}WordPress Fast Docker - Initialization Script${NC}"
    echo "=============================================="
    
    # Change to WordPress directory if it exists
    if [ -d "/var/www/html" ]; then
        cd /var/www/html
        print_status "Changed to WordPress directory: /var/www/html"
    fi
    
    # Execute setup steps
    wait_for_database
    download_wordpress
    create_wp_config
    install_wordpress
    set_permalinks
    configure_mailhog
    install_plugins
    configure_wp_mail_smtp
    setup_development
    display_summary
    
    echo -e "${GREEN}WordPress initialization completed successfully!${NC}"
}

# Handle script interruption
trap 'print_error "Script interrupted by user"; exit 130' INT

# Run main function
main "$@"
