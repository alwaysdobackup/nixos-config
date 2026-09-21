{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;

    # Useful Bash defaults for an interactive DevOps shell.
    shellOptions = [
      "histappend"
      "checkwinsize"
      "cdspell"
      "cmdhist"
    ];

    historySize = 10000;
    historyFileSize = 20000;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];

    shellAliases = {
      ll = "ls -lah";
      la = "ls -A";
      l = "ls -CF";

      ".." = "cd ..";
      "..." = "cd ../..";

      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --decorate --graph";

      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get svc";
      kgn = "kubectl get nodes";

      tf = "terraform";
    };

    initExtra = ''
      # ============================================================
      # DevOps Bash Prompt
      # ============================================================

      # Colors
      __prompt_reset='\[\e[0m\]'
      __prompt_gray='\[\e[90m\]'
      __prompt_red='\[\e[31m\]'
      __prompt_green='\[\e[32m\]'
      __prompt_yellow='\[\e[33m\]'
      __prompt_blue='\[\e[34m\]'
      __prompt_magenta='\[\e[35m\]'
      __prompt_cyan='\[\e[36m\]'
      __prompt_bright_cyan='\[\e[96m\]'
      __prompt_white='\[\e[97m\]'
      __prompt_bold='\[\e[1m\]'


      # ------------------------------------------------------------
      # Git
      # ------------------------------------------------------------

      __prompt_git() {
        command -v git >/dev/null 2>&1 || return

        local branch
        branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)" ||
          branch="$(git rev-parse --short HEAD 2>/dev/null)" ||
          return

        if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
          printf '%s󰊢 %s*%s' \
            "$__prompt_yellow" \
            "$branch" \
            "$__prompt_reset"
        else
          printf '%s󰊢 %s%s' \
            "$__prompt_green" \
            "$branch" \
            "$__prompt_reset"
        fi
      }


      # ------------------------------------------------------------
      # Nix
      # ------------------------------------------------------------

      __prompt_nix() {
        [[ -n "$IN_NIX_SHELL" ]] || return

        local name="''${name:-shell}"

        printf '%s󱄅 nix:%s%s' \
          "$__prompt_cyan" \
          "$name" \
          "$__prompt_reset"
      }


      # ------------------------------------------------------------
      # Python virtualenv
      # ------------------------------------------------------------

      __prompt_python() {
        [[ -n "$VIRTUAL_ENV" ]] || return

        printf '%s %s%s' \
          "$__prompt_blue" \
          "$(basename "$VIRTUAL_ENV")" \
          "$__prompt_reset"
      }


      # ------------------------------------------------------------
      # Kubernetes
      # ------------------------------------------------------------

      __prompt_kubernetes() {
        command -v kubectl >/dev/null 2>&1 || return

        [[ -f "$HOME/.kube/config" || -n "$KUBECONFIG" ]] || return

        local context namespace

        context="$(kubectl config current-context 2>/dev/null)" ||
          return

        namespace="$(
          kubectl config view \
            --minify \
            --output 'jsonpath={..namespace}' \
            2>/dev/null
        )"

        namespace="''${namespace:-default}"

        printf '%s󱃾 %s/%s%s' \
          "$__prompt_magenta" \
          "$context" \
          "$namespace" \
          "$__prompt_reset"
      }


      # ------------------------------------------------------------
      # Terraform
      # ------------------------------------------------------------

      __prompt_terraform() {
        [[ -d ".terraform" ]] || return
        command -v terraform >/dev/null 2>&1 || return

        local workspace
        workspace="$(terraform workspace show 2>/dev/null)" || return

        printf '%s󱁢 tf:%s%s' \
          "$__prompt_bright_cyan" \
          "$workspace" \
          "$__prompt_reset"
      }


      # ------------------------------------------------------------
      # AWS
      # ------------------------------------------------------------

      __prompt_aws() {
        [[ -n "$AWS_PROFILE" ]] || return

        printf '%s󰸏 aws:%s%s' \
          "$__prompt_yellow" \
          "$AWS_PROFILE" \
          "$__prompt_reset"
      }


      # ------------------------------------------------------------
      # SSH
      # ------------------------------------------------------------

      __prompt_ssh() {
        [[ -n "$SSH_CONNECTION" ]] || return

        printf '%s󰣀 SSH%s' \
          "$__prompt_red" \
          "$__prompt_reset"
      }


      # ------------------------------------------------------------
      # Docker
      # ------------------------------------------------------------

      __prompt_docker() {
        [[ -n "$DOCKER_CONTEXT" ]] || return
        [[ "$DOCKER_CONTEXT" == "default" ]] && return

        printf '%s󰡨 docker:%s%s' \
          "$__prompt_cyan" \
          "$DOCKER_CONTEXT" \
          "$__prompt_reset"
      }


      # ------------------------------------------------------------
      # Compose environment information
      # ------------------------------------------------------------

      __prompt_environment() {
        local item
        local output=""

        item="$(__prompt_git)"
        [[ -n "$item" ]] && output+=" $item"

        item="$(__prompt_nix)"
        [[ -n "$item" ]] && output+=" $item"

        item="$(__prompt_python)"
        [[ -n "$item" ]] && output+=" $item"

        item="$(__prompt_terraform)"
        [[ -n "$item" ]] && output+=" $item"

        item="$(__prompt_kubernetes)"
        [[ -n "$item" ]] && output+=" $item"

        item="$(__prompt_docker)"
        [[ -n "$item" ]] && output+=" $item"

        item="$(__prompt_aws)"
        [[ -n "$item" ]] && output+=" $item"

        item="$(__prompt_ssh)"
        [[ -n "$item" ]] && output+=" $item"

        printf '%s' "$output"
      }


      # ------------------------------------------------------------
      # Prompt
      # ------------------------------------------------------------

      __prompt_command() {
        local exit_code=$?

        local user_color="$__prompt_green"

        if [[ "$EUID" -eq 0 ]]; then
          user_color="$__prompt_red"
        fi

        local status

        if (( exit_code == 0 )); then
          status="''${__prompt_green}✔''${__prompt_reset}"
        else
          status="''${__prompt_red}✘ $exit_code''${__prompt_reset}"
        fi

        local environment
        environment="$(__prompt_environment)"

        PS1="''${__prompt_gray}┌─''${__prompt_reset}"
        PS1+="''${user_color}\u''${__prompt_reset}"
        PS1+="''${__prompt_gray}@''${__prompt_reset}"
        PS1+="''${__prompt_bright_cyan}\h''${__prompt_reset}"
        PS1+=" ''${__prompt_gray}in''${__prompt_reset}"
        PS1+=" ''${__prompt_blue}\w''${__prompt_reset}"
        PS1+="''${environment}"
        PS1+=$'\n'
        PS1+="''${__prompt_gray}└─''${__prompt_reset}"
        PS1+="''${status}"
        PS1+=" ''${__prompt_bold}''${__prompt_white}\\\$''${__prompt_reset} "
      }


      # Preserve any existing PROMPT_COMMAND.
      PROMPT_COMMAND="__prompt_command''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    '';
  };
}

