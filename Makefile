build:
	nix build .#darwinConfigurations.macbook.system \
	   --extra-experimental-features 'nix-command flakes'

	./result/sw/bin/darwin-rebuild switch --flake .#macbook
	./scripts/brew_no_quarantine.sh
