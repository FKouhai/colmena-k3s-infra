{
  disko.devices = {
    disk.sdb = {
      type = "disk";
      device = "/dev/sdb";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0022" "dmask=0022" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };

    # Dedicated disk for microvm image files — keeps VM data off the OS disk.
    # sdc–sdh are the old Harvester VM loop-backed disks; leave them alone.
    disk.sda = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions.vms = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/var/lib/microvms";
          };
        };
      };
    };
  };
}
