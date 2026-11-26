# DEV_DOC.md — Developer documentation

## Set up the environment

### Prerequisites

Install Docker Engine, the Docker Compose v2 plugin, and GNU Make. The Makefile also uses `sudo`, `hostname`, `awk`, and `sed`.

Run commands from the repository root. Before starting the stack, provide:

- `srcs/.env` with the configuration variables listed below.
- Four password files in `secrets/`, referenced by `srcs/docker-compose.yml`:

  ```text
  db_root_password.txt
  db_password.txt
  wp_admin_password.txt
  wp_user_password.txt
  ```

Compose mounts these files into the relevant containers under `/run/secrets`. `.env` and `secrets/` are ignored by Git; do not commit real credentials.

`example_env.sh` deletes and recreates `srcs/.env`. `example_secrets.sh` writes placeholder passwords. Inspect these scripts before using them and replace all placeholders with secure values.

### Configuration

`srcs/.env` supplies non-secret values to Compose. The current configuration uses:

```text
DOMAIN_NAME
DATA_PATH
SQL_DATABASE
SQL_USER
SQL_HOST
WP_URL
WP_TITLE
WP_ADMIN_USER
WP_ADMIN_EMAIL
WP_USER
WP_USER_EMAIL
```

Set `DATA_PATH` to the host directory where persistent data should live. Keep it aligned with `DATA_DIR` in the Makefile, which is `/home/$USER/data`. The current local configuration uses `/home/darmarti/data`.

The Makefile also sets `DOMAIN_NAME` independently for its `/etc/hosts` update. If changing the domain, keep the Makefile value, `DOMAIN_NAME`, and `WP_URL` consistent.

## Build and launch

The default Makefile target performs setup, builds images, and starts the stack:

```bash
make
```

The targets can also be run separately:

```bash
make setup
make build
make up
```

- `setup` creates host data directories, sets their permissions to `777`, and replaces the domain entry in `/etc/hosts` with the first IP returned by `hostname -I`.
- `build` creates missing data directories and runs `docker compose build`.
- `up` runs `docker compose up -d`. It does not run setup or build first.

Equivalent Compose commands:

```bash
docker compose -f srcs/docker-compose.yml build
docker compose -f srcs/docker-compose.yml up -d
```

Compose defines three services: NGINX, WordPress/PHP-FPM, and MariaDB. They communicate over the `inception` bridge network. Only NGINX publishes a port to the host (`443`).

## Manage containers and volumes

Makefile lifecycle commands:

```bash
make up       # Start services
make stop     # Stop services, keep containers
make down     # Stop and remove containers and network
make build    # Build service images
```

Useful Compose commands:

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs --tail=100
docker compose -f srcs/docker-compose.yml restart nginx
docker compose -f srcs/docker-compose.yml exec wordpress sh
docker compose -f srcs/docker-compose.yml exec mariadb sh
docker volume ls
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```

`make clean` runs `docker compose down -v`, then `docker system prune -af`. This prune affects unused Docker resources across the host, not only this project. `make fclean` additionally removes host data directories. `make re` runs `fclean` before rebuilding, so it is destructive. Check the configured paths and back up data before using these targets.

## Data location and persistence

Compose declares two named volumes backed by host directories:

| Volume | Host path | Container path |
|---|---|---|
| `mariadb_data` | `${DATA_PATH}/mariadb` | `/var/lib/mysql` |
| `wordpress_data` | `${DATA_PATH}/wordpress` | `/var/www/html` |

Both WordPress and NGINX mount `wordpress_data`, so NGINX serves the files managed by WordPress. MariaDB uses the separate `mariadb_data` volume.

The data remains on the host when containers are stopped or recreated. `make down` does not request volume removal. `make clean` removes the Compose volume resources but does not explicitly delete the host directories. `make fclean` does delete host data: it removes `/home/$USER/data` and also contains hard-coded removal paths under `/home/darmarti/data/`.

