{ config, ... }:
{
  services.go2rtc = {
    enable = true;
    settings = {
      streams = {
        porch_main = [ ''rtsp://admin:''${FRIGATE_RTSP_PASSWORD}@192.168.1.84:10554/tcp/av0_0'' ];
        porch_sub = [ ''rtsp://admin:''${FRIGATE_RTSP_PASSWORD}@192.168.1.84:10554/tcp/av0_1'' ];

        living_room_main = [ ''rtsp://admin:''${FRIGATE_RTSP_PASSWORD}@192.168.1.80:10554/tcp/av0_0'' ];
        living_room_sub = [ ''rtsp://admin:''${FRIGATE_RTSP_PASSWORD}@192.168.1.80:10554/tcp/av0_1'' ];

        basement_main = [ ''rtsp://admin:''${FRIGATE_RTSP_PASSWORD}@192.168.1.83:10554/tcp/av0_0'' ];
        basement_sub = [ ''rtsp://admin:''${FRIGATE_RTSP_PASSWORD}@192.168.1.83:10554/tcp/av0_1'' ];

        loft_main = [ ''rtsp://admin:''${FRIGATE_RTSP_PASSWORD}@192.168.1.81:10554/tcp/av0_0'' ];
        loft_sub = [ ''rtsp://admin:''${FRIGATE_RTSP_PASSWORD}@192.168.1.81:10554/tcp/av0_1'' ];

        outside_garage_front_main = [ ''rtsp://admin:''${FRIGATE_RTSP_PASSWORD}@192.168.1.86:10554/tcp/av0_0'' ];
        outside_garage_front_sub = [ ''rtsp://admin:''${FRIGATE_RTSP_PASSWORD}@192.168.1.86:10554/tcp/av0_1'' ];

        chickens_main = [ ''rtsp://admin:''${FRIGATE_RTSP_PASSWORD}@192.168.1.87:10554/tcp/av0_0'' ];
        chickens_sub = [ ''rtsp://admin:''${FRIGATE_RTSP_PASSWORD}@192.168.1.87:10554/tcp/av0_1'' ];
      };

      webrtc.candidates = [ "192.168.1.249:8555" ];
    };
  };

  systemd.services.go2rtc.serviceConfig.EnvironmentFile = [
    config.age.secrets.frigate-env.path
  ];
}
