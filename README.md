# NixOS: niri + quickshell + nvidia-open

## Directory structure

```
nixos-config/
├── flake.nix                       # inputs + wires a host's config + its user's home.nix together
├── flake.lock                      # generated on first build; commit it
├── .gitignore
├── README.md
│
├── hosts/
│   └── nixos/                      # one directory per machine; name = its hostname
│       ├── configuration.nix       # only what's specific to THIS machine
│       ├── disko.nix                #   (disk layout, hostname, boot loader, timezone...)
│       └── hardware-configuration.nix
│
├── modules/
│   └── desktop.nix                 # shared system config: networking, nvidia, niri,
│                                    # audio, bluetooth, flatpak, fonts -- identical
│                                    # across every machine that imports it
│
└── home/
    └── you/                        # one directory per user; name = their username
        ├── home.nix
        └── nixvim.nix
```

Why split it this way:

- **`hosts/<name>/`** holds only what's genuinely tied to one physical
  machine: which disk to partition, the hostname, the boot loader, the
  timezone, which user accounts exist on it. Add a laptop later by copying
  this directory to `hosts/laptop/`, writing its own `disko.nix` and
  `hardware-configuration.nix`, and adjusting the handful of settings in its
  `configuration.nix`.
- **`modules/desktop.nix`** holds everything that should be *identical*
  everywhere: the systemd-networkd/resolved setup, nvidia-open, niri,
  pipewire, bluetooth, flatpak, fonts. Every host's `configuration.nix`
  just does `imports = [ ../../modules/desktop.nix ];` and gets all of it.
  If you later want, say, power-saving tweaks only on the laptop, that goes
  directly in `hosts/laptop/configuration.nix` instead, or you split
  `modules/desktop.nix` further into smaller pieces (`modules/nvidia.nix`,
  `modules/niri.nix`, ...) once it's worth the indirection -- not needed yet
  for one machine.
- **`home/<username>/`** is the home-manager side, kept separate from
  `hosts/` on purpose: your dotfiles and personal packages aren't really
  *about* any one machine, they're about *you*. `flake.nix` references it as
  `./home/${username}/home.nix`, so a second user just needs their own
  `home/<theirname>/` directory.

For now there's exactly one host and one user, so this looks like a lot of
scaffolding for not much -- that's intentional; it costs nothing today and
means "I bought a laptop" later is a new directory, not a rewrite.

## What is home-manager, and why is it here?

NixOS configuration (`hosts/<name>/configuration.nix` + `modules/desktop.nix`)
manages the *system*: services,
drivers, users that exist, system-wide packages. It's analogous to editing
`/etc` by hand on Arch, except declarative and reproducible.

**home-manager** manages a *user's* environment the same declarative way:
dotfiles, per-user packages, shell config, application settings (git,
niri, neovim, etc). You could put everything in `configuration.nix` as
`environment.systemPackages`, but then it's system-wide and root-owned, and
you can't easily reuse the same user config on a second machine independent
of the OS config. Splitting them (as this config does, into `home/you/`) means
your personal environment is portable: the same `home.nix` would work if you
ever install home-manager standalone on a non-NixOS Linux box, or add a
second user with a different setup on this same machine.

Here it's wired in as a **NixOS module** (see the `home-manager.nixosModules`
bit in `flake.nix`), so `sudo nixos-rebuild switch` rebuilds your system
*and* your user environment in one shot, in one atomic generation. That's a
style choice, not a requirement -- the alternative is running
`home-manager switch` as your own user, separately from system rebuilds.

## Is flatpak OK on NixOS?

