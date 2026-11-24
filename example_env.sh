º#!/bin/bash

rm srcs/.env
echo "DOMAIN_NAME=darmarti.42.fr
DATA_PATH=/home/darmarti/data

SQL_DATABASE=wordpress
SQL_USER=wordpress
SQL_HOST=mariadb

WP_URL=https://darmarti.42.fr
WP_TITLE=inception
WP_ADMIN_USER=darmarti42
WP_ADMIN_EMAIL=darmarti42@example.com
WP_USER=darmarti
WP_USER_EMAIL=darmarti@example.com" >> srcs/.env
