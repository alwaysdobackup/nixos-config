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
        "01-personal"   = { name = "personal"; };
        "02-work"       = { name = "work"; };
        "03-devops"     = { name = "devops"; };
        "04-notes"      = { name = "notes"; };
        "05-messenger"  = { name = "messenger"; };
        "06-media"      = { name = "media"; };
        "07-scratch"    = { name = "scratch"; };
        "08-misc"       = { name = "misc"; };
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

        # Overview
        "Mod+O".action.toggle-overview = [];

        # Media keys (playerctl works with any MPRIS-enabled player)
        "XF86AudioPlay" = { allow-when-locked = true; action.spawn-sh = "playerctl play-pause"; };
        "XF86AudioPause" = { allow-when-locked = true; action.spawn-sh = "playerctl play-pause"; };
        "XF86AudioStop" = { allow-when-locked = true; action.spawn-sh = "playerctl stop"; };
        "XF86AudioPrev" = { allow-when-locked = true; action.spawn-sh = "playerctl previous"; };
        "XF86AudioNext" = { allow-when-locked = true; action.spawn-sh = "playerctl next"; };

        # Brightness keys (brightnessctl)
        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = [ "brightnessctl" "--class=backlight" "set" "+10%" ];
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = [ "brightnessctl" "--class=backlight" "set" "10%-" ];
        };

        # Close focused window
        "Mod+Shift+Q".action.close-window = [];

        # Focus columns / windows (arrows + vim keys)
        "Mod+Left".action.focus-column-left = [];
        "Mod+Right".action.focus-column-right = [];
        "Mod+Up".action.focus-window-up = [];
        "Mod+Down".action.focus-window-down = [];
        "Mod+H".action.focus-column-left = [];
        "Mod+J".action.focus-window-down = [];
        "Mod+K".action.focus-window-up = [];
        "Mod+L".action.focus-column-right = [];

        # Move columns / windows
        "Mod+Ctrl+Left".action.move-column-left = [];
        "Mod+Ctrl+Down".action.move-window-down = [];
        "Mod+Ctrl+Up".action.move-window-up = [];
        "Mod+Ctrl+Right".action.move-column-right = [];
        "Mod+Ctrl+H".action.move-column-left = [];
        "Mod+Ctrl+J".action.move-window-down = [];
        "Mod+Ctrl+K".action.move-window-up = [];
        "Mod+Ctrl+L".action.move-column-right = [];

        # First / last column
        "Mod+Home".action.focus-column-first = [];
        "Mod+End".action.focus-column-last = [];
        "Mod+Ctrl+Home".action.move-column-to-first = [];
        "Mod+Ctrl+End".action.move-column-to-last = [];

        # Switch workspaces
        "Mod+Page_Down".action.focus-workspace-down = [];
        "Mod+Page_Up".action.focus-workspace-up = [];
        "Mod+U".action.focus-workspace-down = [];
        "Mod+I".action.focus-workspace-up = [];

        # Mouse wheel (cooldown is most useful on the wheel)
        "Mod+WheelScrollDown" = { cooldown-ms = 150; action.focus-workspace-down = []; };
        "Mod+WheelScrollUp" = { cooldown-ms = 150; action.focus-workspace-up = []; };
        "Mod+Ctrl+WheelScrollDown" = { cooldown-ms = 150; action.move-column-to-workspace-down = []; };
        "Mod+Ctrl+WheelScrollUp" = { cooldown-ms = 150; action.move-column-to-workspace-up = []; };

        "Mod+WheelScrollRight".action.focus-column-right = [];
        "Mod+WheelScrollLeft".action.focus-column-left = [];
        "Mod+Ctrl+WheelScrollRight".action.move-column-right = [];
        "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [];

        # Shift + wheel = horizontal scrolling, like in most applications
        "Mod+Shift+WheelScrollDown".action.focus-column-right = [];
        "Mod+Shift+WheelScrollUp".action.focus-column-left = [];
        "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [];
        "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [];

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

        # Consume / expel windows
        "Mod+BracketLeft".action.consume-or-expel-window-left = [];
        "Mod+BracketRight".action.consume-or-expel-window-right = [];
        # Consume one window from the right into the bottom of the focused column
        "Mod+Comma".action.consume-window-into-column = [];
        # Expel the bottom window from the focused column to the right
        "Mod+Period".action.expel-window-from-column = [];

        # Column width / window height presets
        "Mod+R".action.switch-preset-column-width = [];
        "Mod+Shift+R".action.switch-preset-column-width-back = [];
        "Mod+Ctrl+Shift+R".action.switch-preset-window-height = [];
        "Mod+Ctrl+R".action.reset-window-height = [];

        # Maximize / fullscreen
        "Mod+F".action.maximize-column = [];
        "Mod+Shift+F".action.fullscreen-window = [];
        # Like normal maximizing: no gaps or borders
        "Mod+M".action.maximize-window-to-edges = [];
        # Fill the rest of the space not taken by other fully visible columns
        "Mod+Ctrl+F".action.expand-column-to-available-width = [];

        # Centering
        "Mod+C".action.center-column = [];
        "Mod+Ctrl+C".action.center-visible-columns = [];

        # Finer size adjustments
        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        # Floating
        "Mod+V".action.toggle-window-floating = [];
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [];

        # Tabbed column display
        "Mod+W".action.toggle-column-tabbed-display = [];

        # Layout switching (only enable if you have NO matching xkb layout-switch option,
        # otherwise it will switch twice per keypress)
        # "Mod+Space".action.switch-layout = "next";
        # "Mod+Shift+Space".action.switch-layout = "prev";

        # Screenshots
        "Print".action.screenshot = [];
        "Ctrl+Print".action.screenshot-screen = [];
        "Alt+Print".action.screenshot-window = [];

        # Escape hatch for apps that inhibit shortcuts (remote desktop, KVM, etc.)
        "Mod+Escape" = {
          allow-inhibiting = false;
          action.toggle-keyboard-shortcuts-inhibit = [];
        };

        # Session
        "Mod+Shift+E".action.quit = [];
        "Ctrl+Alt+Delete".action.quit = [];
        "Mod+Shift+P".action.power-off-monitors = [];
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

