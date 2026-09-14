{ pkgs, ... }:
{
  # Reuse the exact directories the old docker container used, so the
  # existing library database, users, watch history, and plugins carry
  # over without a rescan. The official jellyfin docker image points
  # JELLYFIN_DATA_DIR and JELLYFIN_CONFIG_DIR at the same /config volume —
  # mirror that here rather than relying on the module's own default
  # relationship between dataDir and configDir.
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jellyfin";
    group = "jellyfin";
    dataDir = "/home/jellyfin/jellyfin/config";
    cacheDir = "/home/jellyfin/jellyfin/cache";
  };

  # The old container's library paths are recorded internally as
  # "/media" and "/music" (the container-internal mount points). Bind
  # mounting the real paths to those same locations on the host lets
  # Jellyfin's existing library database resolve unchanged, instead of
  # remapping library paths and risking a rescan / lost watch state.
  fileSystems."/config" = {
    device = "/home/jellyfin/jellyfin/config";
    fsType = "none";
    options = [ "bind" ];
  };
  fileSystems."/cache" = {
    device = "/home/jellyfin/jellyfin/cache";
    fsType = "none";
    options = [ "bind" ];
  };
  fileSystems."/media" = {
    device = "/home/jellyfin/server/Videos";
    fsType = "none";
    options = [ "bind" ];
  };
  fileSystems."/music" = {
    device = "/home/jellyfin/server/Music";
    fsType = "none";
    options = [ "bind" ];
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };
}
