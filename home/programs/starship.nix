{
  ...
}:
{
  programs.foot = {
    enable = true;

    settings = {
      main = {
        include = "~/.config/foot/themes/noctalia";
        font = "JetBrains Mono:size=11";
      };

      scrollback = {
        multiplier = "4.0";
      };
    };
  };
}
