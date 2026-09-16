{ ... }:
{
  services.xserver.wacom.enable = true;
  services.libinput.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
