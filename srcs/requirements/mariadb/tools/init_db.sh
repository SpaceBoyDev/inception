#!/bin/bash

echo "----------- MariaDB: Initializing... ----------"

# Create needed directories and change ownership
# /var/lib/mysql -> keep persistent data
# /run/mysqld -> keep temporary files
mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql && chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql

# Get credentials from secrets (automatically mounted in /run)
: "${MYSQL_DATABASE:?MYSQL_DATABASE is not set}"
: "${MYSQL_USER:?MYSQL_USER is not set}"
SQL_PASSWORD=$(cat /run/secrets/db_password)
SQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then # If db doesnt exist
	# skip-grant-tables -> bypass password checks during setup
	# skip-networking -> skips TCP/IP (uses local socket)
	mysqld_safe --skip-grant-tables --skip-networking &

	# Wait for it to start (ping it to know if its silent or it woke up)
	until mysqladmin ping -h localhost --silent; do
		echo "Waiting..."
		sleep 1
	done

	echo "Creating users..."

	# Create users database with user root (-u root) (- EOF ignores tabs)
	# - FLUSH PRIVILEGES -> restores privileges after --skip-grant-tables
	# - % -> allow connections from any host
	# - "IF NOT EXISTS" -> evita error
	# - ALTER USER -> changes root password
	# - FLUSH PRIVILEGES (again) -> Saves all changes (reloads RAM)
	mysql -u root <<-EOF
		FLUSH PRIVILEGES;
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
		ALTER USER \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
		FLUSH PRIVILEGES;
		EOF

	# Kill the background process (delete temp files, save data, end process)
	mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" shutdown
else
	# Keep an existing data volume compatible with the current Compose credentials.
	mysql -u root -p"${SQL_ROOT_PASSWORD}" <<-EOF
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
		ALTER USER \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';
		FLUSH PRIVILEGES;
		EOF
fi

echo "--------------- MariaDB: Started --------------"
# Executes mysqld as PID 1
# --user=mysql makes mysqld stop running as root and use mysql user (999)
# Logs errors in log-error
exec mysqld --user=mysql --log-warnings=1