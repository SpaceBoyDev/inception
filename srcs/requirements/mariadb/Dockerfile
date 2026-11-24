FROM alpine:3.23

# Instala MariaDB y su cliente
RUN apk update && apk add mariadb mariadb-client
# Prepara el directorio usado por el servidor MySQL
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Puerto predeterminado de MariaDB
EXPOSE 3306

# Copia el script que inicializa y arranca el servicio
COPY ./entrypoint.sh  /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Ejecuta el entrypoint al iniciar el contenedor
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Comando predeterminado para iniciar MariaDB
CMD ["mysqld", "--user=mysql", "--console" ]
