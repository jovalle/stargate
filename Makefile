.PHONY: help template clean setup start stop restart logs ps submodules env-example

# Default target
help:
	@echo "Available targets:"
	@echo "  submodules          Initialize and update git submodules"
	@echo "  template            Generate all configuration files from templates"
	@echo "  env-example         Sync .env.example with .env (preserves existing values)"
	@echo "  clean               Remove generated configuration files"
	@echo "  setup               Install pre-commit git hooks"
	@echo ""
	@echo "Container Management:"
	@echo "  start [SERVICE]     Start all containers or specific container(s)"
	@echo "  stop [SERVICE]      Stop all containers or specific container(s)"
	@echo "  restart [SERVICE]   Restart all containers or specific container(s)"
	@echo "  logs [SERVICE]      Follow logs for all or specific container(s)"
	@echo "  ps                  Show running containers status"
	@echo ""
	@echo "  help                Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make start                    # Start all containers"
	@echo "  make start SERVICE=traefik    # Start traefik container"
	@echo "  make stop SERVICE=adguard     # Stop adguard container"
	@echo "  make logs SERVICE=gatus       # Follow logs for gatus"

# Initialize and update git submodules
submodules:
	@git submodule update --init --recursive

# Generate all configuration files from templates
templates: template
template: submodules
	@echo "Generating all configuration files from templates..."
	@set -a; [ -f .env ] && . ./.env; \
	export DOMAIN_ESCAPED=$$(echo "$$DOMAIN" | sed 's/\./\\\\./g'); \
	set +a; \
	rendered=0; \
	skipped=0; \
	for template in $$(find docker/ -type f -name "*.template" 2>/dev/null); do \
		skip=false; \
		template_dir=$$(dirname "$$template"); \
		while IFS= read -r pattern; do \
			[ -z "$$pattern" ] && continue; \
			echo "$$pattern" | grep -q '^#' && continue; \
			case "$$pattern" in \
				*/) if echo "$$template_dir/" | grep -qF "$$pattern"; then skip=true; break; fi ;; \
				*) if echo "$$template_dir" | grep -qF "$$pattern"; then skip=true; break; fi ;; \
			esac; \
		done < .gitignore; \
		$$skip && continue; \
		output=$$(echo $$template | sed 's/\.template$$//'); \
		printf "  ⟳ %-70s" "$$template"; \
		temp_file=$$(mktemp); \
		error_msg=""; \
		vars_in_template=$$(grep -o '\$$[{][A-Z_][A-Z0-9_]*[}]' "$$template" 2>/dev/null || true); \
		if ! envsubst < "$$template" > "$$temp_file" 2>/dev/null; then \
			error_msg="envsubst failed"; \
		fi; \
		if [ -z "$$error_msg" ] && [ -n "$$vars_in_template" ]; then \
			for var in $$vars_in_template; do \
				var_name=$$(echo "$$var" | sed 's/\$$[{]\([^}]*\)[}]/\1/'); \
				eval "var_value=\$$$$var_name"; \
				if [ -z "$$var_value" ]; then \
					error_msg="Variable $$var is not set"; \
					break; \
				fi; \
			done; \
		fi; \
		if [ -n "$$error_msg" ]; then \
			printf "\r  ✗ %-70s\n" "$$template"; \
			echo "    ERROR: $$error_msg"; \
			rm -f "$$temp_file"; \
			exit 1; \
		fi; \
		mv "$$temp_file" "$$output"; \
		chmod 644 "$$output"; \
		printf "\r  ✓ %-70s\n" "$$template"; \
		rendered=$$((rendered + 1)); \
	done; \
	echo ""; \
	[ $$skipped -gt 0 ] && echo "⊘ Skipped $$skipped gitignored output(s)"; \
	echo "All templates ($$rendered) generated successfully"

# Sync .env.example with .env (copies structure, preserves existing example values)
env-example:
	@if [ ! -f .env ]; then \
		echo "ERROR: .env file not found"; \
		exit 1; \
	fi
	@echo "Syncing .env.example with .env..."
	@awk ' \
		NR == FNR { \
			if (/^[A-Z_][A-Z0-9_]*=/) { \
				key = $$0; sub(/=.*/, "", key); \
				val = $$0; sub(/^[^=]*=/, "", val); \
				if (val != "") existing[key] = val; \
			} \
			next; \
		} \
		{ \
			if (/^[A-Z_][A-Z0-9_]*=/) { \
				key = $$0; sub(/=.*/, "", key); \
				if (key in existing) { \
					print key "=" existing[key]; \
				} else { \
					print key "="; \
				} \
			} else { \
				print; \
			} \
		} \
	' .env.example .env > .env.example.tmp && \mv .env.example.tmp .env.example
	@echo ".env.example synced"

# Clean generated files
cleanup: clean
clean:
	@echo "This will remove all generated configuration files:"
	@find docker/ -name "*.template" -type f | sed 's/\.template$$//' | sed 's/^/  - /'
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo "Cleaning generated configuration files..."
	@find docker/ -name "*.template" -type f | sed 's/\.template$$//' | xargs rm -f
	@echo "Clean complete"

# Setup pre-commit hooks
init: setup
setup:
	@echo "Setting up pre-commit git hooks..."
	@if ! command -v pre-commit >/dev/null 2>&1; then \
		echo "ERROR: pre-commit is not installed"; \
		echo "Install it with: pip install pre-commit"; \
		echo "               or: brew install pre-commit"; \
		exit 1; \
	fi
	@pre-commit install
	@pre-commit install --hook-type commit-msg
	@echo "Pre-commit hooks installed successfully"
	@echo "Hooks will run automatically on git commit"

# Start containers
start: template
ifdef SERVICE
	@echo "Starting container(s): $(SERVICE)..."
	@docker compose up -d $(SERVICE)
	@echo "Container(s) started successfully"
else
	@echo "Starting all containers..."
	@docker compose up -d --remove-orphans
	@echo "All containers started successfully"
endif

# Stop containers
stop:
ifdef SERVICE
	@echo "Stopping container(s): $(SERVICE)..."
	@docker compose stop $(SERVICE)
	@echo "Container(s) stopped successfully"
else
	@echo "Stopping all containers..."
	@docker compose stop
	@echo "All containers stopped successfully"
endif

# Restart containers
restart:
ifdef SERVICE
	@echo "Restarting container(s): $(SERVICE)..."
	@docker compose restart $(SERVICE)
	@echo "Container(s) restarted successfully"
else
	@echo "Restarting all containers..."
	@docker compose restart
	@echo "All containers restarted successfully"
endif

# Follow logs
logs:
ifdef SERVICE
	@echo "Following logs for: $(SERVICE)..."
	@docker compose logs -f --tail=100 $(SERVICE)
else
	@echo "Following logs for all containers..."
	@docker compose logs -f --tail=100
endif

# Show container status
ps:
	@docker compose ps
