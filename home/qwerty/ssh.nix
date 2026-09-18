{ ... }:

{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "*" = {
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };

      # Example:
      #
      # "github.com" = {
      #   hostname = "github.com";
      #   user = "git";
      #   identityFile = "~/.ssh/id_ed25519";
      #   identitiesOnly = true;
      # };
    };
  };
}
