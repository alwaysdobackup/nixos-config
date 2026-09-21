# openvpn-work.nix
#
# On-demand OpenVPN client for NixOS:
#   - secrets encrypted with sops-nix (safe for a public repo)
#   - routes and DNS pushed by the server
#   - DNS handed to systemd-resolved via update-systemd-resolved
#   - full tunnel by default (fullTunnel = true); set it to false below to
#     ignore the pushed default gateway and keep only the pushed routes
#   - not started at boot: `systemctl start openvpn-work`
#
# ---------------------------------------------------------------------------
# ONE-TIME SETUP
# ---------------------------------------------------------------------------
#
# 1) flake.nix: add the input and the module
#
#    inputs.sops-nix = {
#      url = "github:Mic92/sops-nix";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#
#    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
#      modules = [
#        sops-nix.nixosModules.sops
#        ./configuration.nix
#        ./openvpn-work.nix
#      ];
#    };
#
# 2) age keys
#
#    # host key (public part), derived from the SSH host key:
#    nix-shell -p ssh-to-age --run \
#      'ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub'
#
#    # personal key for editing secrets (BACK IT UP, never commit it):
#    mkdir -p ~/.config/sops/age
#    nix-shell -p age --run 'age-keygen -o ~/.config/sops/age/keys.txt'
#
# 3) .sops.yaml in the repo root (public keys only, safe to commit)
#
#    keys:
#      - &me   age1your_personal_public_key...
#      - &host age1your_host_public_key...
#    creation_rules:
#      - path_regex: secrets/[^/]+\.yaml$
#        key_groups:
#          - age: [*me, *host]
#
# 4) Create/edit the encrypted secrets (sops encrypts on save):
#
#    nix-shell -p sops --run 'sops secrets/secrets.yaml'
#
#    vpn:
#      remote: xxx.xxx.xxx.xxx            # IP/hostname only, no port
#      server-name: server_xxxxxxxx    # value of verify-x509-name
#      ca: |
#        -----BEGIN CERTIFICATE-----
#        ...
#      cert: |
#        -----BEGIN CERTIFICATE-----
#        ...
#      key: |
#        -----BEGIN PRIVATE KEY-----
#        ...
#      tls-crypt: |
#        -----BEGIN OpenVPN Static key V1-----
#        ...
#
#    (If your setup uses tls-auth instead of tls-crypt, or a username and
#     password, adjust the config below accordingly.)
#
# 5) .gitignore
#
#    *.ovpn
#    *.key
#    *.pem
#    *.crt
#    keys.txt
#
# ---------------------------------------------------------------------------

{ config, pkgs, lib, ... }:

let
  # true : all traffic goes through the VPN while it is running
  # false: ignore the pushed default gateway (only pushed routes + DNS apply)
  fullTunnel = true;

  resolvedScript =
    "${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved";
in
{
  # -------------------------------------------------------------------------
  # Networking: networkd + resolved
  # -------------------------------------------------------------------------
  # Your physical interfaces (systemd.network.networks.*) stay as you have
  # them. Do not enable NetworkManager at the same time.
  networking.useNetworkd = true;
  services.resolved.enable = true;

  # OpenVPN installs the pushed routes itself. Without this, networkd may
  # remove them as "foreign" routes when it reloads (e.g. on nixos-rebuild).
  systemd.network.config.networkConfig.ManageForeignRoutes = false;

  # Intentionally NO systemd.network.networks."xx-vpn" block for tun0:
  # a .network file matching tun0 would let networkd reset the DNS settings
  # that update-systemd-resolved pushes into resolved.

  # -------------------------------------------------------------------------
  # Secrets (sops-nix)
  # -------------------------------------------------------------------------
  # This file lives in hosts/workstation/, secrets in <repo>/secrets/
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Decrypted to /run/secrets/... at activation, never into /nix/store.
  sops.secrets."vpn/remote" = { };
  sops.secrets."vpn/server-name" = { };
  sops.secrets."vpn/ca" = { };
  sops.secrets."vpn/cert" = { };
  sops.secrets."vpn/key" = { };
  sops.secrets."vpn/tls-crypt" = { };

  # Rendered at activation with the real hostname substituted in.
  # Key material is referenced by file path, so multi-line values are fine.
  sops.templates."work.ovpn".content = ''
    client
    dev tun0
    dev-type tun
    proto tcp-client
    remote ${config.sops.placeholder."vpn/remote"} 1194
    resolv-retry infinite
    nobind
    persist-key
    persist-tun
    remote-cert-tls server
    verify-x509-name ${config.sops.placeholder."vpn/server-name"} name
    auth SHA256
    auth-nocache
    cipher AES-128-GCM
    tls-client
    tls-version-min 1.2
    tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
    verb 3

    ca        ${config.sops.secrets."vpn/ca".path}
    cert      ${config.sops.secrets."vpn/cert".path}
    key       ${config.sops.secrets."vpn/key".path}
    tls-crypt ${config.sops.secrets."vpn/tls-crypt".path}
  '';

  # -------------------------------------------------------------------------
  # OpenVPN client
  # -------------------------------------------------------------------------
  services.openvpn.servers.work = {
    autoStart = false;          # start manually: systemctl start openvpn-work
    updateResolvConf = false;   # resolved handles DNS via the script below
    config = ''
      config ${config.sops.templates."work.ovpn".path}

      ${lib.optionalString (!fullTunnel) ''
        # Split tunnel: accept pushed routes and DNS, but not the pushed
        # default gateway, so normal traffic keeps using your real connection.
        pull-filter ignore "redirect-gateway"
      ''}
      # Hand pushed DNS to systemd-resolved
      script-security 2
      setenv PATH ${pkgs.coreutils}/bin
      up ${resolvedScript}
      up-restart
      down ${resolvedScript}
      down-pre
    '';
  };

  # -------------------------------------------------------------------------
  # Optional: start/stop without a password prompt (members of "wheel" only,
  # and only for this one unit). Uncomment if you want it.
  # -------------------------------------------------------------------------
  # security.polkit.extraConfig = ''
  #   polkit.addRule(function(action, subject) {
  #     if (action.id == "org.freedesktop.systemd1.manage-units" &&
  #         action.lookup("unit") == "openvpn-work.service" &&
  #         subject.isInGroup("wheel")) {
  #       return polkit.Result.YES;
  #     }
  #   });
  # '';
}
