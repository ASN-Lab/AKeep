FROM php:8.4-fpm-alpine

WORKDIR /app

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
    nginx \
    && docker-php-ext-install pdo pdo_mysql gd zip bcmath intl

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN cp .env.example .env && php artisan key:generate

RUN chmod -R 777 storage bootstrap/cache

COPY nginx.conf /etc/nginx/http.d/default.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8000

CMD ["/start.sh"]
