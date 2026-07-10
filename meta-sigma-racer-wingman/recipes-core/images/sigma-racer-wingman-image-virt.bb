SUMMARY = "Sigma Racer Wingman virtual test image (800×480 QEMU UI stack)"
DESCRIPTION = "Minimal Sigma Racer Wingman image for local QEMU testing — Weston kiosk, \
virtual SocketCAN (vcan0), and instrumentation without OTA hardware dependencies."

LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += " \
    splash \
    ssh-server-openssh \
    tools-debug \
    debug-tweaks \
"

IMAGE_FEATURES:remove = "hwcodecs"

# Ensure psplash is present even if MACHINE_FEATURES quirks clear FEATURE_PACKAGES_splash.
IMAGE_INSTALL:append = " psplash"

IMAGE_INSTALL = " \
    packagegroup-sigma-racer-wingman-core \
    packagegroup-sigma-racer-wingman-graphics \
    packagegroup-sigma-racer-wingman-vehicle \
    sigma-racer-wingman-services \
    sigma-racer-vehicle \
    sigma-racer-cluster \
    ${CORE_IMAGE_EXTRA_INSTALL} \
"

SYSTEMD_DEFAULT_TARGET = "graphical.target"

IMAGE_ROOTFS_EXTRA_SPACE = "262144"

export IMAGE_BASENAME = "sigma-racer-wingman-image-virt"
