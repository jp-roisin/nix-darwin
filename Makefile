# Detect current hostname automatically
CURRENT_HOSTNAME := $(shell scutil --get ComputerName)

# Default target - builds for current machine
build:
	@echo "Building for current machine: $(CURRENT_HOSTNAME)"
	nix build .#darwinConfigurations.$(CURRENT_HOSTNAME).system \
	   --extra-experimental-features 'nix-command flakes'
	yes | sudo ./result/sw/bin/darwin-rebuild switch --flake .#$(CURRENT_HOSTNAME)
	./scripts/brew_no_quarantine.sh

# Helper target to show current hostname
show-hostname:
	@echo "Current hostname: $(CURRENT_HOSTNAME)"

# List all available machines
list-machines:
	@echo "Available machines:"
	@echo "  - macbook"
	@echo "  - macbook-pro-m5"
