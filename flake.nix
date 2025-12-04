{
  description = "NixOS flake for my laptop";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?ref=25.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Wallpaper manager
    swww = {
      url = "github:LGFae/swww";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Launcher
    vicinae.url = "github:vicinaehq/vicinae";

    # Fabric
    fabric-widgets.url = "github:Fabric-Development/fabric";

  };

  nixConfig = {
    extra-substituters = [ "https://vicinae.cachix.org" ];
    extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./nixos/configuration.nix ];
      };
    };
}
