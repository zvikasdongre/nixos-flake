# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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

  sddm-theme = inputs.silentSDDM.packages.${pkgs.system}.default.override {
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

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.upower.enable = true;

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

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vikas = {
    isNormalUser = true;
    description = "Vikas Dongre";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  programs.hyprlock.enable = true;

  # Setup git
  programs.git = {
    enable = true;
    config = {
      user.name = "Vikas Dongre";
      user.email = "zvikasdongre@gmail.com";
      init.defaultBranch = "main";
    };
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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
    nixfmt-rfc-style
    home-manager
    matugen
    gnome-bluetooth
    adw-gtk3

    # Fonts
    jetbrains-mono
    ubuntu-sans
    noto-fonts
    material-symbols

    # Common Programs
    vscode
    neovim
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

    # launcher
    inputs.vicinae.packages.${pkgs.system}.default

    # screenshot utilities
    grimblast
    grim
    slurp
    hyprpicker
    wl-clipboard

    # swww
    inputs.swww.packages.${pkgs.system}.swww

    # quickshell
    quickshell
    kdePackages.qtsvg
    kdePackages.qt5compat
    kdePackages.qtimageformats
    kdePackages.qtmultimedia
    kdePackages.qtvirtualkeyboard

    # Fabric Widgets
    inputs.fabric-widgets.packages.${pkgs.system}.run-widget

    # Ignis Widgets
    (inputs.ignis.packages.${pkgs.system}.default.override {
      enableAudioService = true;
      enableNetworkService = true;
      enableBluetoothService = true;
      useGrassSass = true;
      extraPackages = [
        # ...
      ];
    })

    # themes & theming utilities
    mint-cursor-themes
    afterglow-cursors-recolored
    kvmarwaita
    whitesur-icon-theme
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

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
