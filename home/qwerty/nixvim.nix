{ pkgs, inputs, ... }:

# Nixvim config (home-manager module).
# Languages: Nix, Terraform, Python, Rust, QML (Quickshell).
# Colorscheme: gruvbox (dark).

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    ##########################################################################
    # Colorscheme
    ##########################################################################
    colorschemes.gruvbox = {
      enable = true;
      settings = {
        contrast = ""; # "" (medium), "soft" or "hard"
        terminal_colors = true;
        transparent_mode = false;
        italic = {
          strings = false;
          comments = true;
          operators = false;
          folds = true;
          emphasis = true;
        };
      };
    };

    ##########################################################################
    # Core settings
    ##########################################################################
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Wayland clipboard support (needed for `clipboard = "unnamedplus"`).
    clipboard.providers.wl-copy.enable = true;

    opts = {
      background = "dark";

      mouse = "a";
      clipboard = "unnamedplus";
      swapfile = false;
      backup = false;
      undofile = true;

      number = true;
      relativenumber = true;
      cursorline = true;
      termguicolors = true;
      signcolumn = "yes";
      scrolloff = 8;
      wrap = false;
      showmode = false; # lualine shows the mode

      # 4 is the default; 2-space languages are overridden in autoCmd below.
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      autoindent = true;
      # Legacy option: pulls `#` lines to column 0 and fights treesitter/filetype indent.
      smartindent = false;

      ignorecase = true;
      smartcase = true;
      incsearch = true;
      hlsearch = true;

      splitright = true;
      splitbelow = true;

      updatetime = 250;
      timeoutlen = 400;
      completeopt = [ "menuone" "noselect" ];
    };

    filetype.extension = {
      tf = "terraform";
      tfvars = "terraform";
    };

    diagnostic.settings = {
      severity_sort = true;
      update_in_insert = false;
      float.border = "rounded";
    };

    autoCmd = [
      # Languages whose formatters/style use 2 spaces.
      {
        event = "FileType";
        pattern = [ "nix" "terraform" "hcl" "yaml" "json" "lua" ];
        command = "setlocal shiftwidth=2 tabstop=2 softtabstop=2";
      }
    ];

    ##########################################################################
    # Keymaps
    ##########################################################################
    keymaps = [
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }

      # Window navigation
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Focus left split"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Focus split below"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Focus split above"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Focus right split"; }

      # Window resize
      { mode = "n"; key = "<C-Up>"; action = "<cmd>resize +2<CR>"; }
      { mode = "n"; key = "<C-Down>"; action = "<cmd>resize -2<CR>"; }
      { mode = "n"; key = "<C-Left>"; action = "<cmd>vertical resize -2<CR>"; }
      { mode = "n"; key = "<C-Right>"; action = "<cmd>vertical resize +2<CR>"; }

      # Move selection. The old `gv=gv` re-indent is dropped on purpose: it
      # re-indented moved blocks via indentexpr and caused odd indentation.
      # Use ":m '>+1<CR>gv=gv" if you want it back.
      { mode = "v"; key = "J"; action = ":m '>+1<CR>gv"; options.desc = "Move selection down"; }
      { mode = "v"; key = "K"; action = ":m '<-2<CR>gv"; options.desc = "Move selection up"; }

      # Centered scrolling / search
      { mode = "n"; key = "<C-d>"; action = "<C-d>zz"; }
      { mode = "n"; key = "<C-u>"; action = "<C-u>zz"; }
      { mode = "n"; key = "n"; action = "nzzzv"; }
      { mode = "n"; key = "N"; action = "Nzzzv"; }

      { mode = "n"; key = "<leader>w"; action = "<cmd>w<CR>"; options.desc = "Save"; }
      { mode = "n"; key = "<leader>q"; action = "<cmd>q<CR>"; options.desc = "Quit"; }

      # Buffers
      { mode = "n"; key = "<S-l>"; action = "<cmd>BufferLineCycleNext<CR>"; options.desc = "Next buffer"; }
      { mode = "n"; key = "<S-h>"; action = "<cmd>BufferLineCyclePrev<CR>"; options.desc = "Previous buffer"; }
      { mode = "n"; key = "<leader>bp"; action = "<cmd>BufferLinePick<CR>"; options.desc = "Pick buffer"; }
      { mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<CR>"; options.desc = "Delete buffer"; }

      # File explorer
      { mode = "n"; key = "<leader>e"; action = "<cmd>Oil<CR>"; options.desc = "File explorer"; }

      # Manual format (conform, falls back to LSP)
      {
        mode = [ "n" "v" ];
        key = "<leader>cf";
        action.__raw = ''
          function()
            require("conform").format({ lsp_format = "fallback" })
          end
        '';
        options.desc = "Format";
      }
    ];

    ##########################################################################
    # Plugins
    ##########################################################################
    plugins = {
      web-devicons.enable = true;

      # --- UI ---------------------------------------------------------------
      bufferline = {
        enable = true;
        settings.options = {
          mode = "buffers";
          diagnostics = "nvim_lsp";
          separator_style = "slant";
          always_show_bufferline = true;
          show_buffer_close_icons = true;
          show_close_icon = false;
        };
      };

      lualine = {
        enable = true;
        settings.options = {
          theme = "auto"; # follows gruvbox
          globalstatus = true;
        };
      };

      indent-blankline.enable = true; # also makes indentation problems visible

      which-key = {
        enable = true;
        settings.spec = [
          { __unkeyed-1 = "<leader>f"; group = "Find"; }
          { __unkeyed-1 = "<leader>b"; group = "Buffer"; }
          { __unkeyed-1 = "<leader>c"; group = "Code"; }
        ];
      };

      # --- Editing ----------------------------------------------------------
      nvim-autopairs.enable = true;
      gitsigns.enable = true;
      oil.enable = true; # replaces netrw

      # --- Completion -------------------------------------------------------
      blink-cmp = {
        enable = true;
        settings = {
          keymap.preset = "enter";
          completion.documentation.auto_show = true;
        };
      };

      # --- LSP --------------------------------------------------------------
      lsp = {
        enable = true;
        inlayHints = true; # inferred types inline, handy while learning Rust

        servers = {
          terraformls = {
            enable = true;
            filetypes = [ "terraform" "terraform-vars" ];
          };

          nixd.enable = false; # flip to true if you want a Nix LSP

          basedpyright.enable = true;
          ruff.enable = true;

          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
            settings.check.command = "clippy";
          };

          # Quickshell: keep an empty `.qmlls.ini` in your shell config dir.
          qmlls.enable = true;
        };

        keymaps = {
          silent = true;
          diagnostic = {
            "]d" = { action = "goto_next"; desc = "Next diagnostic"; };
            "[d" = { action = "goto_prev"; desc = "Previous diagnostic"; };
            "<leader>d" = { action = "open_float"; desc = "Line diagnostics"; };
          };
          lspBuf = {
            gd = { action = "definition"; desc = "Go to definition"; };
            gr = { action = "references"; desc = "References"; };
            K = { action = "hover"; desc = "Hover docs"; };
            "<leader>rn" = { action = "rename"; desc = "Rename symbol"; };
            "<leader>ca" = { action = "code_action"; desc = "Code action"; };
          };
        };
      };

      # --- Formatting -------------------------------------------------------
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix = [ "nixfmt" ];
            terraform = [ "terraform_fmt" ];
            python = [ "ruff_organize_imports" "ruff_format" ];
            qml = [ "qmlformat" ]; # opinionated, remove if you dislike it
            # rust: handled by rust-analyzer (rustfmt) via lsp_format fallback
          };
          format_on_save = {
            timeout_ms = 500;
            lsp_format = "fallback";
          };
        };
      };

      # --- Rust -------------------------------------------------------------
      crates.enable = true; # crate versions in Cargo.toml

      # --- Telescope --------------------------------------------------------
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        keymaps = {
          "<leader>ff" = { action = "find_files"; options.desc = "Find files"; };
          "<leader>fg" = { action = "live_grep"; options.desc = "Live grep"; };
          "<leader>fb" = { action = "buffers"; options.desc = "Buffers"; };
          "<leader>fh" = { action = "help_tags"; options.desc = "Help tags"; };
          "<leader>fr" = { action = "oldfiles"; options.desc = "Recent files"; };
          "<leader>fd" = { action = "diagnostics"; options.desc = "Diagnostics"; };
        };
        settings.defaults = {
          file_ignore_patterns = [ "node_modules" ".git/" ];
          layout_strategy = "horizontal";
          layout_config.prompt_position = "top";
          sorting_strategy = "ascending";
        };
      };

      # --- Treesitter -------------------------------------------------------
      # Nixvim installs all grammars as Nix packages by default (Python, Rust,
      # QML, HCL, Nix, ...), so no `ensure_installed` is needed.
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true; # if indentation acts up: `:TSBufToggle indent`
        };
      };
    };

    # Tools that nvim needs on its PATH.
    extraPackages = [
      pkgs.nixfmt
      pkgs.ruff
      pkgs.rustfmt
      pkgs.clippy
      pkgs.kdePackages.qtdeclarative # qmlls, qmlformat
      # terraform_fmt needs `terraform` (or use opentofu + "tofu_fmt") on PATH,
      # e.g. from your system packages or a devshell.
    ];
  };
}
