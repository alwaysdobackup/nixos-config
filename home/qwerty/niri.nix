{ pkgs, ... }:

{
  programs.niri = {
    enable = true;

    settings = {
      # --------------------------------------------------------------------
      # Monitor
      # --------------------------------------------------------------------
      outputs."HDMI-A-1" = {
        mode = "3840x2160@60.000";
        scale = 1.0;
      };

      # --------------------------------------------------------------------
      # Input
      # --------------------------------------------------------------------
      input = {
        keyboard.xkb = {
          layout = "us,ua";
          options = "grp:win_space_toggle";
        };

        # Disable touchpad completely.
        touchpad.off = true;

        # Increase mouse wheel scrolling speed.
        # 2.0 = approximately twice the normal scroll distance.
        mouse.scroll-factor = 2.0;
      };

      # --------------------------------------------------------------------
      # Workspaces
      # --------------------------------------------------------------------
      workspaces = {
        personal = {};
        work = {};
        devops = {};
        notes = {};
        messenger = {};
        media = {};
        scratch = {};
        misc = {};
      };

      # --------------------------------------------------------------------
      # Keybindings
      #
      # We intentionally don't copy Niri's complete default bind set.
      # This gives us a small configuration that we can expand later.
      # --------------------------------------------------------------------
      binds = {
        # Terminal
        "Mod+Return".action.spawn = "alacritty";

        # Keyboard layout: US <-> UA
        #
        # The actual switching is handled by the XKB option above.
        # Super+Space is therefore the layout switch shortcut.
        #
        # Niri itself doesn't need a corresponding action here.

        # Close focused window
        "Mod+Shift+Q".action.close-window = {};

        # Focus columns
        "Mod+Left".action.focus-column-left = {};
        "Mod+Right".action.focus-column-right = {};

        # Focus windows
        "Mod+Up".action.focus-window-up = {};
        "Mod+Down".action.focus-window-down = {};

        # Workspaces
        "Mod+1".action.focus-workspace = "personal";
        "Mod+2".action.focus-workspace = "work";
        "Mod+3".action.focus-workspace = "devops";
        "Mod+4".action.focus-workspace = "notes";
        "Mod+5".action.focus-workspace = "messenger";
        "Mod+6".action.focus-workspace = "media";
        "Mod+7".action.focus-workspace = "scratch";
        "Mod+8".action.focus-workspace = "misc";

        # Move focused window to workspace
        "Mod+Shift+1".action.move-window-to-workspace = "personal";
        "Mod+Shift+2".action.move-window-to-workspace = "work";
        "Mod+Shift+3".action.move-window-to-workspace = "devops";
        "Mod+Shift+4".action.move-window-to-workspace = "notes";
        "Mod+Shift+5".action.move-window-to-workspace = "messenger";
        "Mod+Shift+6".action.move-window-to-workspace = "media";
        "Mod+Shift+7".action.move-window-to-workspace = "scratch";
        "Mod+Shift+8".action.move-window-to-workspace = "misc";
      };
    };
  };
}

