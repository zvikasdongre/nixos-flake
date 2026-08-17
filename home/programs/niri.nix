{pkgs, config, ...}: {
  wayland.windowManager.niri.enable = true;

  wayland.windowManager.niri.settings = {

  };

  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flake/dotfiles/niri/config.kdl";
}
