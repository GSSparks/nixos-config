{ ... }:
{
  virtualisation.oci-containers.containers.bgutil-provider = {
    image = "docker.io/brainicism/bgutil-ytdlp-pot-provider:1.3.2";
    ports = [ "127.0.0.1:4416:4416" ];
    autoStart = true;
  };
}
