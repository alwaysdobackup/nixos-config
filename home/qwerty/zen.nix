{ config, pkgs, ... }:

let
  zenPolicies = {
    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };

        "446900e4-71c2-419f-a6a7-df9c091e268b" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };
      };
    };
  };
in
{
  services.flatpak.packages = [
    "app.zen_browser.zen"
  ];

  home.file.".config/zen/policies.json".text =
    builtins.toJSON zenPolicies;
}

