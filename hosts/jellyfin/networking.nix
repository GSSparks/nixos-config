{ ... }:
{

  networking.firewall = {
    allowedTCPPorts = [
        80    # nginx vhost the frigate module sets up in front of it
        1883  # mosquitto
        5000  # frigate UI
        8971  # frigate authenticated proxy
        8554  # go2rtc RTSP restream
        8555  # go2rtc WebRTC (tcp)
        1984  # go2rtc API/UI
    ];
    allowedUDPPorts = [
        8555  # go2rtc WebRTC (udp)
    ];
  };

  fileSystems."/home/jellyfin/server" = {
    device = "192.168.1.248:/srv/nfs/storage";
    fsType = "nfs4";
    options = [ "rw" "user" ];
  };

  fileSystems."/home/jellyfin/frigate" = {
    device = "192.168.1.248:/srv/nfs/frigate";
    fsType = "nfs4";
    options = [ "rw" "hard" "noatime" "nfsvers=4.2" ];
  };
}
