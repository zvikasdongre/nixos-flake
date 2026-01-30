{ pkgs, ... }:

{
  imports = [
    ./programs
    ./services
  ];

  home.username = "vikas";
  home.homeDirectory = "/home/vikas";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    eza
  ];

  home.stateVersion = "25.11";
}
