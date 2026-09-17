{ config, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:GSSparks/nixos-config#${config.networking.hostName}";
    allowReboot = false;
  };

  nixpkgs.config.allowUnfree = true;
}
