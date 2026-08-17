{
  config,
  pkgs,
  inputs,
  lib,
  nix-cachyos-kernel,
  ...
}: let
  custom-whitesur-icon-theme = pkgs.whitesur-icon-theme.override {
    alternativeIcons = true;
  };
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.noctalia-greeter.nixosModules.default
  ];

  nixpkgs.overlays = [
    nix-cachyos-kernel.overlays.pinned
  ];

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v4;

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
      devices = ["nodev"];
      useOSProber = false;
      extraEntriesBeforeNixOS = false;

      extraEntries = ''
        menuentry "Linux Mint" --class linuxmint --class gnu-linux --class gnu --class os {
          insmod part_gpt
          insmod ext2

          search --no-floppy --fs-uuid --set=root ecbee46f-8de4-42a1-8129-f027a44ce230

          linux /boot/vmlinuz \
            root=UUID=ecbee46f-8de4-42a1-8129-f027a44ce230 \
            ro quiet splash mem_sleep_default=deep

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

  services.greetd.enable = true;
  programs.noctalia-greeter = {
    enable = true;

    # Optional configuration
    greeter-args = "";
    settings = {
      appearance = {
        hide_logo = true;
      };
      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 24;
        path = "${pkgs.bibata-cursors}/share/icons";
      };
      keyboard = {
        layout = "us";
      };
    };
  };

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  services.gnome.gnome-keyring.enable = true;
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

  security.wrappers.btop = {
    source = "${pkgs.btop}/bin/btop";
    capabilities = "cap_perfmon+ep";
    owner = "root";
    group = "root";
  };

  users.users.vikas = {
    isNormalUser = true;
    description = "Vikas Dongre";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = [];
  };

  # Install firefox.
  programs.firefox.enable = true;
  programs.chromium.enable = true;

  # Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  programs.niri.enable = true;

  programs.mango.enable = true;

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
    xstow
    efibootmgr
    nixfmt
    usbutils
    libmtp
    glib
    wev
    python314
    nil
    nixd
    gpu-screen-recorder
    ripgrep

    # Power management
    lm_sensors

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
    stow
    atuin
    btop
    pix
    obsidian
    zed-editor
    vlc
    mpv
    chromium
    imagemagick

    # noctalia shell
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

    # themes & theming utilities
    mint-cursor-themes
    kvmarwaita
    custom-whitesur-icon-theme
    whitesur-gtk-theme
    nwg-look
    libsForQt5.qt5ct
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum
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
        ];
        sansSerif = [
          "Ubuntu Sans"
        ];
        monospace = ["JetBrains Mono"];
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
