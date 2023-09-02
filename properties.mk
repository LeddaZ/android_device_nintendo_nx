# AV
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.media.avsync=true

# Bpf
PRODUCT_PROPERTY_OVERRIDES += \
    ro.kernel.ebpf.supported=1

# CEC
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hdmi.cec.source.playback_device_action_on_routing_control=wake_up_and_send_active_source

# Charger
PRODUCT_SYSTEM_PROPERTY_OVERRIDES += \
    persist.sys.NV_ECO.IF.CHARGING=false

# GameStream
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.gamestream.display.optimize=1

# HWC
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.tegra.stb.mode=0

# NVWFD
PRODUCT_PROPERTY_OVERRIDES += \
    nvwfd.gamemode=1 \
    nvwfd.max_macroblocks=8160

# Sensors
PRODUCT_PROPERTY_OVERRIDES += \
	persist.vendor.stm.sensors.max-odr = 2000 \
	persist.vendor.stm.sensors.rot-matrix-1.accel = "0,1,0,-1,0,0,0,0,1" \
	persist.vendor.stm.sensors.rot-matrix-1.gyro = "0,1,0,-1,0,0,0,0,1" \
	persist.vendor.stm.sensors.max-range.accel = 79 \
	persist.vendor.stm.sensors.max-range.gyro = 35

# SF
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.sf.vrr.enabled=1 \
    ro.vendor.surface_flinger.use_frame_rate_api=false \
    ro.vendor.sf.override_lcd_density=1

# USB configfs
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.sys.usb.udc=700d0000.xudc \
    sys.usb.controller=700d0000.xudc
