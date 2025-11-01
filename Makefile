.PHONY: help template clean setup-hooks

# Default target
help:
	@echo "Available targets:"
	@echo "  template            Generate all configuration files from templates"
	@echo "  clean               Remove generated configuration files"
	@echo "  setup               Install pre-commit git hooks"
	@echo "  help                Show this help message"

# Generate all configuration files from templates
template:
	@echo "Generating all configuration files from templates..."
	@set -a; [ -f .env ] && . ./.env; \
	export DOMAIN_ESCAPED=$$(echo "$$DOMAIN" | sed 's/\./\\\\./g'); \
	set +a; \
	for template in $$(find docker/ -name "*.template" -type f); do \
		output=$$(echo $$template | sed 's/\.template$$//'); \
		echo "  $$template -> $$output"; \
		temp_file=$$(mktemp); \
		vars_in_template=$$(grep -o '\$$[{][A-Z_][A-Z0-9_]*[}]' "$$template" 2>/dev/null || true); \
		if ! envsubst < "$$template" > "$$temp_file" 2>/dev/null; then \
			echo "ERROR: envsubst failed for $$template"; \
			rm -f "$$temp_file"; \
			exit 1; \
		fi; \
		if [ -n "$$vars_in_template" ]; then \
			for var in $$vars_in_template; do \
				var_name=$$(echo "$$var" | sed 's/\$$[{]\([^}]*\)[}]/\1/'); \
				eval "var_value=\$$$$var_name"; \
				if [ -z "$$var_value" ]; then \
					echo "ERROR: Variable $$var is not set in $$output"; \
					rm -f "$$temp_file"; \
					exit 1; \
				fi; \
			done; \
		fi; \
		mv "$$temp_file" "$$output"; \
	done
	@echo "All templates generated successfully"

# Clean generated files
clean:
	@echo "This will remove all generated configuration files:"
	@find docker/ -name "*.template" -type f | sed 's/\.template$$//' | sed 's/^/  - /'
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo "Cleaning generated configuration files..."
	@find docker/ -name "*.template" -type f | sed 's/\.template$$//' | xargs rm -f
	@echo "Clean complete"

# Setup pre-commit hooks
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
