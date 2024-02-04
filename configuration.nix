# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.xserver = {
    enable = true; # Enable the X11 windowing system.
    displayManager.gdm.enable = true;
    displayManager.defaultSession = "plasmawayland";
    desktopManager = {
      gnome.enable = true;
      plasma5.enable = true;
    };
  };

  # Fix gnome+plasma integration
  programs.ssh.askPassword = "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";

  # Theming
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Flatpaks
  services.flatpak.enable = true;

  xdg.portal.config.common.default = "gtk";

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
      vscode
      google-chrome
      gnome.gnome-tweaks
      discord
      vlc
      kitty
      steam
      
      gparted
      nodejs_21

      thunderbird
      libreoffice-qt

      gtk3
      gtk4
      lxappearance

      #creative
      gimp
      krita
      kdenlive

      # Gnome Extensions
      gnomeExtensions.appindicator
      gnomeExtensions.dash-to-panel
      gnomeExtensions.arcmenu
      gnomeExtensions.desktop-icons-ng-ding
      gnomeExtensions.blur-my-shell
      arc-theme 

      # Gnome stuff
      gnomeExtensions.appindicator
      gnome.gnome-settings-daemon
      papirus-icon-theme
    ];
  };

  #Gnome stuff
  environment.gnome.excludePackages = (with pkgs; [
    #gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    #cheese # webcam tool
    gnome-music
    gnome-terminal
    epiphany # web browser
    #geary # email reader
    #gnome-characters
    totem # video player
  ]);
  programs.dconf.enable = true;

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "marielabro";
  services.xserver.displayManager.gdm.wayland = true; # Use X11

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

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

  # TLP
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false; # Gnome??

  # Nvidia
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Do not disable this unless your GPU is unsupported or if you have a good reason to.
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      # Make sure to use the correct Bus ID values for your system!
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
