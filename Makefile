COMPOSE_FILE = ./srcs/docker-compose.yml
DATA_DIR = /home/$(USER)/data

all: setup build up

$(DATA_DIR)/mariadb:
	mkdir -p $(DATA_DIR)/mariadb

$(DATA_DIR)/wordpress:
	mkdir -p $(DATA_DIR)/wordpress

setup:
	sudo mkdir -p $(DATA_DIR)/mariadb
	sudo mkdir -p $(DATA_DIR)/wordpress
	sudo chown -R 777 $(DATA_DIR)/mariadb
	sudo chown -R 777 $(DATA_DIR)/wordpress

build: $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build

stop:
	docker compose -f $(COMPOSE_FILE) stop

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
	docker compose -f $(COMPOSE_FILE) down -v
	docker system prune -af

fclean: clean
	@sudo rm -rf $(DATA_DIR)
	docker system prune -af
	docker volume prune -f

re: fclean all

.PHONY: all setup build stop up down clean fclean re