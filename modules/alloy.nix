{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.alloy = {
    enable = true;
  };
  environment.etc."alloy/config.alloy".text = ''
    loki.source.journal "read" {
      forward_to = [loki.relabel.journal.receiver]
      labels     = {job = "systemd-journal", host = "${config.networking.hostName}"}
      max_age    = "12h"
    }

    loki.relabel "journal" {
      forward_to = [loki.write.endpoint.receiver]
      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
    }

    loki.write "endpoint" {
      endpoint {
        url = "https://loki.fkouhailabs.net/loki/api/v1/push"
      }
    }
  '';

}
