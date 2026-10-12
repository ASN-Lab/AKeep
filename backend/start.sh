#!/bin/sh
php-fpm &
sed -i "s/listen 8000;/listen ${PORT:-8000};/g" /etc/nginx/http.d/default.conf
nginx -g 'daemon off;'
