{ config, pkgs, ... }:
{
  boot.extraModulePackages = [ config.boot.kernelPackages.evdi ];
  boot.initrd.kernelModules = [ "evdi" ];

  systemd.services.displaylink-server = {
    enable = true;
    requires = [ "systemd-udevd.service" ];
    after = [ "systemd-udevd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
      User = "root";
      Group = "root";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  services.keyd = {
    enable = true;
    keyboards.macroboard = {
      ids = [ "1189:8890" ];
      settings.alt = {
        l = "C-d";
        k = "C-e";
        o = "C-w";
      };
    };
  };
}
