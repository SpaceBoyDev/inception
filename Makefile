COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/$(USER)/data

all: build up

$(DATA_DIR)/mariadb:
	mkdir -p $(DATA_DIR)/mariadb

$(DATA_DIR)/wordpress:
	mkdir -p $(DATA_DIR)/wordpress

build: $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build

up:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

cert:
	mkcert -install
	mkcert \
  		-cert-file darmarti.42.fr.pem \
  		-key-file darmarti.42.fr-key.pem \
  		darmarti.42.fr
	chmod 644 darmarti.42.fr.pem
	chmod 600 darmarti.42.fr-key.pem

clean:
	docker compose -f $(COMPOSE_FILE) down
	docker system prune -af

fclean: clean
	docker volume prune -f
	sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all build up down clean fclean re