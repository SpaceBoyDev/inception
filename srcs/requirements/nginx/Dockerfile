FROM alpine:3.23

ARG DOMAIN_NAME=darmarti.42.fr

# Instala Nginx y las herramientas necesarias para generar TLS
RUN apk update && apk add nginx openssl

# Crea los directorios de certificados y ejecución
RUN mkdir -p /etc/nginx/ssl /var/run/nginx

# Genera un certificado autofirmado para el dominio configurado
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=42/CN=${DOMAIN_NAME}/UID=darmarti"

# Configura el servidor virtual y el nombre de dominio
COPY /conf/nginx.conf /etc/nginx/http.d/default.conf
RUN sed -i "s|server_name .*;|server_name ${DOMAIN_NAME};|" /etc/nginx/http.d/default.conf

# Puerto HTTPS expuesto por el servidor
EXPOSE 443

# Mantiene Nginx ejecutándose en primer plano
CMD ["nginx", "-g", "daemon off;"]
