{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./desktop.nix
    ./packages.nix

    ../../modules/common/boot.nix
    ../../modules/common/nix.nix
    ../../modules/common/locale.nix
    ../../modules/common/packages.nix
    ../../modules/common/security.nix
    ../../modules/common/networking.nix
    ../../modules/common/vim.nix

    ../../modules/desktop/desktop.nix
  ];

  networking.hostName = "lenovo-yoga-11e";

  # This laptop travels — let it auto-detect timezone rather than pin
  # modules/common/locale.nix's static America/New_York.
  services.automatic-timezoned.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 53317 ]; # localsend
    allowedUDPPorts = [ 53317 ];
  };

  services.openssh.openFirewall = true;

  # Client-only here, unlike the "both" set in modules/common/networking.nix.
  services.tailscale.useRoutingFeatures = lib.mkForce "client";

  programs.kdeconnect.enable = true;

  users.users.gsparks = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ firefox ];
  };

  # Declan's account — blank password, so he can click through to his
  # desktop without typing anything. This only affects local/console
  # login via SDDM; sshd already refuses empty-password auth by default
  # regardless of this setting, so remote access isn't weakened by it.
  users.users.declan = {
    isNormalUser = true;
    description = "Declan";
    hashedPassword = "";
  };

  system.stateVersion = "23.11"; # do not change
}
