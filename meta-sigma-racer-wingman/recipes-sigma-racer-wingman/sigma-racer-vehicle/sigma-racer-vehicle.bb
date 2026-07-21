SUMMARY = "Sigma Racer vehicle signal abstraction daemon"
HOMEPAGE = "https://github.com/sigmatactical-org/sigma-racer-vehicle"
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-MIT;md5=a082e45a87ea9bc152345be779914257 \
    file://LICENSE-APACHE;md5=d8b08026ec729e41461816aba7fc28c4 \
"

inherit cargo cargo-update-recipe-crates systemd externalsrc

EXTERNALSRC = "${SIGMA_RACER_VEHICLE_SRC}"

# telemetry (and its sidearm dep) are pinned as git deps but are checked out
# locally under embedded/. Patch them to the in-tree sources so the offline
# (--frozen) cargo build resolves them without ssh/network — the Yocto
# equivalent of each crate's .cargo/config.toml [patch] used for local dev. A
# `paths` override is not enough: cargo still resolves the git *source* first,
# which --frozen forbids. `[patch]` replaces the source outright, and the
# committed Cargo.lock already records these as path deps so --frozen is happy.
require ${THISDIR}/../sigma-cargo-sibling-patches.inc

SRC_URI = " \
    git://github.com/sigmatactical-org/sigma-racer-vehicle.git;protocol=https;name=vehicle;nobranch=1 \
    file://sigma-racer-vehicle.service \
    file://sigma-racer-vehicle.env \
    file://sigma-racer-vehicle-qemu.env \
    file://sigma-racer-vehicle.tmpfiles.conf \
"

require ${THISDIR}/sigma-racer-vehicle-crates.inc

# Full 40-char SHA-1 so BitBake's git fetcher treats it as a resolved revision
# and skips the ls-remote lookup (a short hash is read as an unresolved ref).
SRCREV = "c1557ce617309cda5040bd1282b1cf8f466dcd1d"

S = "${WORKDIR}/git"

VEHICLE_ENV = "${@bb.utils.contains('MACHINE', 'sigma-racer-wingman-qemu', 'sigma-racer-vehicle-qemu.env', 'sigma-racer-vehicle.env', d)}"

CARGO_BUILD_FLAGS:append = " --bin sigma-racer-vehicle --features can-socket,rpmsg"

SYSTEMD_SERVICE:${PN} = "sigma-racer-vehicle.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/sigma-racer-vehicle ${D}${bindir}/sigma-racer-vehicle

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/sigma-racer-vehicle.service ${D}${systemd_system_unitdir}/sigma-racer-vehicle.service

    install -d ${D}${sysconfdir}/sigma-racer-wingman
    install -m 0644 ${WORKDIR}/${VEHICLE_ENV} ${D}${sysconfdir}/sigma-racer-wingman/vehicle.env

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/sigma-racer-vehicle.tmpfiles.conf ${D}${sysconfdir}/tmpfiles.d/sigma-racer-vehicle.conf
}

FILES:${PN} = " \
    ${bindir}/sigma-racer-vehicle \
    ${systemd_system_unitdir}/sigma-racer-vehicle.service \
    ${sysconfdir}/sigma-racer-wingman/vehicle.env \
    ${sysconfdir}/tmpfiles.d/sigma-racer-vehicle.conf \
"

RDEPENDS:${PN} += " \
    bash \
    can-network \
"
