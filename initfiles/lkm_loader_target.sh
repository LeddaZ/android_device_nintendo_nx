#!/vendor/bin/sh

if [ "`cat /proc/device-tree/brcmfmac_pcie_wlan/status`" = "okay" ]; then
  /vendor/bin/modprobe -a -d /vendor/lib/modules brcmfmac;
elif [ "`cat /proc/device-tree/bcmdhd_wlan/status`" = "okay" ]; then
  /vendor/bin/modprobe -a -d /vendor/lib/modules bcmdhd;
fi
