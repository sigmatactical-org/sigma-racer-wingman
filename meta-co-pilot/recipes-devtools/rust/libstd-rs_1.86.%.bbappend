# Poky rust-target-config still ships the pre-1.80 x86_64 data-layout; Rust 1.86 rejects it.
DATA_LAYOUT[x86_64] = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"

# Poky cargo builds for RUST_HOST_SYS; libstd-rs.inc installs from TARGET_SYS (Yocto triple).
do_install () {
    mkdir -p ${D}${rustlibdir}
    rm -f ${B}/${RUST_HOST_SYS}/${BUILD_DIR}/deps/*.d
    cp ${B}/${RUST_HOST_SYS}/${BUILD_DIR}/deps/* ${D}${rustlibdir}
}
