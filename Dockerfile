# Use PHP 7.4-fpm as the base image
FROM php:7.4-fpm

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    wget \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mbstring zip pdo pdo_mysql

# Install ionCube loader
RUN wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xvf ioncube_loaders_lin_x86-64.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.4.so $(php -r "echo ini_get('extension_dir');") \
    && echo "zend_extension=$(php -r 'echo ini_get(\"extension_dir\");')/ioncube_loader_lin_7.4.so" > /usr/local/etc/php/conf.d/00-ioncube.ini \
    && rm -rf ioncube_loaders_lin_x86-64.tar.gz ioncube

# Configure Nginx
COPY default.conf /etc/nginx/conf.d/
RUN echo "daemon off;" >> /etc/nginx/nginx.conf



# Expose the necessary ports
EXPOSE 3003

# Start both PHP and Nginx together using supervisord
CMD ["php-fpm", "-D"] && nginx -g 'daemon off;'
