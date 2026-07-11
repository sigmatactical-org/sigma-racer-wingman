SUMMARY = "Sigma Racer M7 safety-core firmware (sigma-racer-sidearm)"
DESCRIPTION = "Cortex-M7 remoteproc firmware + systemd unit for i.MX 8M Plus"
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://${SIGMA_RACER_SIDEARM_SRC}/LICENSE-MIT;md5=a082e45a87ea9bc152345be779914257 \
    file://${SIGMA_RACER_SIDEARM_SRC}/LICENSE-APACHE;md5=d8b08026ec729e41461816aba7fc28c4 \
"

# Match Cargo.toml; firmware ELF is not Linux userspace-arch-specific.
# Must inherit allarch (not only PACKAGE_ARCH="all") so sstate/rootfs
# look up manifests under "allarch".
PV = "0.1.0"

inherit allarch systemd externalsrc

# Built with the host rustup toolchain (see do_compile), not Yocto's cross
# toolchain, so no bitbake-provided compiler is required. OE has no
# "gcc-native" recipe; the host gcc on /usr/bin is used if a build script
# ever needs a C compiler.

EXTERNALSRC = "${SIGMA_RACER_SIDEARM_SRC}"

SRC_URI = "file://sigma-racer-sidearm.service"

S = "${WORKDIR}"

SYSTEMD_SERVICE:${PN} = "sigma-racer-sidearm.service"
SYSTEMD_AUTO_ENABLE = "enable"

# Yocto's rust-cross does not yet provide core for thumbv7em-none-eabihf.
# Build with the host rustup toolchain (same as scripts/package-deb.sh).
# Bitbake's PATH excludes ~/.cargo/bin — resolve cargo explicitly.
SIDEARM_CARGO_TARGET = "thumbv7em-none-eabihf"
SIDEARM_ELF = "${SIGMA_RACER_SIDEARM_SRC}/target/${SIDEARM_CARGO_TARGET}/release/sigma-racer-sidearm"
SIDEARM_CARGO ??= "${HOME}/.cargo/bin/cargo"

RDEPENDS:${PN} += "bash"

# Firmware is Cortex-M7 (ARM), not the Linux AArch64 userspace arch.
INSANE_SKIP:${PN} += "arch"

do_compile() {
    if [ -f "${SIDEARM_ELF}" ]; then
        bbnote "Using existing M7 firmware: ${SIDEARM_ELF}"
        return 0
    fi

    CARGO="${SIDEARM_CARGO}"
    if [ ! -x "$CARGO" ]; then
        CARGO="$(command -v cargo || true)"
    fi
    if [ -z "$CARGO" ] || [ ! -x "$CARGO" ]; then
        bbfatal "host cargo not found (tried ${SIDEARM_CARGO}). Install rustup + target ${SIDEARM_CARGO_TARGET}, or pre-build with: (cd ${SIGMA_RACER_SIDEARM_SRC} && cargo build --release --no-default-features --features firmware)"
    fi

    # rustup shims need their bin dir on PATH for rustc/rustdoc. Keep the host
    # /usr/bin ahead of any staged natives so a build script that needs a C
    # compiler finds the host gcc (this recipe pulls in no gcc-native).
    export PATH="/usr/bin:/bin:${STAGING_BINDIR_NATIVE}:${STAGING_BINDIRTOOLCHAIN_NATIVE}:$(dirname "$CARGO"):${PATH}"
    export CC="${CC:-$(command -v gcc)}"
    export HOST_CC="${HOST_CC:-$CC}"

    bbnote "Building M7 firmware with $CARGO (CC=$CC)"
    "$CARGO" build --release \
        --manifest-path="${SIGMA_RACER_SIDEARM_SRC}/Cargo.toml" \
        --target ${SIDEARM_CARGO_TARGET} \
        --no-default-features --features firmware \
        --bin sigma-racer-sidearm

    if [ ! -f "${SIDEARM_ELF}" ]; then
        bbfatal "M7 firmware missing after build: ${SIDEARM_ELF}"
    fi
}

do_install() {
    if [ ! -f "${SIDEARM_ELF}" ]; then
        bbfatal "M7 firmware missing at install: ${SIDEARM_ELF}"
    fi
    install -d ${D}${nonarch_base_libdir}/firmware
    install -m 0644 ${SIDEARM_ELF} \
        ${D}${nonarch_base_libdir}/firmware/sigma-racer-sidearm.elf

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/sigma-racer-sidearm.service \
        ${D}${systemd_system_unitdir}/sigma-racer-sidearm.service
}

FILES:${PN} = " \
    ${nonarch_base_libdir}/firmware/sigma-racer-sidearm.elf \
    ${systemd_system_unitdir}/sigma-racer-sidearm.service \
"
