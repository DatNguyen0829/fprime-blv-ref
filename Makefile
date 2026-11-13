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
	west packages pip --install
	cd $(PROJECT_ROOT)/lib/zephyr-workspace/
	west sdk install --toolchains arm-zephyr-eabi

.PHONY: build
.ONESHELL:
build: ## Generate and build the zephyr deployment
	@set -e
	@echo "Setting up development generation for fprime-blv-ref with zephyr..."
	fprime-util generate -DBOARD=rpi_pico2/rp2350a/m33 zephyr
	fprime-util build zephyr
	@echo "Successful build of Zephyr image"

.PHONY: gds
.ONESHELL:
gds: ## Give access to port and run fprime gds
	@set -e
	@echo "Giving access to blv port..."
	sudo chmod a+rw /dev/ttyACM0
	@echo "Read and Write access given"
	@echo "Running GDs..."
	fprime-gds   -n   --dictionary "$(PROJECT_ROOT)/build-artifacts/zephyr/fprime-zephyr-deployment/dict/ReferenceDeploymentTopologyDictionary.json"   --communication-selection uart   --uart-device /dev/ttyACM0   --uart-baud 115200   --framing-selection space-packet-space-data-link

