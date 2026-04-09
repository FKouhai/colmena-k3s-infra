{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  services.qemuGuest.enable = true;
}
