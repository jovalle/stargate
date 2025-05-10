.PHONY: help confirm up start new stop restart logs status ps clean

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

install: ##@other Start and enable service
	@apt update
	@apt install -y curl
	@bash scripts/install-packages.sh
	@bash scripts/install-docker.sh
	@ln -sf stargate.service /etc/systemd/system/stargate.service
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

up: check ## Start all containers in foreground
	@sops --decrypt docker-compose.yaml | docker compose -f - up

start: ## Start all containers in background
	@sops --decrypt docker-compose.yaml | docker compose -f - up -d --remove-orphans

new: ## Start all containers anew
	@sops --decrypt docker-compose.yaml | docker compose -f - up -d --remove-orphans --force-recreate

stop: ## Stop all containers
	@sops --decrypt docker-compose.yaml | docker compose -f - stop

restart: ## Stop and start all containers in background
	@sops --decrypt docker-compose.yaml | docker compose -f - stop
	@sops --decrypt docker-compose.yaml | docker compose -f - up -d --remove-orphans

logs: ## Tail logs of all containers
	@sops --decrypt docker-compose.yaml | docker compose -f - logs -f

status: ## List all containers
	@sops --decrypt docker-compose.yaml | docker compose -f - ps

ps: status

clean: confirm ## Delete all containers
	@sops --decrypt docker-compose.yaml | docker compose -f - down -v
