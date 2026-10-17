FROM debian:bookworm

RUN apt-get update -y  && apt-get upgrade -y \
    && apt-get install -y wget

RUN wget https://wordpress.org/wordpress-7.1.3.tar.gz -P /var/www

# move to /var/www and unzip. Remove file
RUN cd /var/www && tar -xzf wordpress-7.1.3.tar.gz \
	&& rm wordpress-7.1.3.tar.gz

# Change owner to root recursively for everything inside
RUN chown -R root:root /var/www/wordpress

# ------------------------- PHP-FPM ----------------------------

# Install php, fpm and mysql client
RUN apt-get install -y \
	php8.2 \
	php-fpm \
	php-mysql

# Copy config from host to default PHP config file location
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# ---------------------- WORDPRESS CLI -------------------------

# Install CLI to manage wordpress from the terminal
# Set it to be executable
# Move it to the proper directory
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# ---------------------- MariaDB client ------------------------
# To chech if MariaDB is reachable (from the following script)
RUN apt-get install -y mariadb-client

# ---------------------- Initialization script

COPY tools/setupwp.sh .
RUN chmod +x ./setupwp.sh

# Document the port that will be used by WP
EXPOSE 9000

ENTRYPOINT ["./setupwp.sh"]

# ENTRYPOINT ["/usr/local/bin/setup_wordpress.sh"]
