#######################################################################
#                            Main targets                             #
#######################################################################

## Simple example tasks for Veracrypt

help:     ## Show this help.
	@egrep -h '(\s##\s|^##\s)' $(MAKEFILE_LIST) | egrep -v '^--' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m  %-35s\033[0m %s\n", $$1, $$2}'

build:   ## Build containers.
	@echo "${green}Create app${no_color}"
	docker compose build

up:   ## Start containers.
	@echo "${green}Start container${no_color}"
	docker compose up --detach

down:   ## Stop containers and discard them.
	@echo "${green}Stop container${no_color}"
	docker compose down

random_text:   ## Create random text
	@echo "${green}Random.txt${no_color}"
	docker compose run --rm --entrypoint=/bin/bash veracrypt -c "cat /dev/urandom | base64 | head -c 500"

status: ## Show current status.
	@docker compose ps --all | \
		sed "s/\b\(exited\)\b/${orange}\U\1\E${no_color}/gi" | \
		sed "s/\b\(up\)\b/${green}\U\1\E${no_color}/gi" | \
		sed "s/\b\(healthy\)\b/${green}\U\1\E${no_color}/gi" | \
		sed "s/\b\(unhealthy\)\b/${orange}\U\1\E${no_color}/gi" | tee /tmp/status
	@(grep -qi "UP" /tmp/status && echo "${green}UP!${no_color}") || echo "${red}DOWN!${no_color}"

shell: ## Start shell.
	@echo "${green}Start shell interactive console${no_color}"
	docker compose run -it --rm --entrypoint=/bin/bash veracrypt

logs: ## Show logs
	@echo "${green}Show logs${no_color}"
	docker compose logs --follow

images_backup: ## Save images to tar.gz.
	@echo "${green}Backup images${no_color}"
	@{\
		set -e;\
		for img in $$(docker compose config --images); do\
			images="$${images} $${img}";\
		done;\
		for service in $$(docker compose config --services); do\
			services="$${services}-$${service}";\
		done;\
		echo "  ${green}Found images: ${no_color}$${images}";\
		echo "  ${green}Backup..${no_color}";\
		docker save $${images} | gzip > images$${services}.tar.gz;\
		ls -lh images$${services}.tar.gz;\
		echo "  ${green}Done!${no_color}";\
	}

images_restore: ## Restore images from tar.gz.
	@echo "${green}Restore images${no_color}"
	@{\
		set -e;\
		for service in $$(docker compose config --services); do\
			services="$${services}-$${service}";\
		done;\
		ls -lh images$${services}.tar.gz;\
		docker image load -i images$${services}.tar.gz;\
		echo "  ${green}Done!${no_color}";\
	}

.PHONY: help backup shell root build

green=`tput setaf 2`
orange=`tput setaf 9`
red=`tput setaf 1`
no_color=`tput sgr0`
include .env
