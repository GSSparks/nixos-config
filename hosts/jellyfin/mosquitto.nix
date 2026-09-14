{ config, ... }:
{
  services.mosquitto = {
    enable = true;
    listeners = [{
      address = "192.168.1.249";
      port = 1883;
      users.iotdevice = {
        acl = [ "readwrite frigate/#" ];
        passwordFile = config.age.secrets.mosquitto-iotdevice.path;
      };
    }];
  };
}
