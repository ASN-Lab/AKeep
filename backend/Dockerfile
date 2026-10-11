FROM php:8.2-fpm-alpine

WORKDIR /var/www

RUN apk add --no-cache \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    oniguruma-dev \
    && docker-php-ext-install pdo pdo_mysql gd zip bcmath

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN php artisan key:generate

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000