Yes, and it's genuinely the path of least resistance for a handful of GUI
apps like yours, rather than packaging each one in Nix. `services.flatpak.enable
= true;` in `modules/desktop.nix` does it. After your first `nixos-rebuild
switch`, add the flathub remote once:

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.telegram.desktop com.spotify.Client md.obsidian.Obsidian app.zen_browser.zen -y
```

(Nix can also install these declaratively via community modules, but plain
`flatpak install` is simpler and exactly matches your existing script.)

## Package mapping (your pacman list -> this config)

| pacman package | where it went |
|---|---|
| alacritty, git, tmux, vifm, ripgrep, fd, jq, bc, lsof, unzip | `home/you/home.nix` packages |
| neovim | replaced by `home/you/nixvim.nix` (see below) |
| pipewire, wireplumber, pipewire-pulse | `services.pipewire` in `modules/desktop.nix` (one service, not 3 packages) |
| pulsemixer, playerctl | `home/you/home.nix` packages |
| bluez, bluez-utils | `hardware.bluetooth.enable` in `modules/desktop.nix` |
| bluetui | `home/you/home.nix` packages |
| slurp, grim, wl-clipboard, cliphist | `home/you/home.nix` packages |
| flatpak | `services.flatpak.enable` in `modules/desktop.nix` |
| libnotify | `home/you/home.nix` packages, **plus `mako` added** -- libnotify alone is just the client library that lets apps *send* notifications (`notify-send`); something needs to *display* them. Add whichever daemon you actually used on sway if it wasn't mako (dunst, swaync, ...). |
| ttf-firacode-nerd, ttf-jetbrains-mono-nerd | `fonts.packages` in `modules/desktop.nix` |

## neovim vs nixvim

I went with **nixvim** (`home/you/nixvim.nix`) rather than plain `neovim` +
hand-written `init.lua`, since you asked "maybe nixvim." It gives you a
solid starting point (LSP, treesitter, telescope, completion, statusline)
expressed as Nix attributes instead of Lua, which fits naturally into a
flake-based setup and keeps your editor config version-controlled alongside
everything else. If you'd rather keep an existing Lua config as-is, this is
easy to rip out: delete `home/you/nixvim.nix`, remove it from `home.nix`'s
`imports`, add `neovim` back to `home.packages`, and symlink your existing
`~/.config/nvim` via `home.file` instead.

## Niri without a greeter

`programs.niri.enable = true;` installs niri and wires up XDG portals
automatically. Since you don't want a greeter yet:

- `services.getty.autologinUser` auto-logs you into a text console on tty1.
- Your shell (`home/you/home.nix`, `programs.zsh.initExtra`) detects it's on
  tty1 with no Wayland session running yet, and `exec`s `niri-session`.

When you do want a greeter later, the cleanest option is
[greetd](https://wiki.nixos.org/wiki/Greetd) with a minimal greeter like
`tuigreet` or `regreet`, launching `niri-session` as the session command.
At that point you'd remove the autologin + shell-exec approach above.

Niri itself: on first launch it writes a commented default config to
`~/.config/niri/config.kdl` if none exists -- edit that by hand to start.
Once it's stable, you can move it into home-manager for reproducibility
using home-manager's niri module (`programs.niri.settings`), which this
config doesn't set up yet to keep the first boot simple.

## quickshell

Quickshell doesn't ship a NixOS or home-manager module (as of writing), so
it's installed as a plain package from its own flake input
(`inputs.quickshell.packages.${system}.default` in `home.nix`). You write
its QML config the normal quickshell way, under `~/.config/quickshell/`.

## Install steps

1. Boot the NixOS installer ISO, get networking up (`iwctl` or ethernet).
2. Edit `hosts/nixos/disko.nix`: replace `/dev/disk/by-id/REPLACE-ME` with
   your actual disk (`ls -l /dev/disk/by-id/`), and adjust the swap
   partition size.
3. Edit `flake.nix`: set `hostname` and `username` to real values. If you
   rename either, rename the matching directory too: `hosts/nixos/` →
   `hosts/<hostname>/`, `home/you/` → `home/<username>/` -- and update
   `networking.hostName` inside `hosts/<hostname>/configuration.nix` to match.
4. Partition and mount with disko, from the installer:
   ```bash
   nix run github:nix-community/disko -- --mode destroy,format,mount ./hosts/nixos/disko.nix
   ```
5. Generate hardware info (see the comment at the top of
   `hardware-configuration.nix` for exactly what to keep):
   ```bash
   nixos-generate-config --no-filesystems --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/nixos/hardware-configuration.nix
   ```
6. Copy this whole directory into `/mnt/etc/nixos/` (or wherever you'll keep
   it -- it's just a git repo, feel free to clone it there instead), then:
   ```bash
   sudo nixos-install --flake /mnt/etc/nixos#nixos
   ```
7. Reboot. Set a password for your user if `nixos-install` didn't prompt you
   for one already.
8. After boot, from inside the checked-out config:
   ```bash
   sudo nixos-rebuild switch --flake .#nixos
   ```
   is how you apply future changes.

## Things you should double-check / adjust

- `time.timeZone` and `i18n.defaultLocale` in `hosts/nixos/configuration.nix`.
- `hardware.nvidia.open = true` (in `modules/desktop.nix`) requires an
  RTX 20-series/GTX 16-series GPU or newer. If yours is older, set it to
  `false` (proprietary driver).
- `hardware.nvidia.powerManagement.enable` -- leave `false` on desktop,
  consider `true` on a laptop if suspend/resume misbehaves.
- `system.stateVersion` in both `hosts/nixos/configuration.nix` and
  `home/you/home.nix` -- set to whatever release your installer actually is
  (`nixos-version`), and then never change it afterwards.
- `services.resolved.dnssec` is set to `"false"` to avoid surprises; tighten
  it once you've confirmed your resolver/DNS setup supports DNSSEC.
