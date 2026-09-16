{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dig
    git
    gnumake
    htop
    jq
    tmux
    tree
    usbutils
    pciutils
    wireguard-tools
  ];
}
