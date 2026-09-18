{
  disko.devices = {
    disk = {
      # ------------------------------------------------------------------
      # Disk 1: /dev/sda -- entirely /home.
      #
      # Using the raw /dev/sda path (rather than /dev/disk/by-id/...) is
      # fine as long as you're sure this disk will always enumerate as
      # sda. Since your two disks are different bus types (SATA vs NVMe),
      # that's a safe bet -- they won't compete for the same name the way
      # two SATA drives might.
      # ------------------------------------------------------------------
      home = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            home = {
              size = "900G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
              };
            };
          };
        };
      };

      # ------------------------------------------------------------------
      # Disk 2: /dev/nvme0n1 -- EFI + swap + root.
      # ------------------------------------------------------------------
      system = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            # Plain swap partition. 10G is fine for normal swap use, but
            # won't cover hibernation unless it's >= your RAM size.
            swap = {
              size = "10G";
              content = {
                type = "swap";
                resumeDevice = true; # allows resuming from hibernation, if it's big enough
              };
            };

            root = {
              size = "200G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };

            # 1G + 10G + 200G = 211G allocated. Whatever's left on this
            # NVMe beyond that is simply unpartitioned -- disko won't
            # touch it. If you'd rather root took the rest of the disk,
            # change root's size above to "100%".
          };
        };
      };
    };
  };
}
