{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    age
    ente-auth
    jetbrains-mono
    inter
    kdePackages.k3b
    keyd
    linuxKernel.packages.linux_6_12.evdi
    mediaelch-qt6
    rpi-imager
    librashader
    spotify
    wl-screenrec
    python313Packages.bgutil-ytdlp-pot-provider
    gzdoom
  ];
}
