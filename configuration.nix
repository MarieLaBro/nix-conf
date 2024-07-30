# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <nixos-hardware/dell/g3/3779>
      ./hardware-configuration.nix
      ./unstable.nix
    ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.11"; # Did you read the comment?

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/mnt/windows" =
    { device = "/dev/nvme0n1p3";
      fsType = "ntfs-3g"; 
      options = [ "rw" "uid=1000"];
    };

  networking.hostName = "marie-nix"; # Define your hostname.
  
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_CA.UTF-8";

  # Enable the GNOME Desktop Environment.
  services.displayManager = {
    defaultSession = "plasmawayland";
    sddm = {
      enable=true;
      wayland.enable = true;
    };
  };
  services.xserver = {
    enable = true; # Enable the X11 windowing system.
    desktopManager = {
      plasma5.enable = true;
    };
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Flatpaks
  services.flatpak.enable = true;
  
  hardware.bluetooth.enable = true;

  #xdg.portal.config.common.default = "gtk";

  # Tapping
  #services.xserver.libinput.enable = true;
  #services.xserver.libinput.touchpad.tapping= true;
  #services.xserver.libinput.touchpad.clickMethod = "clickfinger";

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marielabro = {
    isNormalUser = true;
    description = "Marie-Jeanne Cormier";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      vlc
      kitty
      steam
      kodi
      zoom-us #rencontres FDLB
      blender
      
      gparted
      nodejs_22

      thunderbird
      libreoffice-qt

      #plasma
      kdePackages.merkuro
      kdePackages.kdepim-addons

      #nixos utils
      nh
      nil

      lutris
      gamemode
      gamescope
      fish

      gtk3
      gtk4
      lxappearance

      #Minecraft
      temurin-jre-bin-17

      #creative
      gimp
      krita
      kdenlive
      obs-studio

      papirus-icon-theme
    ];
  };

  

  programs.bash = {
  interactiveShellInit = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';
};

  programs.dconf.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "marielabro";
  #services.xserver.displayManager.gdm.wayland = true;

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    gh
    tree
    btop
    ranger
  ];

  #Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  # Nvidia
  # Enable OpenGL - Managed by hardware-config

  # RPCS3
  security.pam.loginLimits = [
    { domain = "*"; item = "memlock"; type = "hard"; value = "unlimited"; }
    { domain = "*"; item = "memlock"; type = "soft"; value = "unlimited"; }
  ];
}
