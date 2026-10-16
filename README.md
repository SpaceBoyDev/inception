*This project has been created as part of the 42 curriculum by darmarti.*

# Inception

## Description

Inception is a system-administration project built with Docker Compose. It deploys a small WordPress infrastructure composed of three containers:

- **NGINX**: the TLS-enabled public entrypoint and reverse proxy.
- **WordPress with PHP-FPM**: the application container that serves the WordPress PHP code.
- **MariaDB**: the database server used by WordPress.

The services communicate through a private Docker bridge network. WordPress files and the MariaDB database are persisted outside the containers so that recreating containers does not remove application data.

The project domain is `darmarti.42.fr`. HTTPS is served by NGINX on port 443. The current development setup uses a locally trusted `mkcert` certificate; the root CA must be trusted on each client that accesses the site.

### Project structure

```text
.
├── Makefile
├── secrets/
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

## Instructions

### Prerequisites

- Linux with Docker Engine and Docker Compose v2.
- `make`.
- A local DNS/hosts entry for the domain:

  ```text
  127.0.0.1 darmarti.42.fr
  ```

- A certificate and key for `darmarti.42.fr` mounted at the paths configured in `srcs/docker-compose.yml`.

For local HTTPS without a browser warning, install and use `mkcert`:

```bash
mkcert -install
mkcert -cert-file darmarti.42.fr.pem \
  -key-file darmarti.42.fr-key.pem darmarti.42.fr
```

### Build and run

From the repository root:

```bash
make
```

This creates the host data directories, builds the three images, and starts the services in detached mode. The website is then available at:

```text
https://darmarti.42.fr
```

The WordPress administration panel is available at:

```text
https://darmarti.42.fr/wp-admin/
```

Useful lifecycle commands:

```bash
make up       # Start the stack
make down     # Stop and remove the project containers
make build    # Build the images
make clean    # Stop containers and prune unused Docker resources
make fclean   # Clean Docker resources and remove /home/$USER/data
make re       # Destructive clean followed by a complete rebuild
```

`make fclean` and `make re` delete the persistent host data and therefore delete the database and WordPress files. Do not use them when data must be preserved.

## Technical design

### Docker versus virtual machines

A virtual machine runs a complete guest operating system with its own kernel, which provides strong isolation but requires more memory and storage. Docker containers share the host kernel and isolate processes using namespaces and control groups. Containers start faster and use fewer resources, while a VM can isolate different kernels and operating-system environments more strongly.

This project uses containers because each service has one focused responsibility and can be built, started, stopped, and replaced independently.

### Secrets versus environment variables

Environment variables are useful for non-sensitive configuration such as the domain name, database name, and database user. They are not ideal for passwords because they can be exposed through container inspection, process information, logs, and inherited child processes.

Docker secrets are mounted as files under `/run/secrets`. This project uses secrets for the MariaDB root password and WordPress database password, while `.env` stores non-secret configuration. Secret files must remain local and must never be committed to a public repository.

### Docker network versus host network

A Docker bridge network gives containers private connectivity and service-name DNS, so WordPress can reach MariaDB at `mariadb` and NGINX can reach PHP-FPM at `wordpress:9000`. Only explicitly published ports are reachable from the host.

Host networking removes this network isolation and makes the container share the host network namespace. It can simplify networking, but increases coupling and causes port conflicts. This project uses a dedicated bridge network.

### Docker volumes versus bind mounts

A Docker named volume is managed by Docker and is normally stored below `/var/lib/docker/volumes`. A bind mount maps an explicit host path and gives direct control over its location and permissions.

The Compose file declares named volumes for the two persistent resources and configures their host-backed locations under `/home/$USER/data`, which makes the data easy to inspect and preserve for this 42 exercise. Both services that need WordPress files mount `wordpress_data`; only MariaDB mounts `mariadb_data`.

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

AI was used as a support tool to clarify Docker and Compose concepts, troubleshoot service startup and networking issues, explain secret-file handling, and structure this documentation. All generated explanations and suggested configuration changes must be checked against the project files, Docker documentation, and the 42 subject before use.

