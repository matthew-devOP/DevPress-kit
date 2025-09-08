FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        mysqli \
        gd \
        zip \
        opcache \
        pdo_mysql \
        intl \
        mbstring

# Install Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create PHP configuration directory
RUN mkdir -p /usr/local/etc/php/conf.d

# Configure Opcache for performance
RUN echo 'opcache.enable=1' >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo 'opcache.enable_cli=1' >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo 'opcache.memory_consumption=256' >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo 'opcache.interned_strings_buffer=16' >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo 'opcache.max_accelerated_files=10000' >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo 'opcache.revalidate_freq=2' >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo 'opcache.fast_shutdown=1' >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo 'opcache.validate_timestamps=1' >> /usr/local/etc/php/conf.d/opcache.ini

# Configure Xdebug with environment variable toggle
RUN echo 'xdebug.mode=${XDEBUG_MODE:-off}' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.client_host=${XDEBUG_CLIENT_HOST:-host.docker.internal}' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.client_port=${XDEBUG_CLIENT_PORT:-9003}' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.start_with_request=yes' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.discover_client_host=false' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.log_level=0' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Additional PHP configuration for WordPress
RUN echo 'upload_max_filesize=64M' >> /usr/local/etc/php/conf.d/wordpress.ini \
    && echo 'post_max_size=64M' >> /usr/local/etc/php/conf.d/wordpress.ini \
    && echo 'memory_limit=256M' >> /usr/local/etc/php/conf.d/wordpress.ini \
    && echo 'max_execution_time=300' >> /usr/local/etc/php/conf.d/wordpress.ini \
    && echo 'max_input_vars=3000' >> /usr/local/etc/php/conf.d/wordpress.ini

# Set working directory
WORKDIR /var/www/html

# Change ownership of the working directory to www-data
RUN chown -R www-data:www-data /var/www/html

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
