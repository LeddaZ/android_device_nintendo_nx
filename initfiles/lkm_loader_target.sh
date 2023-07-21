#!/vendor/bin/sh

if [ "`cat /proc/device-tree/brcmfmac_pcie_wlan/status`" = "okay" ]; then
  /vendor/bin/insmod /vendor/lib/modules/compat.ko
  /vendor/bin/insmod /vendor/lib/modules/cfg80211.ko
  /vendor/bin/insmod /vendor/lib/modules/brcmutil.ko
  /vendor/bin/insmod /vendor/lib/modules/brcmfmac.ko
elif [ "`cat /proc/device-tree/bcmdhd_wlan/status`" = "okay" ]; then
  /vendor/bin/modprobe -a -d /vendor/lib/modules bcmdhd;
fi
