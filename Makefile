.PHONY: up down logs backup reset shell-php shell-db help

# Default target
help:
	@echo "Available commands:"
	@echo "  make up        - Start all containers and run initialization"
	@echo "  make down      - Stop and remove containers"
	@echo "  make logs      - View centralized logs"
	@echo "  make backup    - Backup database"
	@echo "  make reset     - Reset WordPress installation"
	@echo "  make shell-php - Access PHP container shell"
	@echo "  make shell-db  - Access database shell"

# Start all containers and run initialization
up:
	@echo "Starting WordPress development environment..."
	docker-compose up -d
	@echo "Waiting for services to be ready..."
	sleep 10
	@echo "Running initialization scripts..."
	docker-compose exec wordpress bash -c "if [ -f /var/www/html/init.sh ]; then /var/www/html/init.sh; fi"
	@echo "WordPress environment is ready!"
	@echo "Access your site at: http://localhost:8080"

# Stop and remove containers
down:
	@echo "Stopping and removing containers..."
	docker-compose down
	@echo "Containers stopped and removed."

# View centralized logs
logs:
	@echo "Viewing logs from all containers..."
	docker-compose logs -f

# Backup database
backup:
	@echo "Creating database backup..."
	@mkdir -p backups
	@TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	docker-compose exec -T db mysqldump -u wordpress -pwordpress wordpress > backups/wordpress_backup_$$TIMESTAMP.sql && \
	echo "Database backup created: backups/wordpress_backup_$$TIMESTAMP.sql"

# Reset WordPress installation
reset:
	@echo "WARNING: This will reset your WordPress installation!"
	@echo "Press Ctrl+C within 5 seconds to cancel..."
	@sleep 5
	@echo "Stopping containers..."
	docker-compose down
	@echo "Removing WordPress data..."
	docker volume rm $$(docker volume ls -q | grep wordpress) 2>/dev/null || true
	@echo "Removing uploads and content..."
	sudo rm -rf wordpress/wp-content/uploads/* 2>/dev/null || true
	@echo "Starting fresh installation..."
	docker-compose up -d
	@echo "WordPress has been reset. Access at: http://localhost:8080"

# Access PHP container shell
shell-php:
	@echo "Accessing WordPress PHP container shell..."
	docker-compose exec wordpress bash

# Access database shell
shell-db:
	@echo "Accessing MySQL database shell..."
	docker-compose exec db mysql -u wordpress -pwordpress wordpress
