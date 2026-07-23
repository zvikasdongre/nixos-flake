{ pkgs, config, ... }:

{
  imports = [
    ./programs
    ./services
  ];

  home.username = "vikas";
  home.homeDirectory = "/home/vikas";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
  ];

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  gtk = {
    enable = true;

    gtk4.theme = config.gtk.theme;

    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };

    iconTheme = {
      name = "WhiteSur-dark";
    };

    font = {
      name = "Ubuntu Sans";
      size = 11;
    };
  };

  home.stateVersion = "25.11";
}
