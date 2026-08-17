{pkgs, config, ...}: {
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flake/dotfiles/.config/niri/config.kdl";
}
