FROM debian:bookworm

# Install nginx and openssl
RUN apt-get update -y  && apt-get upgrade -y \
    && apt-get install -y nginx openssl \
    && rm -rf /var/lib/apt/lists/*

# Ensure nginx runs as www-data with correct UID
RUN usermod -u 33 www-data && groupmod -g 33 www-data

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes \
	-out /etc/nginx/ssl/cert.crt \
	-keyout /etc/nginx/ssl/certkey.key \
	-subj "/C=SP/ST=Mad/L=Mad/O=42/OU=42Mad/CN=${WP_URL}"

RUN mkdir -p /var/run/nginx

# Copy configuration files
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/generate_ssl.sh /usr/local/bin/

# Set permissions
RUN chmod +x /usr/local/bin/*.sh
RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

EXPOSE 443

CMD [ "nginx", "-g", "daemon off;" ]
# ENTRYPOINT ["/usr/local/bin/generate_ssl.sh"]
