{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./jellyfin.nix
    ./frigate.nix
    ./go2rtc.nix
    ./mosquitto.nix
    ./storage.nix
    ./networking.nix

    ../../modules/common/boot.nix
    ../../modules/common/nix.nix
    ../../modules/common/locale.nix
    ../../modules/common/packages.nix
    ../../modules/common/security.nix
    ../../modules/common/networking.nix
    ../../modules/common/vim.nix
  ];

  networking.hostName = "jellyfin";

  age.secrets.mosquitto-iotdevice.file = ../../secrets/mosquitto-iotdevice.age;
  age.secrets.frigate-env.file = ../../secrets/frigate-env.age;

  users.groups.jellyfin.gid = 1000;
  users.users.jellyfin = {
    isNormalUser = true;
    isSystemUser = lib.mkForce false;
    home = "/home/jellyfin";
    uid = 1000;
    group = "jellyfin";
    extraGroups = [ "wheel" "video" "render" ];
  };

  systemd.tmpfiles.rules = [
    "d /dev/shm/logs 0755 root root -"
    "d /dev/shm/logs/frigate 1777 root root -"
    "d /dev/shm/logs/go2rtc 1777 root root -"
    "d /dev/shm/logs/nginx 1777 root root -"
  ];

  environment.systemPackages = with pkgs; [
    wget
    dbus
    sqlite
    sqldiff
    snooze
    yt-dlp
    id3v2
  ];

  services.dbus.enable = true;

  system.stateVersion = "23.11"; # do not change — see original config's own warning
}
