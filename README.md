*This project has been created as part of the 42 curriculum by darmarti.*

# Inception

## Description

Inception is a system-administration project built with Docker Compose. Its goal is to build and run a small web infrastructure by separating the web server, application, and database into containers. It deploys a WordPress website using three services:

- **NGINX**: the HTTPS entrypoint and reverse proxy.
- **WordPress with PHP-FPM**: the application service.
- **MariaDB**: the database service.

The services communicate over a private Docker bridge network. WordPress files and database files are stored in host-backed Docker volumes so they persist when containers are recreated.

The configured domain is `darmarti.42.fr`. NGINX publishes port 443. **The current NGINX image creates a self-signed OpenSSL certificate at build time. Browsers will warn that the connection is not trusted.**

## Project structure

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── example_env.sh
├── example_secrets.sh
├── secrets/                         # Local, ignored secret files
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env                         # Local, ignored configuration
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

## Project description

Docker Compose builds and runs a separate container for each service. The Compose file defines their network, published port, secrets, and persistent storage. The Makefile prepares the host, builds the images, and provides lifecycle commands.

The project sources are organized by service:

- `srcs/requirements/mariadb/` contains the MariaDB image definition and its database initialization entrypoint.
- `srcs/requirements/nginx/` contains the NGINX image definition and HTTPS/web-server configuration.
- `srcs/requirements/wordpress/` contains the PHP-FPM/WordPress image definition and its WordPress setup entrypoint.
- `srcs/docker-compose.yml` connects the services; `srcs/.env` supplies non-secret settings.

### Main design choices

#### Virtual machines vs Docker

A virtual machine runs a complete guest operating system with its own kernel, giving stronger operating-system isolation at higher resource and startup cost. Docker containers share the host kernel and isolate processes, so they are lighter and start faster, but do not provide a separate kernel. This project uses Docker to package and run each service independently.

#### Secrets vs environment variables

Environment variables are convenient for non-sensitive configuration, but values can be exposed through container inspection and process environments. Docker Compose secrets are mounted as files under `/run/secrets`, which is more appropriate for passwords. This project uses `.env` for settings and secret files for credentials; the source secret files still need to be protected on the host.

#### Docker network vs host network

A Docker bridge network provides private container-to-container connectivity and service-name DNS. Host networking shares the host's network namespace, reducing isolation and potentially causing port conflicts. This project uses a bridge network so WordPress can reach MariaDB at `mariadb` and NGINX can reach PHP-FPM at `wordpress:9000`; only NGINX publishes a host port.

#### Docker volumes vs bind mounts

Docker-managed named volumes are convenient for persistent data, while bind mounts expose a specific host path and make its location and permissions directly manageable. This project declares named volumes but configures the local volume driver with host paths under `DATA_PATH`. That keeps data in known host directories while mounting it into the containers.

## Instructions

### Prerequisites

- Linux with Docker Engine and the Docker Compose v2 plugin.
- GNU Make and `sudo` access.
- A local `srcs/.env` file and the four secret files listed above. These files are not tracked by Git.

The Compose configuration reads `DOMAIN_NAME`, `DATA_PATH`, database and WordPress settings from `srcs/.env`. The Makefile separately uses `/home/$USER/data` for host data directories. Keep that path consistent with `DATA_PATH`; the current local configuration uses `/home/darmarti/data`.

The `example_env.sh` helper removes and recreates `srcs/.env`. The `example_secrets.sh` helper writes placeholder passwords. Review these scripts before using them, and replace placeholders with secure values.

### Build and run

From the repository root:

```bash
make
```

The default target runs `setup`, `build`, and `up` in that order. `setup` creates the host data directories, sets their permissions, and replaces the domain's `/etc/hosts` entry with the first IP reported by `hostname -I`. `build` builds the service images; `up` starts the containers in detached mode.

The website is intended to be available at:

```text
https://darmarti.42.fr
```

The actual domain and WordPress URL are configured in `srcs/.env`. The WordPress administration page is at `/wp-admin/`.

### Lifecycle commands

```bash
make build    # Create data directories if needed and build images
make up       # Start the Compose services
make stop     # Stop running containers without removing them
make down     # Stop and remove project containers and network
make clean    # Run Compose down -v, then prune unused Docker resources
make fclean   # Clean Docker resources and delete host data directories
make re       # Run fclean, then rebuild and start everything
```

`make clean`, `make fclean`, and `make re` need care: `clean` removes Compose volumes and globally prunes unused Docker resources; `fclean` also deletes host data directories, including the MariaDB database and WordPress files. `re` invokes this destructive cleanup before starting again.

## Current TLS behavior

The NGINX Dockerfile generates a self-signed certificate with OpenSSL. It is not signed by a certificate authority trusted by your browser, so the warning is expected. The NGINX configuration listens on HTTPS port 443 only; it does not configure an HTTP-to-HTTPS redirect.

`mkcert` can issue a locally trusted certificate for development, but generating one alone is not enough: NGINX must be configured to use that certificate and key, and the mkcert root CA must be trusted by each client device/browser. That integration is not present in the current project state.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/reference/compose-file/)
- [Docker build best practices](https://docs.docker.com/build/building/best-practices/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress documentation](https://wordpress.org/documentation/)
- [mkcert](https://github.com/FiloSottile/mkcert)

### Use of AI

AI was used to help explain and document the Docker and Compose design, review the Makefile and service configuration, and troubleshoot startup, networking, secrets, and TLS behavior. It also assisted in drafting the project documentation, including the architecture and setup instructions. The relevant project areas were `Makefile`, `srcs/docker-compose.yml`, and the service sources under `srcs/requirements/`.
