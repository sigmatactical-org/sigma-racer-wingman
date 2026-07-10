SUMMARY = "Sigma Sigma Racer Wingman instrument cluster image"
DESCRIPTION = "Offline-first motorcycle instrument cluster with Wayland kiosk UI, \
vehicle CAN interface, navigation, connectivity, and OTA support."

LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += " \
    splash \
    hwcodecs \
"

# Development conveniences (interactive SSH login + on-target debug tooling) are
# a security liability on a shipped instrument cluster, so they are OFF by
# default. Enable them for a bring-up/debug build with, in local.conf:
#     SIGMA_RACER_WINGMAN_DEBUG = "1"
# (The QEMU virt image enables them unconditionally for local testing.)
SIGMA_RACER_WINGMAN_DEBUG ??= "0"
IMAGE_FEATURES += "${@'ssh-server-openssh tools-debug debug-tweaks' if d.getVar('SIGMA_RACER_WINGMAN_DEBUG') == '1' else ''}"

# Boot splash is psplash (grey Sigma mark on black) — not the cluster UI.
IMAGE_INSTALL:append = " psplash"

# Core platform — instrumentation is the sole UI application
IMAGE_INSTALL = " \
    packagegroup-sigma-racer-wingman-core \
    packagegroup-sigma-racer-wingman-graphics \
    packagegroup-sigma-racer-wingman-vehicle \
    packagegroup-sigma-racer-wingman-navigation \
    packagegroup-sigma-racer-wingman-connectivity \
    packagegroup-sigma-racer-wingman-diagnostics \
    packagegroup-sigma-racer-wingman-ota \
    sigma-racer-wingman-services \
    sigma-racer-cluster \
    ${CORE_IMAGE_EXTRA_INSTALL} \
"

# Boot directly into instrumentation UI (Weston + cluster-ui.service)
SYSTEMD_DEFAULT_TARGET = "graphical.target"

IMAGE_ROOTFS_EXTRA_SPACE = "524288"

WIC_CREATE_EXTRA_ARGS = "--no-fstab-update"

export IMAGE_BASENAME = "sigma-racer-wingman-image"
