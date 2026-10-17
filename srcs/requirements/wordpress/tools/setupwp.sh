#!/bin/bash
set -e

echo "----------- Wordpress: Initializing... ----------"

WP_PATH="/var/www/html"

: "${WORDPRESS_DB_NAME:?WORDPRESS_DB_NAME is not set}"
: "${WORDPRESS_DB_USER:?WORDPRESS_DB_USER is not set}"
: "${WORDPRESS_DB_HOST:?WORDPRESS_DB_HOST is not set}"
: "${WORDPRESS_DB_PASSWORD_FILE:?WORDPRESS_DB_PASSWORD_FILE is not set}"

WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")

# Ensure PHP runtime dir exists
mkdir -p /run/php
mkdir -p "$WP_PATH"
if [ ! -f "$WP_PATH/index.php" ]; then
	cp -a /var/www/wordpress/. "$WP_PATH/"
fi
cd "$WP_PATH"

# Wait until mariadb is up
while ! printf "" 2>>/dev/null >/dev/tcp/mariadb/3306; do
	echo "Waiting..."
	sleep 1
done

if [ ! -f "$WP_PATH/wp-config.php" ]; then
	wp config create \
		--allow-root \
		--dbname="$WORDPRESS_DB_NAME" \
		--dbuser="$WORDPRESS_DB_USER" \
		--dbpass="$WORDPRESS_DB_PASSWORD" \
		--dbhost="$WORDPRESS_DB_HOST" \
		--path="$WP_PATH"
fi

chown -R www-data:www-data "$WP_PATH"

# Start PHP-FPM as PID 1
echo "Starting PHP"
exec php-fpm8.2 -F