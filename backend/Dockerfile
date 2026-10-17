FROM php:8.4-fpm-alpine

WORKDIR /var/www/html

RUN apk add --no-cache \
    libpng-dev \
    libzip-dev \
    libintl \
    icu-dev \
    zip \
    unzip \
    git \
    curl \
    ca-certificates \
    oniguruma-dev \
    && docker-php-ext-install pdo pdo_mysql gd zip bcmath intl

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV LOG_CHANNEL=stderr

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN cp .env.example .env && php artisan key:generate

RUN mkdir -p storage/framework/sessions storage/framework/views storage/framework/cache \
    && chmod -R 777 storage bootstrap/cache

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8000}
