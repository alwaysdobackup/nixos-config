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
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec niri-session
      fi

      # ============================================================
      # DevOps Bash Prompt (no forks, no external commands)
      #
      # Every segment is built with bash builtins only. Segment
      # functions append to $__prompt_env instead of printing, so no
      # $(...) subshell is needed either.
      #
      # Optional: export PROMPT_GIT_DIRTY=1 to show a "*" for a dirty
      # git tree. That is the only thing here that runs `git`.
      # ============================================================

      : "''${PROMPT_GIT_DIRTY:=0}"

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

      # Icons (Nerd Font)
      __icon_git=$'\xf3\xb0\x8a\xa2'   # U+F02A2
      __icon_nix=$'\xf3\xb1\x84\x85'   # U+F1105
      __icon_python=$'\xee\x9c\xbc'   # U+E73C
      __icon_k8s=$'\xf3\xb1\x83\xbe'   # U+F10FE
      __icon_tf=$'\xf3\xb1\x81\xa2'   # U+F1062
      __icon_aws=$'\xf3\xb0\xb8\x8f'   # U+F0E0F
      __icon_ssh=$'\xf3\xb0\xa3\x80'   # U+F08C0
      __icon_docker=$'\xf3\xb0\xa1\xa8'   # U+F0868


      # ------------------------------------------------------------
      # Git: read .git/HEAD directly instead of running git
      # ------------------------------------------------------------

      __prompt_git() {
        local dir="$PWD" gitdir="" head branch

        # Walk up looking for .git (directory, or file for worktrees/submodules)
        while :; do
          if [[ -d "$dir/.git" ]]; then
            gitdir="$dir/.git"
            break
          elif [[ -f "$dir/.git" ]]; then
            IFS= read -r head < "$dir/.git" || return
            gitdir="''${head#gitdir: }"
            [[ "$gitdir" == /* ]] || gitdir="$dir/$gitdir"
            break
          fi
          [[ "$dir" == / ]] && return
          dir="''${dir%/*}"
          dir="''${dir:-/}"
        done

        IFS= read -r head < "$gitdir/HEAD" || return

        if [[ "$head" == "ref: refs/heads/"* ]]; then
          branch="''${head#ref: refs/heads/}"
        else
          branch="''${head:0:7}"   # detached HEAD: short hash
        fi

        # Never let a branch name inject $(...) or backticks into PS1
        branch="''${branch//[\\\$\`]/}"

        local color="$__prompt_green" mark=""

        if [[ "$PROMPT_GIT_DIRTY" == 1 ]] &&
           [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
          color="$__prompt_yellow"
          mark="*"
        fi

        __prompt_env+=" ''${color}''${__icon_git} ''${branch}''${mark}''${__prompt_reset}"
      }


      # ------------------------------------------------------------
      # Nix
      # ------------------------------------------------------------

      __prompt_nix() {
        [[ -n "$IN_NIX_SHELL" ]] || return

        __prompt_env+=" ''${__prompt_cyan}''${__icon_nix} nix:''${name:-shell}''${__prompt_reset}"
      }


      # ------------------------------------------------------------
      # Python virtualenv
      # ------------------------------------------------------------

      __prompt_python() {
        [[ -n "$VIRTUAL_ENV" ]] || return

        __prompt_env+=" ''${__prompt_blue}''${__icon_python} ''${VIRTUAL_ENV##*/}''${__prompt_reset}"
      }


      # ------------------------------------------------------------
      # Terraform: read .terraform/environment instead of running terraform
      # ------------------------------------------------------------

      __prompt_terraform() {
        [[ -d .terraform ]] || return

        local ws="$TF_WORKSPACE"

        if [[ -z "$ws" && -r .terraform/environment ]]; then
          IFS= read -r ws < .terraform/environment
        fi

        ws="''${ws:-default}"
        ws="''${ws//[\\\$\`]/}"

        __prompt_env+=" ''${__prompt_bright_cyan}''${__icon_tf} tf:''${ws}''${__prompt_reset}"
      }


      # ------------------------------------------------------------
      # Kubernetes: parse the kubeconfig file instead of running kubectl
      # (assumes kubectl's own YAML layout; uses the first KUBECONFIG file)
      # ------------------------------------------------------------

      __prompt_kubernetes() {
        local cfg="''${KUBECONFIG%%:*}"
        cfg="''${cfg:-$HOME/.kube/config}"
        [[ -r "$cfg" ]] || return

        local line current="" pending="" in_contexts=0 q="'" key val
        local -A ns_of=()

        while IFS= read -r line; do
          case "$line" in
            "contexts:"*)         in_contexts=1 ;;
            "current-context: "*) current="''${line#current-context: }"; in_contexts=0 ;;
            [a-zA-Z]*:*)          in_contexts=0 ;;
            *)
              (( in_contexts )) || continue
              case "$line" in
                "- context:"*)
                  pending=""
                  ;;
                "    namespace: "*)
                  pending="''${line#    namespace: }"
                  pending="''${pending//\"/}"
                  pending="''${pending//$q/}"
                  ;;
                "  name: "*)
                  key="''${line#  name: }"
                  key="''${key//\"/}"
                  key="''${key//$q/}"
                  ns_of["$key"]="$pending"
                  pending=""
                  ;;
              esac
              ;;
          esac
        done < "$cfg"

        current="''${current//\"/}"
        current="''${current//$q/}"
        [[ -n "$current" ]] || return

        local ns="''${ns_of[$current]:-default}"
        current="''${current//[\\\$\`]/}"
        ns="''${ns//[\\\$\`]/}"

        __prompt_env+=" ''${__prompt_magenta}''${__icon_k8s} ''${current}/''${ns}''${__prompt_reset}"
      }


      # ------------------------------------------------------------
      # Docker
      # ------------------------------------------------------------

      __prompt_docker() {
        [[ -n "$DOCKER_CONTEXT" && "$DOCKER_CONTEXT" != default ]] || return

        __prompt_env+=" ''${__prompt_cyan}''${__icon_docker} docker:''${DOCKER_CONTEXT//[\\\$\`]/}''${__prompt_reset}"
      }


      # ------------------------------------------------------------
      # AWS
      # ------------------------------------------------------------

      __prompt_aws() {
        [[ -n "$AWS_PROFILE" ]] || return

        __prompt_env+=" ''${__prompt_yellow}''${__icon_aws} aws:''${AWS_PROFILE//[\\\$\`]/}''${__prompt_reset}"
      }


      # ------------------------------------------------------------
      # SSH
      # ------------------------------------------------------------

      __prompt_ssh() {
        [[ -n "$SSH_CONNECTION" ]] || return

        __prompt_env+=" ''${__prompt_red}''${__icon_ssh} SSH''${__prompt_reset}"
      }


      # ------------------------------------------------------------
      # Prompt
      # ------------------------------------------------------------

      __prompt_command() {
        local exit_code=$?

        local user_color="$__prompt_green"
        [[ "$EUID" -eq 0 ]] && user_color="$__prompt_red"

        local last_status
        if (( exit_code == 0 )); then
          last_status="''${__prompt_green}✔''${__prompt_reset}"
        else
          last_status="''${__prompt_red}✘ $exit_code''${__prompt_reset}"
        fi

        __prompt_env=""
        __prompt_git
        __prompt_nix
        __prompt_python
        __prompt_terraform
        __prompt_kubernetes
        __prompt_docker
        __prompt_aws
        __prompt_ssh

        # \$ is expanded by bash at display time: "$" for users, "#" for root
        local symbol='\$'

        PS1="''${__prompt_gray}┌─''${__prompt_reset}"
        PS1+="''${user_color}\u''${__prompt_reset}"
        PS1+="''${__prompt_gray}@''${__prompt_reset}"
        PS1+="''${__prompt_bright_cyan}\h''${__prompt_reset}"
        PS1+=" ''${__prompt_gray}in''${__prompt_reset}"
        PS1+=" ''${__prompt_blue}\w''${__prompt_reset}"
        PS1+="''${__prompt_env}"
        PS1+=$'\n'
        PS1+="''${__prompt_gray}└─''${__prompt_reset}"
        PS1+="''${last_status}"
        PS1+=" ''${__prompt_bold}''${__prompt_white}''${symbol}''${__prompt_reset} "
      }


      # Preserve any existing PROMPT_COMMAND, but don't add ourselves twice.
      [[ "$PROMPT_COMMAND" == *__prompt_command* ]] ||
        PROMPT_COMMAND="__prompt_command''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    '';
  };
}
