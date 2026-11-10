HOST ?= $(shell hostname)
FLAKE := $(CURDIR)

.PHONY: switch bootstrap home

# Rebuild this NixOS machine.
switch:
	sudo nixos-rebuild switch --flake $(FLAKE)#$(HOST)

# First run after a fresh NixOS install: make bootstrap HOST=home-laptop
bootstrap:
	cp /etc/nixos/hardware-configuration.nix machines/$(HOST)-hardware.nix
	git add machines/$(HOST)-hardware.nix
	sudo nixos-rebuild switch --flake $(FLAKE)#$(HOST)

# Non-NixOS Linux (home-manager only).
home:
	home-manager switch -b backup --flake $(FLAKE)#$(USER)
