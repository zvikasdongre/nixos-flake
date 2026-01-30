{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.gh ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Vikas Dongre";
      user.email = "zvikasdongre@gmail.com";
      init.defaultBranch = "main";
    };
  };
}
