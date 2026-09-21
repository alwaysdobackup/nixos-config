{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./alacritty.nix
    ./bash.nix
    ./niri.nix
    ./nixvim.nix
    ./ssh.nix
    ./zen.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  # Match this to the NixOS release you installed with; see configuration.nix.
  home.stateVersion = "26.05";

  ##########################################################################
  # Packages -- direct translation of your pacman list, minus what's now a
  # NixOS *service* instead of a package (pipewire/wireplumber/bluez/flatpak
  # are enabled in configuration.nix) and minus neovim (configured natively
  # via nixvim.nix instead of just installed as a binary).
  ##########################################################################
  home.packages = with pkgs; [
    # Core / CLI
    alacritty
    tmux
    ripgrep
    fd
    jq
    bc
    lsof
    unzip

    # Audio
    pulsemixer
    playerctl

    # Bluetooth
    bluetui

    # Screenshots / clipboard
    slurp
    grim
    wl-clipboard

    # Misc
    # quickshell has no home-manager module yet, so just install the package
    inputs.quickshell.packages.${pkgs.system}.default
  ];

  services.flatpak = {
    packages = [
      "org.telegram.desktop"
      "md.obsidian.Obsidian"
      "com.spotify.Client"
      "com.visualstudio.code"
    ];
  };


  programs.git = {
	enable = true;
	userName = "Volodymyr Tymchuk";
	userEmail = "volodymyr.tymchuk@outlook.com";
  };

  programs.home-manager.enable = true;
}
