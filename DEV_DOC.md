# Developer documentation

## Architecture

The stack is defined in [`srcs/docker-compose.yml`](./srcs/docker-compose.yml) and contains three services:

| Service | Responsibility | Internal endpoint |
|---|---|---|
| `nginx` | TLS termination and reverse proxy | `443` from the host |
| `wordpress` | WordPress and PHP-FPM | `wordpress:9000` |
| `mariadb` | WordPress database | `mariadb:3306` |

All services use the `inception-network` bridge network. NGINX is the only public entrypoint. WordPress and MariaDB are not published to host ports.

## Prerequisites

Install:

- Docker Engine.
- Docker Compose v2.
- GNU Make.
- OpenSSL; `mkcert` is recommended for locally trusted development certificates.

The host must resolve the configured domain:

```text
127.0.0.1 darmarti.42.fr
```

The repository also expects certificate files at the paths mounted by Compose:

```text
darmarti.42.fr.pem
darmarti.42.fr-key.pem
```

## Configuration

### Environment configuration

Edit `srcs/.env` for non-secret values such as:

```text
DOMAIN_NAME=darmarti.42.fr
MYSQL_DATABASE=wordpress_db
MYSQL_USER=wp_user
```

Do not store passwords in `.env` for this project. Compose reads the secret files declared at the bottom of `srcs/docker-compose.yml`:

```yaml
secrets:
  db_root_password:
    file: ../secrets/db_root_password.txt
  db_password:
    file: ../secrets/db_password.txt
```

The resulting paths inside containers are `/run/secrets/db_root_password` and `/run/secrets/db_password`. The MariaDB and WordPress startup scripts explicitly read those files.

### Build contexts

Each service has an independent build context:

```text
srcs/requirements/mariadb/
srcs/requirements/nginx/
srcs/requirements/wordpress/
```

Configuration files are copied into the images by their Dockerfiles. After changing a Dockerfile or copied configuration, rebuild the affected service.

## Build and launch

From the repository root:

```bash
make build
make up
```

The `build` target first creates:

```text
/home/$USER/data/mariadb
/home/$USER/data/wordpress
```

Equivalent Compose commands:

```bash
docker compose -f srcs/docker-compose.yml build
docker compose -f srcs/docker-compose.yml up -d
```

For a clean rebuild:

```bash
make re
```

This runs the destructive `fclean` target, removes Docker resources, deletes `/home/$USER/data`, and rebuilds the stack. Never use it as a routine deployment command when data must be retained.

## Container and volume management

Useful commands:

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml restart wordpress
docker compose -f srcs/docker-compose.yml exec wordpress sh
docker compose -f srcs/docker-compose.yml exec mariadb sh
docker inspect mariadb
docker inspect wordpress
docker volume ls
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```

The Compose volume declarations map the persistent database and website storage to:

```text
/home/$USER/data/mariadb
/home/$USER/data/wordpress
```

The `mariadb` service mounts the first volume at `/var/lib/mysql`. Both `wordpress` and `nginx` mount the second at `/var/www/html`. Keep the two data directories separate.

## Service implementation

### MariaDB

`srcs/requirements/mariadb/tools/init_db.sh`:

1. Reads the root and application passwords from Docker secret files.
2. Initializes the data directory if it is empty.
3. Starts a temporary local MariaDB server.
4. Creates the database and application user.
5. Grants the application user access to the WordPress database.
6. Stops the temporary server and starts MariaDB in the foreground.

The data directory is persistent, so initialization logic is not equivalent to a migration system. Changes to credentials must account for users already stored in the existing database.

### WordPress

`srcs/requirements/wordpress/tools/setup_wordpress.sh` reads the database password secret, downloads WordPress when `wp-config.php` is absent, writes the database configuration, sets ownership and permissions, and starts PHP-FPM in the foreground.

The PHP-FPM pool listens on `wordpress:9000`. It does not expose a host port.

### NGINX

`srcs/requirements/nginx/conf/nginx.conf`:

- redirects HTTP to HTTPS;
- accepts TLS connections on port 443;
- serves `/var/www/html`;
- forwards PHP requests to `wordpress:9000`;
- enables TLS 1.2 and TLS 1.3.

`generate_ssl.sh` ensures the certificate paths exist, validates the NGINX configuration with `nginx -t`, and starts NGINX in the foreground. In the local setup, the certificate and key are mounted from the repository root.

## Troubleshooting

Check the full startup sequence:

```bash
docker compose -f srcs/docker-compose.yml ps
docker logs mariadb --tail 100
docker logs wordpress --tail 100
docker logs nginx --tail 100
```

For a database connection error, verify that:

1. `mariadb` is running and listening on the Compose network.
2. WordPress uses `DB_HOST=mariadb`.
3. `/run/secrets/db_password` exists in the WordPress container.
4. The MariaDB application user and password match the secret.
5. An old `wp-config.php` is not preserving an earlier password.

For a `403 Forbidden`, verify that both containers see the same `/var/www/html`, that `index.php` exists, and that the directories are traversable and files readable by NGINX's `www-data` user.

For port conflicts:

```bash
sudo ss -ltnp | grep -E ':80|:443'
docker ps --format 'table {{.Names}}\t{{.Ports}}'
```

Stop the conflicting service before starting NGINX. The project is designed to expose only the NGINX entrypoint to the host.

