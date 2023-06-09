#!/vendor/bin/sh

# Copyright (c) 2017-2019, NVIDIA CORPORATION. All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.

scriptName=$0

# Read the Board/Platform name
hardwareName=$(getprop ro.hardware)

/vendor/bin/log -t "$scriptName" -p i "*** STARTING LKM LOADER FOR ***:" $hardwareName

do_insmod()
{
if [ -e "$1" ]; then
        insmod $@ > /dev/kmsg 2>&1
fi
}

#====================================================================================
# Early load is for loading modules "on fs"
early_load()
{
# list of Vendor modules
# insmod /vendor/lib/modules/example1.ko
/vendor/bin/log -t "$scriptName" -p i "Early Loading LKM SoC-Vendor modules started"

do_insmod /vendor/lib/modules/pcie-tegra-dw.ko
do_insmod /vendor/lib/modules/pci-tegra.ko

/vendor/bin/log -t "$scriptName" -p i "Loading LKM nvgpu started"
do_insmod /vendor/lib/modules/nvgpu.ko
/vendor/bin/log -t "$scriptName" -p i "Loading LKM nvgpu completed"

# Realtek R8168 drivers
do_insmod /vendor/lib/modules/r8168.ko

# load COMMS drivers
do_insmod /vendor/lib/modules/bluedroid_pm.ko
if [ "`cat /proc/device-tree/brcmfmac_pcie_wlan/status`" = "okay" ]; then
        /vendor/bin/log -t "wifiloader" -p i " Loading brcmfmac driver for wlan"
        do_insmod /vendor/lib/modules/compat.ko
        do_insmod /vendor/lib/modules/cfg80211.ko
        do_insmod /vendor/lib/modules/brcmutil.ko
        do_insmod /vendor/lib/modules/brcmfmac.ko
fi

# USB-to-serial driver
do_insmod /vendor/lib/modules/usbserial.ko
do_insmod /vendor/lib/modules/ftdi_sio.ko
/vendor/bin/log -t "$scriptName" -p i "loading usb serial modules completed"

/vendor/bin/log -t "$scriptName" -p i "loading vendor audio modules started"
# HDA audio driver
do_insmod /vendor/lib/modules/snd-hda-tegra.ko

# APE audio drivers
do_insmod /vendor/lib/modules/snd-soc-tegra-alt-utils.ko
do_insmod /vendor/lib/modules/snd-soc-tegra210-alt-xbar.ko
do_insmod /vendor/lib/modules/tegra210-adma.ko
do_insmod /vendor/lib/modules/snd-soc-tegra210-alt-admaif.ko
do_insmod /vendor/lib/modules/snd-soc-tegra-virt-alt-ivc.ko
do_insmod /vendor/lib/modules/snd-soc-tegra210-alt-adsp.ko
do_insmod /vendor/lib/modules/snd-soc-tegra210-alt-sfc.ko
do_insmod /vendor/lib/modules/snd-soc-tegra210-alt-i2s.ko
do_insmod /vendor/lib/modules/snd-soc-tegra210-alt-mixer.ko
do_insmod /vendor/lib/modules/snd-soc-tegra210-alt-afc.ko
do_insmod /vendor/lib/modules/snd-soc-tegra210-alt-adx.ko
do_insmod /vendor/lib/modules/snd-soc-tegra210-alt-amx.ko
do_insmod /vendor/lib/modules/snd-soc-tegra210-alt-dmic.ko
do_insmod /vendor/lib/modules/snd-soc-tegra210-alt-mvc.ko
do_insmod /vendor/lib/modules/snd-soc-tegra210-alt-ope.ko
/vendor/bin/log -t "$scriptName" -p i "loading vendor audio modules completed"

do_insmod /vendor/lib/modules/cpufreq_schedutil.ko
do_insmod /vendor/lib/modules/cpufreq_conservative.ko
do_insmod /vendor/lib/modules/cpufreq_powersave.ko
do_insmod /vendor/lib/modules/cpufreq_userspace.ko
do_insmod /vendor/lib/modules/cpufreq_ondemand.ko

# DEVFREQ governors
do_insmod /vendor/lib/modules/governor_userspace.ko
do_insmod /vendor/lib/modules/governor_pod_scaling.ko
do_insmod /vendor/lib/modules/governor_wmark_active.ko
# Security
do_insmod /vendor/lib/modules/echainiv.ko
do_insmod /vendor/lib/modules/af_alg.ko
do_insmod /vendor/lib/modules/algif_skcipher.ko
do_insmod /vendor/lib/modules/algif_hash.ko
do_insmod /vendor/lib/modules/cryptd.ko
do_insmod /vendor/lib/modules/crypto_simd.ko
do_insmod /vendor/lib/modules/ecc.ko
do_insmod /vendor/lib/modules/ecdsa_generic.ko
do_insmod /vendor/lib/modules/twofish_common.ko
do_insmod /vendor/lib/modules/twofish_generic.ko
do_insmod /vendor/lib/modules/ablk_helper.ko
do_insmod /vendor/lib/modules/ecdh_generic.ko
do_insmod /vendor/lib/modules/aes-ce-cipher.ko
do_insmod /vendor/lib/modules/aes-ce-ccm.ko
do_insmod /vendor/lib/modules/sha1-ce.ko
do_insmod /vendor/lib/modules/sha2-ce.ko
do_insmod /vendor/lib/modules/sha512-arm64.ko
do_insmod /vendor/lib/modules/aes-ce-blk.ko
do_insmod /vendor/lib/modules/gf128mul.ko
do_insmod /vendor/lib/modules/ghash-ce.ko
do_insmod /vendor/lib/modules/aes-neon-blk.ko
do_insmod /vendor/lib/modules/aes-neon-bs.ko
do_insmod /vendor/lib/modules/tegra-se.ko
do_insmod /vendor/lib/modules/tegra-se-elp.ko
do_insmod /vendor/lib/modules/tegra-se-nvhost.ko
do_insmod /vendor/lib/modules/tegra-cryptodev.ko
do_insmod /vendor/lib/modules/trusty.ko
do_insmod /vendor/lib/modules/trusty-irq.ko
do_insmod /vendor/lib/modules/virtio.ko
do_insmod /vendor/lib/modules/virtio_ring.ko
do_insmod /vendor/lib/modules/trusty-log.ko
do_insmod /vendor/lib/modules/trusty-ipc.ko
do_insmod /vendor/lib/modules/trusty-ote.ko
do_insmod /vendor/lib/modules/trusty-otf-iface.ko
do_insmod /vendor/lib/modules/trusty-mem.ko
do_insmod /vendor/lib/modules/trusty-virtio.ko

# Peripheral
do_insmod /vendor/lib/modules/core.ko
do_insmod /vendor/lib/modules/input-cfboost.ko
do_insmod /vendor/lib/modules/pwm-tegra-pmc-blink.ko
do_insmod /vendor/lib/modules/pwm_fan.ko

# Joycons (make sure to load after pwm_fan to avoid excessive fanspin!)
do_insmod /vendor/lib/modules/crc8.ko
do_insmod /vendor/lib/modules/joycon-serdev.ko

# TV tuner drivers
do_insmod /vendor/lib/modules/videobuf-core.ko
do_insmod /vendor/lib/modules/videobuf-vmalloc.ko
do_insmod /vendor/lib/modules/videobuf-dvb.ko
do_insmod /vendor/lib/modules/tveeprom.ko
/vendor/bin/log -t "$scriptName" -p i "Early loading SoC-Vendor TV tuner modules completed"

/vendor/bin/log -t "$scriptName" -p i "Early Loading LKM SoC-Vendor modules completed"

#--------------------------------------------------------------------------------

# list of ODM modules
# insmod /odm/lib/modules/example2.ko
# Upstream has these on odm, but we put all modules on vendor
/vendor/bin/log -t "$scriptName" -p i "Early Loading LKM Board-ODM modules started"

/vendor/bin/log -t "$scriptName" -p i "loading odm audio modules started"
do_insmod /vendor/lib/modules/snd-soc-rt5640.ko
do_insmod /vendor/lib/modules/snd-soc-tegra-machine-driver.ko
/vendor/bin/log -t "$scriptName" -p i "loading odm audio modules completed"

# Peripheral
do_insmod /vendor/lib/modules/ina230.ko
do_insmod /vendor/lib/modules/ina3221.ko

/vendor/bin/log -t "$scriptName" -p i "Loading vendor gpio timed keys module for early mode started"
do_insmod /vendor/lib/modules/gpio_timed_keys.ko
/vendor/bin/log -t "$scriptName" -p i "Loading vendor gpio timed keys module for early mode completed"

# TV tuner drivers
do_insmod /vendor/lib/modules/lgdt3306a.ko
do_insmod /vendor/lib/modules/si2168.ko
do_insmod /vendor/lib/modules/si2157.ko
do_insmod /vendor/lib/modules/lgdt3305.ko
do_insmod /vendor/lib/modules/tda18272.ko
do_insmod /vendor/lib/modules/em28xx.ko
do_insmod /vendor/lib/modules/em28xx-dvb.ko
do_insmod /vendor/lib/modules/em28xx-rc.ko
do_insmod /vendor/lib/modules/cx25840.ko
do_insmod /vendor/lib/modules/cx2341x.ko
do_insmod /vendor/lib/modules/cx231xx.ko
do_insmod /vendor/lib/modules/cx231xx-dvb.ko
/vendor/bin/log -t "$scriptName" -p i "Early loading ODM TV tuner modules completed"
}

#===================================================================================

# Normal load is for loading on boot
normal_load()
{
# list of Vendor modules
# insmod /vendor/lib/modules/example1.ko
/vendor/bin/log -t "$scriptName" -p i "Loading LKM SoC-Vendor modules started"

do_insmod /vendor/lib/modules/usb-storage.ko
#do_insmod /vendor/lib/modules/uas.ko
do_insmod /vendor/lib/modules/cdc-acm.ko

do_insmod /vendor/lib/modules/ozwpan.ko
do_insmod /vendor/lib/modules/hid-nvidia-blake.ko
do_insmod /vendor/lib/modules/hid-jarvis-remote.ko
do_insmod /vendor/lib/modules/hid-xinmo.ko
do_insmod /vendor/lib/modules/hid-betopff.ko

/vendor/bin/log -t "$scriptName" -p i "Loading LKM SoC-Vendor modules completed"
}

#--------------------------------------------------------------------------------

# if [ "$1" = "recovery" ]; then
#   Use BoardConfig.mk and init.recovery.lkm*.rc instead
if [ "$1" = "early" ]; then
    early_load
else
    normal_load
fi

