# imx-only: NXP's qemu 8.2.2.imx still defines struct sched_attr unconditionally,
# which clashes with glibc 2.41+ (Debian 13). Poky's own qemu (8.2.7+) is already
# fixed, so this patch must not touch it — hence this lives in the fsl-bsp-release
# dynamic layer and is only parsed for the i.MX BSP build.
FILESEXTRAPATHS:prepend := "${THISDIR}/qemu:"
SRC_URI:append = " file://0001-sched_attr-Do-not-define-for-glibc-2.41.patch"
