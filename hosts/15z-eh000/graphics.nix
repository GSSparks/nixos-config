{ pkgs, ... }:
{
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr
  ];
}
