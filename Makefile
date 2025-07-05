# please change 'hostname' to your hostname
deploy:
	nix build .#darwinConfigurations.macbook.system \
	   --extra-experimental-features 'nix-command flakes'

	./result/sw/bin/darwin-rebuild switch --flake .#macbook
