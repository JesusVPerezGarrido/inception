# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jeperez- <jeperez-@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/07/28 12:30:16 by jeperez-          #+#    #+#              #
#    Updated: 2025/07/28 16:11:18 by jeperez-         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Default target (runs 'build')
all: up

# Builds containers with proper directory permissions
build: hosts
	mkdir -p /home/jeperez-/data/mariadb /home/jeperez-/data/wordpress
	chmod -R 755 /home/jeperez-/data
	docker compose -f srcs/docker-compose.yml build

# Start containers previously built
up:
	docker compose -f srcs/docker-compose.yml up -d

# Ensure /etc/hosts contains the necessary domain mapping
hosts:
	@echo "Checking /etc/hosts for jeperez-.42.fr..."
	@if ! grep -q "127.0.0.1 jeperez-.42.fr" /etc/hosts; \
	then \
		echo "Adding 127.0.0.1 jeperez-.42.fr to /etc/hosts"; \
		echo "127.0.0.1 jeperez-.42.fr" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "127.0.0.1 jeperez-.42.fr already exists."; \
	fi

# Stop containers
down:
	docker compose -f srcs/docker-compose.yml down

# Full cleanup (containers, images, volumes)
clean: down
	-docker volume rm -f $(shell docker volume ls -q)
	docker system prune -af --volumes
	sudo rm -rf /home/jeperez-/data

# Rebuild from scratch
re: clean build

.PHONY: all build up down clean re hosts
