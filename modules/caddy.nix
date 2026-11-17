{
  config,
  lib,
  pkgs,
  ...
}:
let
  forwardAuth = ''
    forward_auth https://tinyauth.fkouhailabs.net {
      uri /api/auth/traefik
      header_up Host tinyauth.fkouhailabs.net
      header_up X-Forwarded-Host {host}
      header_up X-Forwarded-Proto {scheme}
      header_up X-Forwarded-Uri {uri}
      header_up X-Forwarded-Method {method}
      copy_headers Cookie Authorization Remote-User Remote-Name Remote-Email Remote-Groups
    }
  '';
  tlsConf = ''
    tls {
      dns cloudflare {env.CF_API_TOKEN}
      resolvers 192.168.0.2 192.168.0.1
      propagation_timeout 300s
    }

  '';
in
{
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
    };
    virtualHosts = {
      "s3.fkouhailabs.net".extraConfig = ''
        ${tlsConf}
        reverse_proxy 127.0.0.1:8333
      '';

      "filer.fkouhailabs.net".extraConfig = ''
        ${tlsConf}
        route {
          ${forwardAuth}
          reverse_proxy 127.0.0.1:8888
        }
      '';

      "seaweed-admin.fkouhailabs.net".extraConfig = ''
        ${tlsConf}
        route {
          ${forwardAuth}
          reverse_proxy 127.0.0.1:23646
        }
      '';
    };
  };
  age.secrets.caddy-env = {
    file = ../secrets/caddy-env.age;
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = [ config.age.secrets.caddy-env.path ];
}
