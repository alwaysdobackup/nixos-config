{
  description = "NixOS: niri + quickshell, systemd-networkd/resolved, nvidia-open";

  inputs = {
    # unstable tracks new packages (niri, quickshell) faster than a stable release branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
        url = "github:sodiboo/niri-flake";
    };

    nix-flatpak = {
	    url = "github:gmodena/nix-flatpak";
    };

    # optional: structured, Nix-native neovim config instead of a plain init.lua
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # quickshell has no NixOS/home-manager module (yet) -- we just take its package
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
	self, 
	nixpkgs, 
	disko,
    sops-nix,
	home-manager, 
    niri,
	nix-flatpak,
	nixvim, 
	quickshell, 
	... 
  }@inputs:
    let
      system = "x86_64-linux";

      # ---- EDIT THESE TWO -----------------------------------------------
      hostname = "workstation";   # must match networking.hostName in configuration.nix
      username = "qwerty";     # must match users.users.<name> in configuration.nix
      # ---------------------------------------------------------------------
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          disko.nixosModules.disko
          ./hosts/${hostname}/disko.nix

          sops-nix.nixosModules.sops

          ./hosts/${hostname}/configuration.nix
          ./hosts/${hostname}/hardware-configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs username; };

            home-manager.users.${username} = {
                imports = [
                    niri.homeModules.config
                    ./home/${username}/home.nix
                ];
            };

    	    home-manager.sharedModules = [
              nix-flatpak.homeManagerModules.nix-flatpak
            ];
          }
        ];
      };
    };
}


