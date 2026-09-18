{ config, pkgs, lib, username, ... }:

{
  imports = [ ../../modules/desktop.nix ];

  ##########################################################################
  # Boot
  ##########################################################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ##########################################################################
  # Identity
  ##########################################################################
  networking.hostName = "workstation"; # keep in sync with `hostname` in flake.nix

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ];
    shell = pkgs.bash;
  };

  ##########################################################################
  # Locale
  ##########################################################################
  time.timeZone = "Europe/Kyiv"; # adjust if this isn't right
  i18n.defaultLocale = "en_US.UTF-8";

  # Set this to whatever release is current when you install (check with
  # `nixos-version` on the installer), then never change it -- see the
  # NixOS manual's notes on system.stateVersion for why.
  system.stateVersion = "26.05";
}
