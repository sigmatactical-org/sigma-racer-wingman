SUMMARY = "RAUC A/B update bundle for the Sigma Racer Wingman image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit bundle

# Must match /etc/rauc/system.conf on the device (rauc-conf substitutes
# @MACHINE@ the same way).
RAUC_BUNDLE_COMPATIBLE = "${MACHINE}"
RAUC_BUNDLE_VERSION = "${DISTRO_VERSION}"
RAUC_BUNDLE_DESCRIPTION = "Sigma Racer Wingman ${DISTRO_VERSION}"

RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_SLOT_rootfs = "${@'sigma-racer-wingman-image-virt' if 'virt' in d.getVar('MACHINE') else 'sigma-racer-wingman-image'}"
RAUC_SLOT_rootfs[fstype] = "ext4"

# Signing material comes from local.conf / the release environment
# (RAUC_KEY_FILE / RAUC_CERT_FILE); there is no in-tree default key.
