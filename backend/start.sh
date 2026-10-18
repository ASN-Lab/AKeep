#!/bin/sh
set -e

# Fallback to 8000 if PORT is not set
PORT="${PORT:-8000}"
echo "Starting Nginx on port $PORT"

# Replace listen port in Nginx config
sed -i "s/listen 8000;/listen $PORT;/g" /etc/nginx/http.d/default.conf

# Start PHP-FPM in background
php-fpm -D

# Start Nginx in foreground
nginx -g 'daemon off;'
