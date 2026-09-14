# packages/meet-control/default.nix
#
# A standalone package derivation, meant to be loaded via `pkgs.callPackage`
# (see flake.nix). Using writeShellApplication instead of the old inline
# writeShellScriptBin gets you two things for free:
#   - the script is run through shellcheck at build time
#   - the wrapper adds `set -euo pipefail` and a clean PATH built from
#     runtimeInputs, instead of inheriting whatever's on your shell's PATH
{ lib, writeShellApplication, ... }:

writeShellApplication {
  name = "meet-control";

  # Any CLI tools the script shells out to (e.g. wpctl, playerctl, notify-send)
  # go here so the wrapped script always finds them regardless of caller PATH.
  runtimeInputs = [
    # pkgs.playerctl
    # pkgs.libnotify
  ];

  text = builtins.readFile ../../scripts/meet-control.sh;

  meta = with lib; {
    description = "Control script for meeting/webcam state";
    platforms = platforms.linux;
  };
}
