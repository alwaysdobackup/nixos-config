{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./alacritty.nix
    ./niri.nix
    ./nixvim.nix
    ./ssh.nix
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
      "app.zen_browser.zen"
      "org.telegram.desktop"
      "md.obsidian.Obsidian"
      "com.spotify.Client"
      "com.visualstudio.code"
    ];
  };


  ##########################################################################
  # Niri: launched, not yet configured here. On first run niri writes a
  # commented, documented default config to ~/.config/niri/config.kdl --
  # edit that by hand for now. Once you're happy with it, you can migrate it
  # into home-manager's `programs.niri.settings` (from home-manager's niri
  # module) for reproducibility.
  ##########################################################################

  ##########################################################################
  # Shell: since there's no greeter yet, autologin (configuration.nix) drops
  # you into a shell on tty1, and this launches niri from there.
  ##########################################################################
  programs.bash = {
    enable = true;
    initExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec niri-session
      fi
    '';
  };

  programs.git = {
	enable = true;
	userName = "Volodymyr Tymchuk";
	userEmail = "volodymyr.tymchuk@outlook.com";
  };

  programs.home-manager.enable = true;
}
