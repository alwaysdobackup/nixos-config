{ pkgs, ... }:

{
  programs.niri = {
    package = pkgs.niri;

    settings = {
      # --------------------------------------------------------------------
      # General
      # --------------------------------------------------------------------
      
      prefer-no-csd = true;

      screenshot-path =
        "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";

      hotkey-overlay = {
        skip-at-startup = true;
      };


      # --------------------------------------------------------------------
      # Environment
      # --------------------------------------------------------------------

      environment = {
        # Wayland-native applications.
        QT_QPA_PLATFORM = "wayland";

        # GTK / Electron / Chromium applications.
        NIXOS_OZONE_WL = "1";

        # Firefox and other applications.
        MOZ_ENABLE_WAYLAND = "1";

        # Java applications which support Wayland.
        _JAVA_AWT_WM_NONREPARENTING = "1";

        # Prevent applications from forcing X11 display usage.
        DISPLAY = null;
      };

      # --------------------------------------------------------------------
      # Monitor
      # --------------------------------------------------------------------
      outputs."HDMI-A-1" = {
          mode = {
              width = 3840;
              height = 2160;
              refresh = 60.0;
          };
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


        # Increase mouse wheel scrolling speed.
        # 2.0 = approximately twice the normal scroll distance.
        mouse.scroll-factor = 2.0;
      };

      
      # --------------------------------------------------------------------
      # Cursor
      # --------------------------------------------------------------------
      cursor = {
        hide-when-typing = true;
        hide-after-inactive-ms = 2000;
      };


      # --------------------------------------------------------------------
      # Layout
      # --------------------------------------------------------------------
        
      layout = {
        gaps = 12;

        # DevOps work usually benefits from keeping the focused
        # terminal/editor near the center of the screen.
        center-focused-column = "never";

        always-center-single-column = true;

        default-column-width = {
          proportion = 0.50;
        };

        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.50; }
          { proportion = 0.66667; }
        ];


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

      # --------------------------------------------------------------------
      # Window rules
      # --------------------------------------------------------------------

      window-rules = [
        # ----------------------------------------------------------
        # Terminal
        # ----------------------------------------------------------

        {
          matches = [
            { app-id = "^Alacritty$"; }
            { app-id = "^org\.wezfurlong\.wezterm$"; }
          ];

          default-column-width = {
            proportion = 0.50;
          };
        }

        # ----------------------------------------------------------
        # Browser
        # ----------------------------------------------------------

        {
          matches = [
            { app-id = "^zen$"; }
            { app-id = "^firefox$"; }
            { app-id = "^chromium$"; }
            { app-id = "^google-chrome$"; }
          ];

          default-column-width = {
            proportion = 0.66667;
          };
        }

        # ----------------------------------------------------------
        # Floating dialogs
        # ----------------------------------------------------------

        {
          matches = [
            { title = "^(Open|Save|Select).*"; }
          ];

          open-floating = true;
        }

        # ----------------------------------------------------------
        # Authentication dialogs
        # ----------------------------------------------------------

        {
          matches = [
            { app-id = ".*polkit.*"; }
          ];

          open-floating = true;
        }

        # ----------------------------------------------------------
        # Picture-in-picture
        # ----------------------------------------------------------

        {
          matches = [
            {
              title = ".*Picture-in-Picture.*";
            }
          ];

          open-floating = true;
        }

        # ----------------------------------------------------------
        # Extension: Bitwarden 
        # ----------------------------------------------------------

        {
            matches = [
              {
                app-id = "^zen$";
                title = "^Extension:.*Bitwarden.*Zen Browser$";
              }
            ];

            open-floating = true;

            default-column-width = {
              fixed = 420;
            };

            default-window-height = {
              fixed = 700;
            };
        }
      ];
    };
  };
}

