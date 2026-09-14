{ config, ... }:
{
  systemd.services.frigate.serviceConfig.SupplementaryGroups = [ "video" "render" ];

  services.frigate = {
    enable = true;
    hostname = "frigate.jellyfin.local";
    checkConfig = false;
    vaapiDriver = "i965";

    settings = {
      mqtt = {
        host = "192.168.1.249";
        port = 1883;
        topic_prefix = "frigate";
        user = "iotdevice";
        password = "{FRIGATE_MQTT_PASSWORD}";
      };

      ffmpeg = {
        hwaccel_args = "preset-vaapi";
        input_args = "preset-rtsp-restream";
      };

      record = {
        enabled = true;
        alerts.retain.days = 30;
        detections.retain.days = 30;
        continuous.days = 7;
        motion.days = 7;
      };

      snapshots = {
        enabled = true;
        retain.default = 30;
      };

      cameras = {
        porch = {
          live.streams = { "Main Stream" = "porch_main"; "Sub Stream" = "porch_sub"; };
          ffmpeg.inputs = [
            { path = "rtsp://192.168.1.249:8554/porch_sub"; roles = [ "detect" ]; }
            { path = "rtsp://192.168.1.249:8554/porch_main"; roles = [ "record" ]; }
          ];
        };

        living_room = {
          live.streams = { "Main Stream" = "living_room_main"; "Sub Stream" = "living_room_sub"; };
          ffmpeg.inputs = [
            { path = "rtsp://192.168.1.249:8554/living_room_sub"; roles = [ "detect" ]; }
            { path = "rtsp://192.168.1.249:8554/living_room_main"; roles = [ "record" ]; }
          ];
        };

        basement = {
          live.streams = { "Main Stream" = "basement_main"; "Sub Stream" = "basement_sub"; };
          ffmpeg.inputs = [
            { path = "rtsp://192.168.1.249:8554/basement_sub"; roles = [ "detect" ]; }
            { path = "rtsp://192.168.1.249:8554/basement_main"; roles = [ "record" ]; }
          ];
        };

        loft = {
          live.streams = { "Main Stream" = "loft_main"; "Sub Stream" = "loft_sub"; };
          ffmpeg.inputs = [
            { path = "rtsp://192.168.1.249:8554/loft_sub"; roles = [ "detect" ]; }
            { path = "rtsp://192.168.1.249:8554/loft_main"; roles = [ "record" ]; }
          ];
        };

        outside_garage_front = {
          live.streams = { "Main Stream" = "outside_garage_front_main"; "Sub Stream" = "outside_garage_front_sub"; };
          ffmpeg.inputs = [
            { path = "rtsp://192.168.1.249:8554/outside_garage_front_sub"; roles = [ "detect" ]; }
            { path = "rtsp://192.168.1.249:8554/outside_garage_front_main"; roles = [ "record" ]; }
          ];
          onvif = {
            host = "192.168.1.86";
            port = 10080;
            user = "admin";
            password = "{FRIGATE_RTSP_PASSWORD}";
          };
        };

        chickens = {
          live.streams = { "Main Stream" = "chickens_main"; "Sub Stream" = "chickens_sub"; };
          ffmpeg.inputs = [
            { path = "rtsp://192.168.1.249:8554/chickens_sub"; roles = [ "detect" ]; }
            { path = "rtsp://192.168.1.249:8554/chickens_main"; roles = [ "record" ]; }
          ];
        };
      };

      detect = {
        enabled = true;
        width = 640;
        height = 360;
      };

      semantic_search.enabled = false;
      face_recognition.enabled = false;
      lpr.enabled = false;
      classification.bird.enabled = false;

      version = "0.17-0";
    };
  };

  # Frigate reads {FRIGATE_*} placeholders in its config from real
  # environment variables at startup — feed them from the agenix secret
  # rather than baking them into the rendered config (which would land
  # in the Nix store in plaintext otherwise).
  systemd.services.frigate.serviceConfig.EnvironmentFile = [
    config.age.secrets.frigate-env.path
  ];
}
