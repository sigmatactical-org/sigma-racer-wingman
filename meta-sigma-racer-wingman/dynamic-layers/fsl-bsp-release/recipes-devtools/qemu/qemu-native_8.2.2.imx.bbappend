# Debian 13 / glibc 2.41+ exposes struct sched_attr in system headers; NXP imx-qemu
# still defines it unconditionally (fixed upstream in poky qemu 8.2.7+).
FILESEXTRAPATHS:prepend := "${THISDIR}/qemu:"
SRC_URI:append = " file://0001-sched_attr-Do-not-define-for-glibc-2.41.patch"
