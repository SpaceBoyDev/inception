COMPOSE_FILE = ./srcs/docker-compose.yml
DATA_DIR = /home/$(USER)/data
DOMAIN_NAME = darmarti.42.fr
HOST_IP = $(shell hostname -I | awk '{print $$1}')

all: setup build up

$(DATA_DIR)/mariadb:
	mkdir -p $(DATA_DIR)/mariadb

$(DATA_DIR)/wordpress:
	mkdir -p $(DATA_DIR)/wordpress

setup:
	sudo mkdir -p $(DATA_DIR)/mariadb
	sudo mkdir -p $(DATA_DIR)/wordpress
	sudo chmod -R 777 $(DATA_DIR)/mariadb
	sudo chmod -R 777 $(DATA_DIR)/wordpress
	sudo sed -i '/[[:space:]]$(DOMAIN_NAME)\([[:space:]]\|$$\)/d' /etc/hosts
	echo "$(HOST_IP) $(DOMAIN_NAME)" | sudo tee -a /etc/hosts >/dev/null

build: $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build

stop:
	docker compose -f $(COMPOSE_FILE) stop

up:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

# cert:
# 	sudo apt-get update
# 	sudo apt-get install -y mkcert libnss3-tools
# 	mkcert -install
# 	mkcert \
# 		-cert-file $(DOMAIN_NAME).pem \
# 		-key-file $(DOMAIN_NAME)-key.pem \
# 		$(DOMAIN_NAME)
# 	chmod 644 $(DOMAIN_NAME).pem
# 	chmod 600 $(DOMAIN_NAME)-key.pem

clean:
	docker compose -f $(COMPOSE_FILE) down -v
	docker system prune -af

fclean: clean
	@sudo rm -rf $(DATA_DIR)
	docker volume prune -f
	sudo rm -rf /home/darmarti/data/wordpress /home/darmarti/data/mariadb

re: fclean all

.PHONY: all setup build stop up down cert clean fclean re