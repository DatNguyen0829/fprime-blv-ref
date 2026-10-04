PYTHON_VERSION = 3.12
PROJECT_ROOT = $(CURDIR)

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; 
				 printf "\nUsage:\n  
				 make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ 
				 { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ 
				 { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: setup
.ONESHELL:
setup: ## Set up the repo
	@set -e
	@echo "Setting up development environment for fprime-blv-ref with zephyr..."
	git checkout main
	@echo "Making the fprime virtual environment..."
	python$(PYTHON_VERSION) -m venv fprime-venv
	@echo "Sourcing fprime virtual environment..."
	. fprime-venv/bin/activate
	@echo "Initializing and updating all git submodules recursively..."
	git submodule update --init --recursive
	@echo "Installing Python requirements into venv..."
	fprime-venv/bin/pip install pip
	fprime-venv/bin/pip install --upgrade pip
	fprime-venv/bin/pip install -r requirements.txt
	fprime-venv/bin/pip install "cmake>=3.28,<4"
	hash -r
	@echo "Showing west workspace info..."
	west topdir
	west config manifest.path
	west config manifest.file
	west config zephyr.base
	@echo "Updating west manifest into zephyr-workspace..."
	west update
