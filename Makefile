# Detect current hostname automatically
CURRENT_HOSTNAME := $(shell scutil --get ComputerName)

# Default target - builds for current machine
build:
	@echo "Building for current machine: $(CURRENT_HOSTNAME)"
	nix build .#darwinConfigurations.$(CURRENT_HOSTNAME).system \
	   --extra-experimental-features 'nix-command flakes'
	yes | sudo ./result/sw/bin/darwin-rebuild switch --flake .#$(CURRENT_HOSTNAME)
	./scripts/brew_no_quarantine.sh
