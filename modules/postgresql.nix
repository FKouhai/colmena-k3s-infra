# PostgreSQL on copernico (.19) — native service, no microVM.
# Hosts all six app DBs (same role/DB names as the NAS source so
# pg_dump/restore is a straight copy). Same major as source (17.x).
# Apps connect as the postgres superuser today, mirrored as-is;
# per-app least-privilege roles are a follow-up, not this move.
{
  config,
  lib,
  pkgs,
  agenix,
  ...
}:

{
  # Single shared postgres password for all DBs on this host.
  age.secrets.psql-password = {
    file = ../secrets/psql-password.age;
    owner = "postgres";
    mode = "0400";
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    # Listen on all; firewall below decides who gets in.
    enableTCPIP = true;
    # Self-contained first-init: password + DBs from the agenix
    # secret (read at runtime via psql backticks, so nothing leaks
    # into the store). Runs once ever; password rotation is manual.
    initialScript = pkgs.writeText "copernico-init.sql" ''
      \set pw `cat ${config.age.secrets.psql-password.path}`
      ALTER ROLE postgres WITH PASSWORD :'pw';
      SELECT 'CREATE DATABASE "authentik" OWNER postgres'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'authentik')\gexec
      SELECT 'CREATE DATABASE "atuin" OWNER postgres'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'atuin')\gexec
      SELECT 'CREATE DATABASE "grafana" OWNER postgres'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'grafana')\gexec
      SELECT 'CREATE DATABASE "openbao" OWNER postgres'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'openbao')\gexec
      SELECT 'CREATE DATABASE "sonarr_main" OWNER postgres'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'sonarr_main')\gexec
      SELECT 'CREATE DATABASE "sonarr_log" OWNER postgres'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'sonarr_log')\gexec
      SELECT 'CREATE DATABASE "radarr_main" OWNER postgres'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'radarr_main')\gexec
      SELECT 'CREATE DATABASE "radarr_log" OWNER postgres'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'radarr_log')\gexec
      SELECT 'CREATE DATABASE "prowlarr_main" OWNER postgres'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'prowlarr_main')\gexec
      SELECT 'CREATE DATABASE "prowlarr_log" OWNER postgres'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'prowlarr_log')\gexec
    '';
    # NOTE: pods reach .19 SNAT'd to their node's LAN IP (Cilium BPF
    # masquerades everything outside 10.42.0.0/16), so Postgres sees
    # 192.168.0.0/24 sources, never pod IPs. HBA must allow the LAN.
    authentication = lib.mkOverride 10 ''
      local all all peer
      host all all 192.168.0.0/24 scram-sha-256
      host all all 127.0.0.1/32 scram-sha-256
      host all all ::1/128 scram-sha-256
    '';
  };

  # Client tools on PATH for manual maintenance (dumps, psql).
  environment.systemPackages = [ config.services.postgresql.package ];

  # postgres_exporter for Prometheus. Runs as the postgres OS user with
  # peer auth, so no password in config. Scraped as 192.168.0.19:9187.
  services.prometheus.exporters.postgres = {
    enable = true;
    port = 9187;
    runAsLocalSuperUser = true;
  };

  # Pods reach .19 over the LAN bridge. (tailscale0 is a trusted interface,
  # so tailnet peers can also reach it — authenticated mesh, acceptable.)
  networking.firewall.interfaces.br0.allowedTCPPorts = [ 5432 9187 ];

  # Nightly compressed dumps of every hosted DB, 7-day local retention.
  # Follow-up: ship these to R2 (separate postgres-dumps bucket).
  systemd.services.postgres-dump-all = {
    description = "Nightly pg_dump of all hosted databases";
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
    };
    script = ''
      mkdir -p /var/backup/postgresql
      for db in authentik atuin grafana openbao sonarr_main sonarr_log radarr_main radarr_log prowlarr_main prowlarr_log; do
        ${config.services.postgresql.package}/bin/pg_dump "$db" \
          | ${pkgs.zstd}/bin/zstd -o /var/backup/postgresql/"$db"-$(date +%F).sql.zst
      done
      find /var/backup/postgresql -name '*.sql.zst' -mtime +7 -delete
    '';
    startAt = "02:00";
  };
}
