#!/bin/sh

# Download website sources
git clone $1 www

# Build site
/usr/bin/hugo -D -s /src/www

# Run site
mkdir -p /run/nginx
/usr/sbin/nginx -g 'daemon off;'
