{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  environment.systemPackages = with pkgs; [
    google-chrome
    vscode
    steam
    discord
    rpcs3

    # Minecraft
    prismlauncher
    ## JDKS
    temurin-bin-8
    temurin-bin-21
    temurin-bin-11
  ];
}