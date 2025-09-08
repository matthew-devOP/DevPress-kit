# Apache2 Configuration for WordPress with PHP-FPM

This directory contains Apache2 configuration files optimized for running WordPress with PHP-FPM in a Docker environment.

## Files Overview

### `wordpress.conf`
Main virtual host configuration file that includes:
- Virtual host setup for WordPress on port 80
- Document root configuration
- **mod_rewrite enabled** with WordPress permalink rules
- **PHP-FPM proxy configuration** to communicate with PHP container
- Security headers (X-Content-Type-Options, X-Frame-Options, X-XSS-Protection)
- **Custom logging configuration** with detailed access and error logs

### `modules.conf`
Apache modules configuration file that loads all required modules:
- `mod_rewrite` for WordPress permalinks
- `mod_proxy` and `mod_proxy_fcgi` for PHP-FPM communication
- `mod_headers` for security headers
- Additional modules for directory handling, MIME types, and logging

### `apache2.conf`
Main Apache configuration file with global settings:
- Server optimization settings
- Security configurations
- Default directory permissions
- File upload limits (100M)
- Timeout and KeepAlive settings
- **PHP-FPM proxy pool configuration**

### `wordpress.htaccess`
Template .htaccess file for WordPress root directory:
- WordPress permalink rewrite rules
- Security enhancements
- File access restrictions
- Static content caching
- Text compression
- PHP settings optimization

## Usage in Docker

### In Dockerfile
```dockerfile
# Copy Apache configuration
COPY config/apache/apache2.conf /etc/apache2/apache2.conf
COPY config/apache/modules.conf /etc/apache2/conf-available/modules.conf
COPY config/apache/wordpress.conf /etc/apache2/sites-available/wordpress.conf

# Enable site and modules
RUN a2ensite wordpress && \
    a2enmod rewrite proxy proxy_fcgi headers && \
    a2dissite 000-default
```

### In docker-compose.yml
```yaml
services:
  apache:
    volumes:
      - ./config/apache/apache2.conf:/etc/apache2/apache2.conf
      - ./config/apache/modules.conf:/etc/apache2/conf-available/modules.conf
      - ./config/apache/wordpress.conf:/etc/apache2/sites-available/wordpress.conf
```

## Key Features

### ✅ Virtual Host Configuration
- Configured for localhost on port 80
- Document root set to `/var/www/html`
- Proper directory permissions and security

### ✅ mod_rewrite for Permalinks
- Enabled in both virtual host and .htaccess template
- WordPress-specific rewrite rules
- Pretty permalink support

### ✅ PHP-FPM Proxy Configuration
- Proxies PHP requests to `php:9000` container
- Proper FastCGI configuration
- Connection timeout and retry settings

### ✅ Custom Logging Configuration
- Separate error and access logs for WordPress
- Detailed logging format with response times
- Multiple log levels and formats

## Log Files Location
- Error log: `/var/log/apache2/wordpress_error.log`
- Access log: `/var/log/apache2/wordpress_access.log`
- Detailed log: `/var/log/apache2/wordpress_detailed.log`

## Security Features
- Server signature disabled
- Directory browsing disabled
- Sensitive files protected
- Security headers enabled
- File upload size limits
- Request filtering for malicious patterns

## Performance Optimizations
- KeepAlive enabled
- Static content caching
- Text compression (deflate)
- Optimized worker configuration
- Connection pooling for PHP-FPM
