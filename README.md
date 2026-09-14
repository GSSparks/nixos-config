# nixos-config

Flake-based NixOS + home-manager configuration for `gsparks-sitespect`.

## Layout

```
flake.nix / flake.lock       entry point — inputs, nixosConfigurations, packages
hosts/<name>/                per-machine config + generated hardware-configuration.nix
modules/                     system-wide config, grouped by concern, shared across hosts
home/                        home-manager (per-user) config
overlays/                    package overrides (e.g. pinned _1password-cli)
packages/                    custom packages exposed as flake outputs (e.g. meet-control)
secrets/                     agenix-encrypted secrets + secrets.nix recipient list
scripts/                     raw scripts consumed by packages/ derivations
```

## First-time setup on a new machine

1. Clone this repo, e.g. to `~/nixos-config`.
2. Symlink it into place (optional, but keeps `/etc/nixos` muscle memory working):
   ```bash
   sudo ln -s ~/nixos-config /etc/nixos
   ```
3. **DisplayLink driver — manual step required, see below.**
4. Build without switching, to confirm everything evaluates:
   ```bash
   nixos-rebuild build --flake .#gsparks-sitespect
   ```
5. If that succeeds, switch for real:
   ```bash
   sudo nixos-rebuild switch --flake .#gsparks-sitespect
   ```

## DisplayLink driver (manual, per-machine)

`pkgs.displaylink` cannot legally redistribute Synaptics' binary driver, so nixpkgs
requires you to fetch it once yourself and hand it to the local Nix store. This is a
**local store step, not something tracked in this repo** — every machine that builds
this config needs to do it once.

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

## Overlays

`overlays/default.nix` currently pins `_1password-cli` to a specific vendor-provided
build. If you're revisiting this, check whether nixpkgs's own version has since
caught up (`nix eval nixpkgs#_1password-cli.version`) before assuming the pin is
still necessary.

## Everyday commands

```bash
nixos-rebuild build --flake .#gsparks-sitespect    # build only, verify it evaluates
sudo nixos-rebuild switch --flake .#gsparks-sitespect   # build + activate now
sudo nixos-rebuild switch --flake .#gsparks-sitespect --rollback   # roll back
```

(The `rebuild` / `rebuild-test` aliases in `home/gsparks.nix` wrap the first two.)
