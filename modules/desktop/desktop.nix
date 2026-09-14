{ pkgs, ... }:
{
  environment.variables = {
    KWIN_DRM_PREFER_COLOR_DEPTH = "24";
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "plasma";
  };

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  services.printing.enable = true;

  hardware.graphics.enable = true;   # GPU-specific extraPackages set per-host
  hardware.bluetooth.enable = true;
}
