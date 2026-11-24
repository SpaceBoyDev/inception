FROM alpine:3.23

# Instala PHP-FPM, extensiones y utilidades necesarias
RUN apk update && apk add \
php83 \
php83-fpm \
php83-mysqli \
php83-phar \
php83-mbstring \
php83-curl \
php83-gd \
mariadb-client \
wget

# Habilita el ejecutable PHP con un nombre habitual
RUN ln -s /usr/bin/php83 /usr/bin/php

# Permite que PHP-FPM reciba peticiones FastCGI en el puerto 9000
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php83/php-fpm.d/www.conf
# Descarga WP-CLI y lo deja disponible globalmente
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp
# Ajusta el límite de memoria para WordPress
RUN echo "memory_limit = 256M" > /etc/php83/conf.d/wp-cli-memory.ini
# Establece el directorio de trabajo de WordPress
WORKDIR /var/www/html

# Puerto FastCGI usado por Nginx
EXPOSE 9000

# Copia el script de arranque
COPY ./entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

# Ejecuta el entrypoint al iniciar el contenedor
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Arranca PHP-FPM sin ejecutar el proceso como demonio
CMD ["php-fpm83", "-F"]
