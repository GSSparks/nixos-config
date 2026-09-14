{ ... }:
{
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowPing = false;
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "true";
      Domains = [ "~." ];
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
}
