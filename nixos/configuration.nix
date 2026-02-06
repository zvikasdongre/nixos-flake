{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  wallpaper = pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/je/wallhaven-jeej1q.jpg";
    hash = "sha256-ez3QBbOkRApfrAHc0K622l5rdwWViUhIbUksw0ziZiU=";
  };

  system = pkgs.stdenv.hostPlatform.system;

  sddm-theme = inputs.silentSDDM.packages.${system}.default.override {
    theme = "silvia";

    extraBackgrounds = [ wallpaper ];
    theme-overrides = {
      # Available options: https://github.com/uiriansan/SilentSDDM/wiki/Options
      "LoginScreen" = {
        background = "${wallpaper.name}";
      };
      "LockScreen" = {
        background = "${wallpaper.name}";
      };
    };
  };

  custom-whitesur-icon-theme = pkgs.whitesur-icon-theme.override {
    alternativeIcons = true;
  };

in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader = {
    timeout = 10;

    efi = {
      efiSysMountPoint = "/boot/efi";
      canTouchEfiVariables = true;
    };

    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = false; # Otherwise /boot/EFI/BOOT/BOOTX64.EFI isn't generated
      devices = [ "nodev" ];
      useOSProber = false;
      extraEntriesBeforeNixOS = true;

      extraEntries = ''
        menuentry "Linux Mint 22.2 Zara" --class linuxmint --class gnu-linux --class gnu --class os {
          insmod part_gpt
          insmod ext2

          search --no-floppy --fs-uuid --set=root ecbee46f-8de4-42a1-8129-f027a44ce230

          linux /boot/vmlinuz \
            root=UUID=ecbee46f-8de4-42a1-8129-f027a44ce230 \
            ro quiet splash

          initrd /boot/initrd.img
        }
      '';
    };
  };

  networking.hostName = "kronos";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;

  time.timeZone = "Asia/Kolkata";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  services.xserver.enable = false;

  # Enable Android UDEV rules
  services.udev.enable = true;

  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Enable SDDM.
  services.displayManager.sddm = {
    package = pkgs.kdePackages.sddm;

    enable = true;
    wayland.enable = true;
    enableHidpi = true;

    theme = sddm-theme.pname;
    extraPackages = sddm-theme.propagatedBuildInputs;

    settings = {
      General = {
        GreeterEnvironment = lib.concatStringsSep "," [
          "QT_QPA_PLATFORM=wayland"
          "QT_WAYLAND_FORCE_DPI=192"
          "QT_SCALE_FACTOR=1"
          "QT_AUTO_SCREEN_SCALE_FACTOR=0"
          "QT_SCREEN_SCALE_FACTORS=2"
          "QT_FONT_DPI=192"
          "QML2_IMPORT_PATH=${sddm-theme}/share/sddm/themes/${sddm-theme.pname}/components/"
          "QT_IM_MODULE=qtvirtualkeyboard"
        ];
        InputMethod = "qtvirtualkeyboard";
      };

      Theme = {
        CursorTheme = "Bibata-Modern-Classic";
        CursorSize = 24;
      };
    };
  };

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.upower.enable = true;
  services.tuned.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  services = {
    hypridle.enable = true;
  };

  systemd.tmpfiles.rules =
    let
      user = "vikas";
      iconPath = "${config.users.users.vikas.home}/.face.icon";
    in
    [
      "f+ /var/lib/AccountsService/users/${user}  0600 root root -  [User]\\nIcon=/var/lib/AccountsService/icons/${user}\\n"
      "L+ /var/lib/AccountsService/icons/${user}  -    -    -    -  ${iconPath}"
    ];

  users.users.vikas = {
    isNormalUser = true;
    description = "Vikas Dongre";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = [ ];
  };

  # Install firefox.
  programs.firefox.enable = true;
  programs.chromium.enable = true;

  # Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  programs.hyprlock.enable = true;
  programs.seahorse.enable = true;

  programs.fuse = {
    enable = true;
    userAllowOther = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  xdg = {
    mime.enable = true;
    portal.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Essentials / Utilities
    wget
    jq
    gnome-keyring
    libsecret
    brightnessctl
    dunst
    libnotify
    hyprpolkitagent
    xstow
    efibootmgr
    nixfmt
    matugen
    gnome-bluetooth
    adw-gtk3
    usbutils
    libmtp
    glib
    jmtpfs
    wev
    wlsunset
    pywalfox-native
    python314
    nil
    nixd

    # Power management
    lm_sensors
    powertop

    # Fonts
    jetbrains-mono
    ubuntu-sans
    noto-fonts
    material-symbols

    # Common Programs
    vscode
    nemo-with-extensions
    fastfetch
    ghostty
    gh
    cava
    starship
    stow
    atuin
    btop
    pix
    obsidian
    zed-editor
    vlc
    mpv
    smassh
    chromium
    imagemagick

    # launcher
    inputs.vicinae.packages.${system}.default

    # screenshot utilities
    grimblast
    grim
    slurp
    hyprpicker
    wl-clipboard

    # quickshell
    quickshell
    kdePackages.qtsvg
    kdePackages.qt5compat
    kdePackages.qtimageformats
    kdePackages.qtmultimedia
    kdePackages.qtvirtualkeyboard

    # themes & theming utilities
    mint-cursor-themes
    kvmarwaita
    custom-whitesur-icon-theme
    whitesur-gtk-theme
    nwg-look
    libsForQt5.qt5ct
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum
    sddm-theme
    sddm-theme.test
  ];

  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      ubuntu-sans
      noto-fonts
      material-symbols
    ];
    fontconfig = {
      defaultFonts = {
        serif = [
          "Liberation Serif"
          "Vazirmatn"
        ];
        sansSerif = [
          "Ubuntu Sans"
          "Vazirmatn"
        ];
        monospace = [ "JetBrains Mono" ];
      };
    };
    fontDir.enable = true;
  };

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22000 # Syncthing
      80
      443
    ];
  };

  system.stateVersion = "25.05";
}
