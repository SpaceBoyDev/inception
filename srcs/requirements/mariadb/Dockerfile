FROM debian:bookworm

# Install MariaDB
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 755 /var/run/mysqld

# Copy configuration
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY tools/init_db.sh .


# Set permissions
RUN chmod +x ./init_db.sh

EXPOSE 3306

ENTRYPOINT ["./init_db.sh"]