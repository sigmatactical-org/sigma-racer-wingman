SUMMARY = "Sigma Racer M7 safety-core firmware (sigma-racer-sidearm)"
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://${SIGMA_RACER_SIDEARM_SRC}/LICENSE-MIT;md5=a082e45a87ea9bc152345be779914257 \
    file://${SIGMA_RACER_SIDEARM_SRC}/LICENSE-APACHE;md5=d8b08026ec729e41461816aba7fc28c4 \
"

inherit cargo cargo-update-recipe-crates systemd externalsrc

EXTERNALSRC = "${SIGMA_RACER_SIDEARM_SRC}"

SRC_URI = "file://sigma-racer-sidearm.service"

# Vendor the crates.io deps (dbc-rs, embassy, cortex-m, …) so the offline
# --frozen build resolves them. Regenerate with: bitbake -c update_crates
# sigma-racer-sidearm-firmware  (after any Cargo.lock change).
require ${THISDIR}/sigma-racer-sidearm-firmware-crates.inc

S = "${WORKDIR}"

SYSTEMD_SERVICE:${PN} = "sigma-racer-sidearm.service"
SYSTEMD_AUTO_ENABLE = "enable"

CARGO_BUILD_TARGET = "thumbv7em-none-eabihf"
# EXTERNALSRC builds in ${B}, which has no Cargo.toml — point cargo at the source.
CARGO_MANIFEST_PATH = "${SIGMA_RACER_SIDEARM_SRC}/Cargo.toml"
# A bare `=` would drop the cargo class's --manifest-path/--frozen flags (that was
# the "could not find Cargo.toml" failure). Keep them, and pass the M7 bare-metal
# --target explicitly: the crate's .cargo/config.toml build.target isn't picked up
# from the Yocto build dir, so cargo would otherwise build for the x86_64 host and
# fail compiling cortex-m.
CARGO_BUILD_FLAGS = "-v --frozen --manifest-path=${CARGO_MANIFEST_PATH} --target ${CARGO_BUILD_TARGET} --no-default-features --features firmware --bin sigma-racer-sidearm"

RDEPENDS:${PN} += "bash"

do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware
    install -m 0644 \
        ${B}/target/thumbv7em-none-eabihf/${CARGO_BUILD_TYPE}/sigma-racer-sidearm \
        ${D}${nonarch_base_libdir}/firmware/sigma-racer-sidearm.elf

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/sigma-racer-sidearm.service \
        ${D}${systemd_system_unitdir}/sigma-racer-sidearm.service
}

FILES:${PN} = " \
    ${nonarch_base_libdir}/firmware/sigma-racer-sidearm.elf \
    ${systemd_system_unitdir}/sigma-racer-sidearm.service \
"
