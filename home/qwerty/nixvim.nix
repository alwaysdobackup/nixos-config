{ pkgs, inputs, ... }:

# Ported from ~/.config/nvim: init.lua + lua/plugins/{buffferline,lsp,telescope,treesitter}.lua
# + lua/lsp/terraformls.lua.
#
# No colorscheme was set anywhere in your files (nvim's built-in default is
# used), so none is set here either -- say the word if you want one.

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      netrw_banner = 0;
      netrw_liststyle = 3;
    };

    opts = {
      mouse = "a";
      clipboard = "unnamedplus";
      swapfile = false;
      backup = false;
      undofile = true; # nvim's default undodir (stdpath("data")/undo) matches what your init.lua set explicitly

      number = true;
      relativenumber = true;
      cursorline = true;
      termguicolors = true;
      signcolumn = "yes";
      scrolloff = 8;
      wrap = false;
      showmode = false;

      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      smartindent = true;
      autoindent = true;

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

    keymaps = [
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }

      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Focus left split"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Focus split below"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Focus split above"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Focus right split"; }

      { mode = "n"; key = "<C-Up>"; action = "<cmd>resize +2<CR>"; }
      { mode = "n"; key = "<C-Down>"; action = "<cmd>resize -2<CR>"; }
      { mode = "n"; key = "<C-Left>"; action = "<cmd>vertical resize -2<CR>"; }
      { mode = "n"; key = "<C-Right>"; action = "<cmd>vertical resize +2<CR>"; }

      { mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; options.desc = "Move selection down"; }
      { mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; options.desc = "Move selection up"; }

      { mode = "n"; key = "<C-d>"; action = "<C-d>zz"; }
      { mode = "n"; key = "<C-u>"; action = "<C-u>zz"; }
      { mode = "n"; key = "n"; action = "nzzzv"; }
      { mode = "n"; key = "N"; action = "Nzzzv"; }

      { mode = "n"; key = "<leader>w"; action = "<cmd>w<CR>"; options.desc = "Save"; }
      { mode = "n"; key = "<leader>q"; action = "<cmd>q<CR>"; options.desc = "Quit"; }

      { mode = "n"; key = "<S-l>"; action = "<cmd>BufferLineCycleNext<CR>"; }
      { mode = "n"; key = "<S-h>"; action = "<cmd>BufferLineCyclePrev<CR>"; }
      { mode = "n"; key = "<leader>bp"; action = "<cmd>BufferLinePick<CR>"; options.desc = "Pick buffer"; }
      { mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<CR>"; options.desc = "Delete buffer"; }

      { mode = "n"; key = "<leader>e"; action = "<cmd>Ex<CR>"; options.desc = "Open netrw"; }
    ];

    ##########################################################################
    # Plugins
    ##########################################################################
    plugins = {
      # Needed by both bufferline and telescope (your lazy.nvim specs listed
      # it as a dependency of each).
      web-devicons.enable = true;

      # --- buffferline.lua -------------------------------------------------
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

      # --- lsp.lua + lsp/terraformls.lua ------------------------------------
      # Your setup used mason.nvim + mason-lspconfig to *download* terraform-ls
      # at runtime, then nvim-lspconfig + vim.lsp.config() to configure it.
      # nixvim's LSP module replaces the mason half: it pulls terraform-ls
      # from nixpkgs as a build-time dependency instead (reproducible, and no
      # runtime download/network needed), while still using the same
      # vim.lsp.config()/nvim-lspconfig mechanics underneath. So: no mason
      # here, just the server enabled directly, with your filetypes override
      # carried over.
      lsp = {
        enable = true;
        servers.terraformls = {
          enable = true;
          filetypes = [ "terraform" "terraform-vars" ];
        };
      };
      # If you actually want mason for other languages later (e.g. picking
      # servers at runtime rather than declaring them here), nixvim also has
      # `plugins.mason.enable = true;` -- the two approaches don't compose
      # well together for the same server, so pick one per-server.

      # --- telescope.lua -----------------------------------------------------
      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
          "<leader>fr" = "oldfiles";
        };
        settings.defaults = {
          file_ignore_patterns = [ "node_modules" ".git/" ];
          layout_strategy = "horizontal";
          layout_config.prompt_position = "top";
          sorting_strategy = "ascending";
        };
      };

      # --- treesitter.lua ----------------------------------------------------
      # NOTE: you pinned `branch = "master"` in lazy.nvim to stay on
      # nvim-treesitter's legacy, stable config API (`configs.setup` with
      # highlight/indent modules) -- upstream did a full incompatible rewrite
      # on their default branch. nixvim's treesitter module has historically
      # tracked that same legacy API, which is what `settings` below
      # reproduces. If highlighting looks wrong after your first build,
      # check nixvim's treesitter docs for whether it has since moved to the
      # new API, since that's a moving target upstream, not something this
      # config controls.
      #
      # Also: nixvim installs the actual parser binaries as Nix packages, so
      # there's no `:TSUpdate` build step to carry over -- `ensure_installed`
      # here just tells it which languages you want.
      treesitter = {
        enable = true;
        settings = {
          ensure_installed = [ "terraform" "hcl" ];
          highlight.enable = true;
          indent.enable = true;
        };
      };
    };

    # ------------------------------------------------------------------
    # Nothing pending -- this now covers everything in plugins/*.lua and
    # lsp/terraformls.lua. If you add more lazy.nvim plugins later, check
    # https://nix-community.github.io/nixvim/ first (most popular plugins
    # have a first-class `plugins.<name>` module like the ones above); if
    # one doesn't, fall back to `extraPlugins = [ pkgs.vimPlugins.<name> ];`
    # plus `extraConfigLua` for anything nixvim doesn't wrap yet.
    # ------------------------------------------------------------------
  };
}
