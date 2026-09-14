{ ... }:
{
  services.openssh.enable = true;

  services.clamav = {
    daemon.enable = true;
    daemon.settings = {
      LogFile = "/var/log/clamav/clamav.log";
      LogTime = "yes";
    };
    updater.enable = true;
    updater.settings = {
      UpdateLogFile = "/var/log/clamav/freshclam.log";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/log/clamav 0750 clamav clamav -"
  ];

  services.logrotate.enable = true;
  services.logrotate.settings = {
    header.dateext = true;

    "/var/log/clamav/clamav.log" = {
      frequency = "yearly";
      rotate = 5;
      missingok = true;
      notifempty = true;
      compress = true;
      create = "640 clamav clamav";
      priority = 100;
    };

    "/var/log/clamav/freshclam.log" = {
      frequency = "yearly";
      rotate = 5;
      missingok = true;
      notifempty = true;
      compress = true;
      create = "640 clamav clamav";
      priority = 100;
    };
  };
}
