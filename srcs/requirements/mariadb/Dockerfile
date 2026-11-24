FROM alpine:3.23

RUN apk update && apk add mariadb mariadb-client
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

EXPOSE 3306

COPY ./entrypoint.sh  /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["mysqld", "--user=mysql", "--console" ]
