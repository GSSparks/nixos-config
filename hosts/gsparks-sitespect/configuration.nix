{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./hardware-devices.nix
    ./graphics.nix
    ./networking.nix
    /home/gsparks/.nixos-private/gsparks-sitespect.nix

    ../../modules/common/boot.nix
    ../../modules/common/nix.nix
    ../../modules/common/locale.nix
    ../../modules/common/packages.nix
    ../../modules/common/security.nix
    ../../modules/common/networking.nix

    ../../modules/desktop/desktop.nix
    ../../modules/desktop/programs.nix
    ../../modules/desktop/packages.nix
    ../../modules/desktop/virtualisation.nix
  ];

  nixpkgs.overlays = [ (import ../../overlays) ];

  networking.hostName = "gsparks-sitespect";

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "gsparks" ];
  };

  age.secrets.oddspedia-privatekey.file = ../../secrets/oddspedia-privatekey.age;
  age.secrets.oddspedia-psk.file = ../../secrets/oddspedia-psk.age;

  fileSystems."/home/gsparks" = {
    device = "/dev/disk/by-uuid/490be522-afcb-4ab2-8a4b-3c3a1984de51";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  users.users.gsparks = {
    isNormalUser = true;
    description = "Gary Sparks";
    extraGroups = [ "wheel" "docker" "networkmanager" "libvirtd" "cdrom" ];
  };

  system.stateVersion = "25.05";
}
