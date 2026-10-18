#!/bin/sh
set -e

PORT="${PORT:-8000}"
echo "Configuring Nginx to listen on port 8000 and port $PORT"

# Ensure Nginx listens on both 8000 and whatever $PORT is provided by Railway
if [ "$PORT" != "8000" ] && [ "$PORT" != "80" ]; then
    sed -i "s/listen 8000;/listen 8000;\n    listen $PORT;/g" /etc/nginx/http.d/default.conf
fi

# Start PHP-FPM in background
echo "Starting PHP-FPM..."
php-fpm -D

# Start Nginx in foreground
echo "Starting Nginx..."
nginx -g 'daemon off;'
