{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  imports = [ ../../modules/desktop.nix ];

  ##########################################################################
  # Boot
  ##########################################################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the latest kernel available from this nixpkgs revision.
  boot.kernelPackages = pkgs.linuxPackages;

  ##########################################################################
  # Identity
  ##########################################################################
  networking.hostName = "workstation"; # keep in sync with `hostname` in flake.nix

  # Docker
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true; # periodically cleans unused images/containers
  };

  services.openssh = {
    enable = true;
    openFirewall = false; # don't open port 22; we only need the host key
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "docker"
    ];
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
  system.stateVersion = "26.11";
}
