FROM alpine:3.23

ARG DOMAIN_NAME=dario.42.fr

RUN apk update && apk add nginx openssl

RUN mkdir -p /etc/nginx/ssl /var/run/nginx

RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=42/CN=${DOMAIN_NAME}/UID=dario"

COPY /conf/nginx.conf /etc/nginx/http.d/default.conf
RUN sed -i "s|server_name .*;|server_name ${DOMAIN_NAME};|" /etc/nginx/http.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
