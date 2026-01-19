# Detect current hostname automatically
CURRENT_HOSTNAME := $(shell scutil --get ComputerName)

# Default target - builds for current machine
build:
	@echo "Building for current machine: $(CURRENT_HOSTNAME)"
	nix build .#darwinConfigurations.$(CURRENT_HOSTNAME).system \
	   --extra-experimental-features 'nix-command flakes'
	sudo ./result/sw/bin/darwin-rebuild switch --flake .#$(CURRENT_HOSTNAME)
	./scripts/brew_no_quarantine.sh

# Optional: Explicit targets for each machine
build-macbook:
	@echo "Building for macbook"
	nix build .#darwinConfigurations.macbook.system \
	   --extra-experimental-features 'nix-command flakes'
	sudo ./result/sw/bin/darwin-rebuild switch --flake .#macbook
	./scripts/brew_no_quarantine.sh

build-macbook-pro-m5:
	@echo "Building for macbook-pro-m5"
	nix build .#darwinConfigurations.macbook-pro-m5.system \
	   --extra-experimental-features 'nix-command flakes'
	sudo ./result/sw/bin/darwin-rebuild switch --flake .#macbook-pro-m5
	./scripts/brew_no_quarantine.sh

# Helper target to show current hostname
show-hostname:
	@echo "Current hostname: $(CURRENT_HOSTNAME)"

# List all available machines
list-machines:
	@echo "Available machines:"
	@echo "  - macbook"
	@echo "  - macbook-pro-m5"
