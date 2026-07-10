# sigma-racer-wingman-qemu needs a display backend for runqemu (gtk/sdl).
# Applies to every 8.2.x qemu-system-native (poky's 8.2.7 and NXP's 8.2.2.imx).
PACKAGECONFIG:append = " sdl"
DEPENDS:append = " libsdl2-native"

# The glibc-2.41 sched_attr patch is imx-only (poky 8.2.7 is already fixed); it
# lives in dynamic-layers/fsl-bsp-release/ so it only applies to the i.MX BSP build.
