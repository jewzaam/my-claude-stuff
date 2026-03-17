.PHONY: install install-dev install-no-deps uninstall clean format lint typecheck test test-verbose coverage default check help reconcile

# Normalize HOME to forward slashes (no-op on Unix, fixes Windows backslashes)
HOME_DIR := $(subst \,/,$(HOME))

# Use shared ~/.venv/ap if it exists, otherwise local .venv
ifeq ($(OS),Windows_NT)
    VENV_DIR ?= $(if $(wildcard $(HOME_DIR)/.venv/ap/Scripts/python.exe),$(HOME_DIR)/.venv/ap,.venv)
    PYTHON := $(VENV_DIR)/Scripts/python.exe
else
    VENV_DIR ?= $(if $(wildcard $(HOME_DIR)/.venv/ap/bin/python),$(HOME_DIR)/.venv/ap,.venv)
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

reconcile:  ## Push claude/ config to ~/.claude/
	$(PYTHON) scripts/reconcile.py claude/ $(HOME)/.claude/

help:  ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
