#!/bin/sh

# Carga las contraseñas desde los secretos
DB_ROOT_PASS=$(cat /run/secrets/db_root_password)
DB_PASS=$(cat /run/secrets/db_password)

# Permite conexiones desde todos los interfaces
sed -i "s|*.bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

# Habilita el acceso de red
sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf

# Inicializa MariaDB cuando el volumen está vacío
if [ ! -d /var/lib/mysql/mysql ] ; then
	echo "Data directory empy... Initializing MariaDB";
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

# Inicia temporalmente MariaDB para crear la base de datos
	mysqld --user=mysql --datadir=/var/lib/mysql  --skip-networking  &
	pid="$!"
	
# Espera a que el servidor esté disponible
	while ! mysqladmin ping --silent; do
		sleep 1
	done

# Crea la base de datos y el usuario
	mysql -u root <<-EOSQL
		CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
		GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
		FLUSH PRIVILEGES;
EOSQL

# Detiene la instancia temporal
	mysqladmin -u root -p"${DB_ROOT_PASS}" shutdown
	wait "$pid"

	echo "Mariadb initialization completed"

fi

# Ejecuta el comando configurado en el contenedor
exec "$@"
