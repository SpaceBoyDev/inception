# User documentation

## What the stack provides

This project provides a WordPress website with:

- **NGINX** as the HTTPS entrypoint and web server.
- **WordPress/PHP-FPM** as the application layer.
- **MariaDB** as the WordPress database.

The containers communicate on the private `inception-network`. The website files and database are stored persistently under `/home/$USER/data`.

## Requirements and first access

Install Docker Engine, Docker Compose v2, and `make`. Add the domain to the local hosts file if this is a local installation:

```text
127.0.0.1 darmarti.42.fr
```

Open:

```text
https://darmarti.42.fr
```

The administration panel is:

```text
https://darmarti.42.fr/wp-admin/
```

The first browser connection may require trusting the local `mkcert` CA. A certificate generated for another domain will not be valid for `darmarti.42.fr`.

## Start and stop

From the repository root:

```bash
make up
```

To stop and remove the project containers:

```bash
make down
```

To build images after changing a Dockerfile or configuration copied into an image:

```bash
make build
make up
```

To perform a complete reset:

```bash
make re
```

`make re` is destructive. It removes `/home/$USER/data`, including the MariaDB database and WordPress files.

## Credentials

The Compose project reads non-secret settings from `srcs/.env`. Passwords are stored in:

```text
secrets/db_password.txt
secrets/db_root_password.txt
```

These files are mounted inside the appropriate containers under `/run/secrets`. Do not put passwords in `srcs/.env`, Dockerfiles, screenshots, logs, or Git commits.

If a password is changed, recreate or reinitialize the affected service consistently. Existing MariaDB users keep their old password until it is changed in MariaDB or the database data is deliberately reinitialized.

## Check service health

List container status:

```bash
docker compose -f srcs/docker-compose.yml ps
```

View logs:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Check the database container:

```bash
docker exec mariadb mariadb-admin \
  --socket=/run/mysqld/mysqld.sock ping
```

Check that the WordPress files are visible to NGINX:

```bash
docker exec nginx test -r /var/www/html/index.php
```

A successful command returns exit status `0`. If the site returns `403`, inspect NGINX logs and check that `/home/$USER/data/wordpress` and its files are readable by the container's `www-data` user. If WordPress reports a database error, inspect both the WordPress and MariaDB logs without printing passwords.

## Data and backups

The persistent data is stored on the host in:

```text
/home/$USER/data/mariadb
/home/$USER/data/wordpress
```

Back up these directories only when the services are stopped or when using a database-aware backup procedure. Restoring a database directory must preserve ownership and permissions.

