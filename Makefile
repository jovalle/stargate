.PHONY: help confirm up start stop restart logs status ps clean

# Copypasta from https://github.com/krom/docker-compose-makefile

#COLORS
GREEN  := $(shell tput -Txterm setaf 2)
RED    := $(shell tput -Txterm setaf 1)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
# A category can be added with @category
HELP_FMT = \
	%help; \
	while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
	print "usage: make [target]\n\n"; \
	for (sort keys %help) { \
	print "${WHITE}$$_:${RESET}\n"; \
	for (@{$$help{$$_}}) { \
	$$sep = " " x (32 - length $$_->[0]); \
	print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
	}; \
	print "\n"; }

#DEFAULT variables
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DOCKER_COMPOSE := docker compose
DOCKER_COMPOSE_FILE := $(ROOT_DIR)/docker-compose.yaml
SYSTEMD_UNIT := $(ROOT_DIR)/stargate.service
EXTRA_UP_ARGS := --remove-orphans

install: ##@other Start and enable service
	@apt update
	@apt install -y curl
	@curl -fsSL https://raw.githubusercontent.com/jovalle/mothership/main/scripts/install-packages.sh | sh
	@curl -fsSL https://raw.githubusercontent.com/jovalle/mothership/main/scripts/install-docker.sh | sh
	@ln -sf $(SYSTEMD_UNIT) /etc/systemd/system/stargate.service
	@systemctl daemon-reload
	@systemctl start stargate
	@systemctl enable stargate

uninstall: confirm ##@other Stop and disable service
	@systemctl stop stargate
	@systemctl disable stargate

help: ##@other Show this help
	@perl -e '$(HELP_FMT)' $(MAKEFILE_LIST)

confirm:
	@( read -p "$(RED)Are you sure? [y/N]$(RESET): " sure && case "$$sure" in [yY]) true;; *) false;; esac )

up: ## Start all containers in foreground
	@$(DOCKER_COMPOSE) up

start: ## Start all containers in background
	@$(DOCKER_COMPOSE) up -d $(EXTRA_UP_ARGS)

new: ## Start all containers anew
	@$(DOCKER_COMPOSE) up -d $(EXTRA_UP_ARGS) --force-recreate

stop: ## Stop all containers
	@$(DOCKER_COMPOSE) stop

restart: ## Stop and start all containers in background
	@$(DOCKER_COMPOSE) stop
	@$(DOCKER_COMPOSE) up -d $(EXTRA_UP_ARGS)

logs: ## Tail logs of all containers
	@$(DOCKER_COMPOSE) logs -f

status: ## List all containers
	@$(DOCKER_COMPOSE) ps

ps: status

clean: confirm ## Delete all containers
	@$(DOCKER_COMPOSE) down -v
