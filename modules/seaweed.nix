{
  config,
  lib,
  pkgs,
  ...
}:
{
  systemd.services.seaweed-s3 = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    description = "Seaweed mini S3 mode";
    serviceConfig = {
      Type = "simple";
      User = "seaweedfs";
      Group = "seaweedfs";
      StateDirectory = "seaweedfs";
      WorkingDirectory = "/var/lib/seaweedfs";
      EnvironmentFile = config.age.secrets.seaweed-s3-env.path; # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, S3_BUCKET
      ExecStart = ''
        ${lib.getExe pkgs.seaweedfs} mini -dir=/var/lib/seaweedfs/data
      '';
      Restart = "on-failure";
    };
  };

  users = {
    users.seaweedfs = {
      isSystemUser = true;
      group = "seaweedfs";
    };
    groups.seaweedfs = { };

  };

  networking.firewall.allowedTCPPorts = [ 9000 ];
  age.secrets.seaweed-s3-env = {
    file = ../secrets/seaweed-s3-env.age;
  };
}
