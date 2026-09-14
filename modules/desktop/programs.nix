{ pkgs, ... }:
{
  programs.kdeconnect.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      libffi
      libxml2
      libxslt
      portaudio
      sqlite
      glib
      curl
    ];
  };
}
