# Use official PHP 8.2 with Apache
FROM php:8.2-apache

# Install dependencies & PHP extensions Moodle needs
RUN apt-get update && apt-get install -y \
    libpq-dev libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libicu-dev unzip git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip intl pdo pdo_pgsql pgsql

# Enable Apache mod_rewrite for Moodle friendly URLs
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy Moodle source code to container
COPY . /var/www/html/

# Fix permissions for Apache user
RUN chown -R www-data:www-data /var/www/html

# Create moodledata directory (outside webroot)
RUN mkdir -p /var/www/moodledata && chown -R www-data:www-data /var/www/moodledata

# Expose HTTP port
EXPOSE 80

# Custom PHP configs for Moodle (increase limits)
RUN echo "max_input_vars = 5000" > /usr/local/etc/php/conf.d/custom.ini \
 && echo "upload_max_filesize = 20M" >> /usr/local/etc/php/conf.d/custom.ini \
 && echo "post_max_size = 20M" >> /usr/local/etc/php/conf.d/custom.ini

# Start Apache in the foreground
CMD ["apache2-foreground"]
