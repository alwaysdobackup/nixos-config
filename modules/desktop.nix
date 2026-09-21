{ config, pkgs, lib, username, ... }:

# Everything in this file is meant to be identical across every machine you
# run this on. Anything that varies per-machine (hostname, disk, timezone,
# boot loader details, the user account itself) lives in hosts/<name>/
# instead, which imports this module.

{
  ##########################################################################
  # Networking: systemd-networkd + systemd-resolved (no NetworkManager)
  ##########################################################################
  networking.networkmanager.enable = false;

  networking.useNetworkd = true;
  networking.useDHCP = false; # DHCP is configured per-interface below instead

  systemd.network.enable = true;

  # Wired: DHCP on any ethernet-type interface
  systemd.network.networks."10-wired" = {
    matchConfig.Type = "ether";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
    };
  };

  # Wi-Fi via iwd (simpler and more systemd-networkd-friendly than
  # wpa_supplicant + NetworkManager). iwd itself only does association;
  # networkd handles DHCP.
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = false;
  };
  systemd.network.networks."20-wireless" = {
    matchConfig.Type = "wlan";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "false"; # flip to "allow-downgrade"/"true" once you've checked your resolver supports it
  };

  ##########################################################################
  # Graphics: nvidia-open
  ##########################################################################
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # needed for Steam/Wine/some flatpaks; drop if you don't want it
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;   # required for Wayland compositors like niri
    open = true;                 # nvidia-open: only Turing (RTX 20xx) and newer
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    nvidiaSettings = true;

    powerManagement.enable = false; # flip to true on a laptop if suspend misbehaves
  };

  programs.niri.enable = true;

  services.getty.autologinUser = username;
  # The actual "exec niri-session" on tty1 login lives in home/<user>/home.nix's
  # shell config, since that's per-user.

  security.polkit.enable = true;

  ##########################################################################
  # Audio: pipewire replaces pipewire/pipewire-pulse/wireplumber as 3 separate
  # Arch packages -- on NixOS it's one service block.
  ##########################################################################
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  ##########################################################################
  # Bluetooth
  ##########################################################################
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  # bluetui (in home.nix) is a TUI, so no tray applet/daemon like blueman needed.

  ##########################################################################
  # Flatpak
  ##########################################################################
  services.flatpak.enable = true;
  xdg.portal.enable = true; # flatpak apps and screen-sharing need portals

  ##########################################################################
  # Fonts
  ##########################################################################
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  ##########################################################################
  # A handful of genuinely system-level packages.
  # Everything else (CLI tools, GUI apps) lives in home/<user>/home.nix
  # instead -- see the explanation in README.md.
  ##########################################################################
  environment.systemPackages = with pkgs; [
    git
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true; # the nvidia driver is unfree
}
