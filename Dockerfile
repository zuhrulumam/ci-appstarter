# Use the official PHP image with Apache
FROM php:8.2-apache

# Install system dependencies required for CodeIgniter (intl is crucial)
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install \
    intl \
    pdo_mysql \
    mysqli \
    zip \
    opcache

# Enable Apache Rewrite Module (Required for removing index.php from URL)
RUN a2enmod rewrite

# Change Apache Document Root to point to the /public folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf \ /etc/apache2/conf-available/*.conf

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Run Composer Install (Optimize for production)
RUN composer install --no-dev --optimize-autoloader

# Set Permissions for the 'writable' folder (CRITICAL for CodeIgniter)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/writable

# Expose port 80
EXPOSE 80
