{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./graphics.nix
    ./networking.nix

    ../../modules/common/boot.nix
    ../../modules/common/nix.nix
    ../../modules/common/locale.nix
    ../../modules/common/packages.nix
    ../../modules/common/security.nix
    ../../modules/common/networking.nix
    ../../modules/common/vim.nix

    ../../modules/desktop/desktop.nix
    ../../modules/desktop/programs.nix
    ../../modules/desktop/packages.nix
    ../../modules/desktop/virtualisation.nix
  ];

  nixpkgs.overlays = [ (import ../../overlays) ];

  networking.hostName = "gsparks-15z-eh000";

  services.automatic-timezoned.enable = true;

  users.users.gsparks = {
    isNormalUser = true;
    description = "Gary Sparks";
    extraGroups = [ "wheel" "docker" "networkmanager" "libvirtd" ];
  };

  system.stateVersion = "25.05";
}
