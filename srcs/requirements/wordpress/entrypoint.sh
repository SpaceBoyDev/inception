#!/bin/sh
DB_PASS=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)

set -e

if [ ! -f "/var/www/html/wp-config.php" ]; then
	echo "Descargando WordPress..."
	wp core download --allow-root
	echo "Esperando a MariaDB..."
	while ! mariadb -h"${SQL_HOST}" -u"${SQL_USER}" -p"${DB_PASS}" -e "SELECT 1;" >/dev/null 2>&1; do
		sleep 1
	done
	echo "MariaDB está listo."
	wp config create --allow-root \
		--dbname="${SQL_DATABASE}" \
		--dbuser="${SQL_USER}" \
		--dbpass="${DB_PASS}" \
		--dbhost="${SQL_HOST}"
	wp core install --allow-root \
		--url="${WP_URL}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASS}" \
		--admin_email="${WP_ADMIN_EMAIL}"
	wp user create --allow-root \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PASS}" \
		--role=author
	chown -R nobody:nobody /var/www/html
	find /var/www/html -type d -exec chmod 755 {} \;
	find /var/www/html -type f -exec chmod 644 {} \;
	echo "WordPress instalado y configurado correctamente."
fi
exec "$@"
