{ config, ... }:

let
  home = config.home.homeDirectory;
in
{
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop     = "${home}/Desktop";
    documents   = "${home}/Documents";
    download    = "${home}/Downloads";
    music       = "${home}/Music";
    pictures    = "${home}/Pictures";
    videos      = "${home}/Videos";
    templates   = "${home}/Templates";
    publicShare = "${home}/Public";

    # Custom dirs, exposed as XDG_<NAME>_DIR
    extraConfig = {
      XDG_PROJECTS_DIR = "${home}/Projects";
    };
  };
}
