{
  config,
  ...
}:
{
  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        "Phone" = {
          id = "MSSR2JQ-I7R4NLL-LZFXP2X-Y2D7O3M-DMUB4NI-KUHRF6C-BWJVKZE-HJSZEAA";
        };
      };

      folders = {
        "ObsidianVault" = {
          path = "${config.home.homeDirectory}/ObsidianVault";
          devices = [ "Phone" ];
        };
      };
    };
  };

}
