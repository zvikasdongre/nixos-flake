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

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = ["https://vicinae.cachix.org"];
    extra-trusted-public-keys = ["vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="];
  };

  outputs = {
    self,
    nixpkgs,
    nvf,
    ...
  } @ inputs: {
    nixosConfigurations.kronos = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        nvf.nixosModules.default
        ./nixos/configuration.nix
      ];
    };
  };
}
