{ disks ? [
  "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S21GNXAG805611X"
  "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S4BENS0N804509D"
  "/dev/disk/by-id/ata-Samsung_SSD_860_QVO_1TB_S4CZNF0M710674E"
  "/dev/disk/by-id/ata-Samsung_SSD_860_QVO_1TB_S4CZNF0M710685P"
], ... }: {
  disk = {
    main1 = {
      device = builtins.elemAt disks 0;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "mdraid";
              name = "boot";
            };
          };
          ZFS = {
            end = "-32G";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
          swap = {
            size = "100%";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
        };
      };
    };
    main2 = {
      type = "disk";
      device = builtins.elemAt disks 1;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "mdraid";
              name = "boot";
            };
          };
          ZFS = {
            end = "-32G";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
          swap = {
            size = "100%";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
        };
      };
    };
    storage1 = {
      device = builtins.elemAt disks 2;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ZFS = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zstorage";
            };
          };
        };
      };
    };
    storage2 = {
      type = "disk";
      device = builtins.elemAt disks 3;
      content = {
        type = "gpt";
        partitions = {
          ZFS = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zstorage";
            };
          };
        };
      };
    };
  };
  zpool = {
    zroot = {
      type = "zpool";
      mode = "mirror";
      rootFsOptions = {
        compression = "zstd";
        "com.sun:auto-snapshot" = "false";
      };
      postCreateHook = "zfs snapshot zroot@blank";

      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
        };
        home = {
          type = "zfs_fs";
          mountpoint = "/home";
           options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
        };
        var = {
          type = "zfs_fs";
          mountpoint = "/var";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
          postCreateHook = "mkdir -p /var/data && mkdir -p /var/lib/libvirt";
        };
      };
    };
    zstorage = {
      type = "zpool";
      mode = "mirror";
      rootFsOptions = {
        compression = "zstd";
        canmount = "off";
      };
      postCreateHook = "zfs snapshot zstorage@blank";

      datasets = {
        data = {
          type = "zfs_fs";
          mountpoint = "/var/data";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
        };
        "virtual/images" = {
          type = "zfs_fs";
          mountpoint = "/var/lib/libvirt/images";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
        };
        "virtual/snapshots" = {
          type = "zfs_fs";
          mountpoint = "/var/lib/libvirt/snapshots";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
        };
        "virtual/os" = {
          type = "zfs_fs";
          mountpoint = "/var/lib/libvirt/os";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };

  mdadm = {
    boot = {
      type = "mdadm";
      level = 1;
      metadata = "1.0";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
      };
    };
  };
}
