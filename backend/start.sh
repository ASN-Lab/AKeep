#!/bin/sh
# Update Nginx port to Railway PORT
sed -i "s/listen 8000;/listen ${PORT:-8000};/g" /etc/nginx/http.d/default.conf

# Start PHP-FPM
php-fpm -D

# Start Nginx
nginx -g 'daemon off;'
