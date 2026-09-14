{ config, pkgs, ... }:
{
  networking.enableIPv6 = false;

  networking.firewall = {
    allowedTCPPorts = [ 1935 57621 ];
    allowedUDPPorts = [ 51820 5353 ];
  };
}
