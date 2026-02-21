{
  description = "NixOS flake for my laptop";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?ref=25.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  nixConfig = {
    extra-substituters = [
      "https://vicinae.cachix.org"
      "https://attic.xuyh0120.win/lantian"
    ];
    extra-trusted-public-keys = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-cachyos-kernel,
      ...
    }@inputs:
    {
      nixosConfigurations.kronos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          inherit nix-cachyos-kernel;
        };
        modules = [
          ./nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.vikas = import ./home;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
}
