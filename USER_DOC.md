# USER_DOC.md — User documentation

## Services provided

The project runs three services:

- **NGINX** receives website requests over HTTPS.
- **WordPress/PHP-FPM** runs the website.
- **MariaDB** stores the website's database.

NGINX is the only service exposed to the host, on port 443. The services communicate with each other over a private Docker network.

## Start and stop the project

You need Docker Engine, Docker Compose v2, GNU Make, the local `srcs/.env` file, and the password files listed under [Credentials](#credentials).

From the project directory, start the stack with:

```bash
make
```

This prepares the host directories and domain entry, builds the images, and starts the services. It may ask for your `sudo` password.

To stop services but keep their containers:

```bash
make stop
```

To stop and remove the project containers:

```bash
make down
```

To start the existing services again:

```bash
make up
```

Avoid `make clean`, `make fclean`, and `make re` unless you intend to clean Docker resources or delete stored website and database data.

## Access the website

The current site address is:

```text
https://darmarti.42.fr
```

The WordPress administration panel is:

```text
https://darmarti.42.fr/wp-admin/
```

The current domain is `darmarti.42.fr`. The `make` command adds it to the host's `/etc/hosts` file.

**A browser certificate warning is expected:** NGINX currently serves a self-signed certificate. The mkcert commands in the Makefile are commented out, and NGINX is not configured to use a mkcert certificate.

## Credentials

Password files are stored in the project's `secrets/` directory:

| File | Used for |
|---|---|
| `db_root_password.txt` | MariaDB root account |
| `db_password.txt` | WordPress's MariaDB account |
| `wp_admin_password.txt` | WordPress administrator account |
| `wp_user_password.txt` | Additional WordPress author account |

Set these passwords before the first start. Account names are configured in `srcs/.env` (`SQL_USER`, `WP_ADMIN_USER`, and `WP_USER`); MariaDB's root account is named `root`. Do not put passwords in `.env` or commit the files; Git ignores the `secrets/` directory. The `example_secrets.sh` script writes placeholder values, so replace them with your own secure passwords.

MariaDB saves account credentials in its persistent data directory during its first initialization. Changing a password file later does not automatically change an existing MariaDB account's password.

## Check that the services are running

Show service status:

```bash
docker compose -f srcs/docker-compose.yml ps
```

See recent logs for all three services:

```bash
docker compose -f srcs/docker-compose.yml logs --tail=50 nginx wordpress mariadb
```

Check NGINX's configuration:

```bash
docker compose -f srcs/docker-compose.yml exec nginx nginx -t
```

If a service is not running or the website does not load, review its logs for startup or connection errors.
