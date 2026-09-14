{ ... }:
{
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
