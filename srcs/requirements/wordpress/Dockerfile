FROM alpine:3.23

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

RUN ln -s /usr/bin/php83 /usr/bin/php

RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php83/php-fpm.d/www.conf
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp
RUN echo "memory_limit = 256M" > /etc/php83/conf.d/wp-cli-memory.ini
WORKDIR /var/www/html

EXPOSE 9000

COPY ./entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["php-fpm83", "-F"]
