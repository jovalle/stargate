.PHONY: help confirm up start stop restart logs status ps clean

include .env
export

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
ROOT_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
DOCKER_COMPOSE := docker-compose
DOCKER_COMPOSE_FILE := $(ROOT_DIR)/$(DOCKER_COMPOSE).yml

help: ##@other Show this help
	@perl -e '$(HELP_FMT)' $(MAKEFILE_LIST)

confirm: ##@other Prompt for confirmation
	@( read -p "$(RED)Are you sure? [y/N]$(RESET): " sure && case "$$sure" in [yY]) true;; *) false;; esac )

up: ## Start all containers in foreground
	@$(DOCKER_COMPOSE) $(EXTRA_ARGS) up

start: ## Start all containers in background
	@$(DOCKER_COMPOSE) $(EXTRA_ARGS) up -d

stop: ## Stop all containers
	@$(DOCKER_COMPOSE) $(EXTRA_ARGS) stop

restart: ## Stop and start all containers in background
	@$(DOCKER_COMPOSE) $(EXTRA_ARGS) stop
	@$(DOCKER_COMPOSE) $(EXTRA_ARGS) up -d

logs: ## Tail logs of all containers
	@$(DOCKER_COMPOSE) $(EXTRA_ARGS) logs -f

status: ## List all containers
	@$(DOCKER_COMPOSE) $(EXTRA_ARGS) ps

ps: status

clean: confirm ## Delete all containers
	@$(DOCKER_COMPOSE) $(EXTRA_ARGS) down
