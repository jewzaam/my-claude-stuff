.PHONY: install install-dev install-no-deps uninstall clean format format-check lint typecheck test test-verbose coverage default check help migrate reconcile memory-pull memory-push memory-diff

VENV_DIR ?= .venv
DATA_DIR := $(HOME)/.claude/my-claude-stuff-data
ifeq ($(OS),Windows_NT)
    PYTHON := $(VENV_DIR)/Scripts/python.exe
else
    PYTHON := $(VENV_DIR)/bin/python
endif

$(info venv: $(VENV_DIR))

default: format lint typecheck test coverage  ## Run all checks (format, lint, typecheck, test, coverage)

check: default  ## Alias for default

$(PYTHON):
	python3 -m venv $(VENV_DIR)

install: $(PYTHON)  ## Install package
	$(PYTHON) -m pip install .

install-dev: $(PYTHON)  ## Install in editable mode with dev deps
	$(PYTHON) -m pip install -e ".[dev]"

install-no-deps: $(PYTHON)  ## Install in editable mode without dependencies
	$(PYTHON) -m pip install -e . --no-deps

uninstall:  ## Uninstall package
	$(PYTHON) -m pip uninstall -y my-claude-stuff

clean:  ## Remove build artifacts
	rm -rf build/ dist/ *.egg-info
	find . -type d -name __pycache__ -exec rm -r {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true

format: install-dev  ## Format code with black and JSON files
	$(PYTHON) -m black scripts tests
	jq -S 'walk(if type == "array" then sort else . end)' claude/settings.json > claude/settings.json.tmp && mv claude/settings.json.tmp claude/settings.json

format-check: install-dev  ## Check formatting without modifying files
	$(PYTHON) -m black --check scripts tests

lint: install-dev  ## Lint with flake8
	$(PYTHON) -m flake8 --max-line-length=88 --extend-ignore=E203,W503 scripts tests

typecheck: install-dev  ## Type check with mypy
	$(PYTHON) -m mypy scripts

test: install-dev  ## Run pytest
	$(PYTHON) -m pytest

test-verbose: install-dev  ## Run pytest with verbose output
	$(PYTHON) -m pytest -v

coverage: install-dev  ## Run pytest with coverage
	$(PYTHON) -m pytest --cov=scripts --cov-report=term

migrate:  ## Merge legacy data dirs into my-claude-stuff-data/
	@mkdir -p $(DATA_DIR)
	@for dir in session-tracker prompt-log statusline-cache; do \
		if [ -d "$(HOME)/.claude/$$dir" ]; then \
			echo "Migrating $$dir -> $(DATA_DIR)/$$dir"; \
			cp -rn "$(HOME)/.claude/$$dir/." "$(DATA_DIR)/$$dir/" 2>/dev/null || \
			cp -r --no-clobber "$(HOME)/.claude/$$dir/." "$(DATA_DIR)/$$dir/" 2>/dev/null || \
			cp -r "$(HOME)/.claude/$$dir/." "$(DATA_DIR)/$$dir/"; \
			rm -rf "$(HOME)/.claude/$$dir"; \
		fi; \
	done

reconcile: migrate  ## Push claude/ config to ~/.claude/
	$(PYTHON) scripts/reconcile.py claude/ $(HOME)/.claude/

memory-diff:  ## Show differences between repo and live memory
	@$(PYTHON) scripts/memory_sync.py diff

memory-pull:  ## Pull ~/.claude/memory/ into claude/memory/
	@$(PYTHON) scripts/memory_sync.py pull

memory-push:  ## Push claude/memory/ to ~/.claude/memory/
	@$(PYTHON) scripts/memory_sync.py push

help:  ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
