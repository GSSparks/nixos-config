# nixos-config

Flake-based NixOS + home-manager configuration, shared across multiple hosts:

| Host | Hardware | Role |
|---|---|---|
| `gsparks-sitespect` | Intel desktop | Primary work machine |
| `15z-eh000` | HP Pavilion 15z (AMD) laptop | Personal laptop |
| `JellyFin` | HP Elite 800 G1 | JellyFin/Frigate server |
| `lenovo-yoga-11e` | Lenovo Yoga 11e | Kid's laptop |

More hosts (a second laptop, a Raspberry Pi 4 running Kodi) are planned — see below.

## Layout

```
flake.nix / flake.lock       entry point — inputs, nixosConfigurations, packages
hosts/<name>/                per-machine config, generated hardware-configuration.nix,
                              and anything genuinely specific to that machine
modules/
  common/                    applies to every host, regardless of role
  desktop/                   applies to every KDE Plasma desktop/laptop host
home/                        home-manager (per-user) config, shared across hosts
overlays/                    package overrides (e.g. pinned _1password-cli)
packages/                    custom packages exposed as flake outputs (e.g. meet-control)
secrets/                     agenix-encrypted secrets + secrets.nix recipient list
scripts/                     raw scripts consumed by packages/ derivations
```

### How a host is assembled

Each `hosts/<name>/configuration.nix` imports:

1. Its own `hardware-configuration.nix` (never hand-edited — see below).
2. Any host-only `.nix` files it needs (extra packages, GPU-specific
   `hardware.graphics.extraPackages`, dock/peripheral quirks, VPNs, etc.).
3. `modules/common/*` — always.
4. `modules/desktop/*` — only if it's a KDE Plasma machine.

A module belongs in `modules/common/` only if **every** current and
reasonably-anticipated future host should get it (a headless Kodi box
included). If it's tied to having a desktop environment, GPU, or dock, it's
either `modules/desktop/` or host-local — not `common/`.

## First-time setup on a new machine

1. Clone this repo, e.g. to `~/nixos-config`.
2. Symlink it into place (optional, but keeps `/etc/nixos` muscle memory working):
   ```bash
   sudo ln -s ~/nixos-config /etc/nixos
   ```
3. **DisplayLink driver — manual step required on `gsparks-sitespect` only, see below.**
4. Build without switching, to confirm everything evaluates:
   ```bash
   nixos-rebuild build --flake .#<hostname>
   ```
5. If that succeeds, switch for real:
   ```bash
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

## Adding a new host

1. Generate hardware config on the new machine and copy it in:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/<name>/hardware-configuration.nix
   ```
   Never hand-edit this file — regenerate it if the hardware changes.
2. Create `hosts/<name>/configuration.nix`, importing `modules/common/*`
   (and `modules/desktop/*` if applicable), plus whatever's actually unique
   to this machine.
3. Add a `nixosConfigurations.<name>` entry in `flake.nix`. Check whether
   `system` needs to change (e.g. `aarch64-linux` for a Raspberry Pi) —
   don't assume `x86_64-linux`.
4. `nixos-rebuild build --flake .#<name>` before switching.

## DisplayLink driver (manual, per-machine — `gsparks-sitespect` only)

`pkgs.displaylink` cannot legally redistribute Synaptics' binary driver, so nixpkgs
requires you to fetch it once yourself and hand it to the local Nix store. This is a
**local store step, not something tracked in this repo** — only machines using the
DisplayLink dock (currently just `gsparks-sitespect`) need to do it.

```bash
curl -L -o "/tmp/DisplayLink USB Graphics Software for Ubuntu6.1-EXE.zip" \
  "https://www.synaptics.com/sites/default/files/exe_files/2024-10/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.1-EXE.zip"

mv "/tmp/DisplayLink USB Graphics Software for Ubuntu6.1-EXE.zip" ./displaylink-610.zip

nix-prefetch-url file://$PWD/displaylink-610.zip
```

Then `displaylink-610.zip` in your working directory can be deleted — it only needed
to exist long enough for `nix-prefetch-url` to ingest it into the store.

If a future nixpkgs bump changes the expected DisplayLink version, the build error
will show an updated filename/URL — repeat the same steps with the new values.

## Secrets

Handled with [agenix](https://github.com/ryantm/agenix). `secrets/secrets.nix` lists
which public keys can decrypt which `.age` files — both the rules file and the
encrypted `.age` files themselves are safe to commit. Only the private key that
decrypts them (this machine's own SSH host key, at `/etc/ssh/ssh_host_ed25519_key`,
root-only) is not committed, and never needs to be — it's regenerated per-install.

To edit a secret:

```bash
cd secrets
nix run github:ryantm/agenix -- -e <name>.age
```

Currently encrypted:

- `oddspedia-privatekey.age` — WireGuard private key for the `oddspedia0` interface
- `oddspedia-psk.age` — WireGuard preshared key for the same interface
- `mosquitto-iotdevice.age` - password for mosquitto
- `frigate-env.age` - password for mqtt and cameras

### Private, non-secret configuration

Some config isn't a *secret* exactly (no key material) but reveals internal
network topology (internal hostnames, VPN service names, subnet layout) that
doesn't belong in a public repo. This lives **outside the repo entirely**, at
`/home/gsparks/.nixos-private/<hostname>.nix` on the machine(s) that need it,
and is imported by absolute path from that host's `configuration.nix`. It is
not tracked by git in any form — no `.gitignore`, no intent-to-add — since
those still leave a path for the content to end up committed by accident.

This means a fresh clone of this repo will fail to evaluate for any host
that imports one of these files until that file is recreated locally at the
expected path. Keep a private backup of its contents (password manager,
private gist, encrypted note) — losing the machine also loses this file.

## Overlays

`overlays/default.nix` currently pins `_1password-cli` to a specific vendor-provided
build. If you're revisiting this, check whether nixpkgs's own version has since
caught up (`nix eval nixpkgs#_1password-cli.version`) before assuming the pin is
still necessary.

## Everyday commands

```bash
nixos-rebuild build --flake .#<hostname>            # build only, verify it evaluates
sudo nixos-rebuild switch --flake .#<hostname>       # build + activate now
sudo nixos-rebuild switch --flake .#<hostname> --rollback   # roll back
```

(The `rebuild` / `rebuild-test` aliases in `home/gsparks.nix` wrap the first two.)
