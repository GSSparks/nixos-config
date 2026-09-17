final: prev: {
  _1password = prev._1password;
  _1password-gui = prev._1password-gui;
  # _1password-cli pin removed 2026-09-17 — nixpkgs had drifted 4 versions
  # ahead (2.30.3 pinned vs 2.34.0 in nixpkgs), likely cause of CLI
  # desktop-integration failures against an auto-updated 1Password app.
  # Restore from git history if a future regression needs a pin again.

  pipx = prev.pipx.overrideAttrs (old: {
    doCheck = false;
  });
}
