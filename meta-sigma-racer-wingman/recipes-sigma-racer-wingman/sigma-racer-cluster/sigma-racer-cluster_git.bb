SUMMARY = "Sigma Racer Wingman instrument cluster UI"
HOMEPAGE = "https://github.com/sigmatactical-org/sigma-racer-cluster"
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-MIT;md5=a082e45a87ea9bc152345be779914257 \
    file://LICENSE-APACHE;md5=d8b08026ec729e41461816aba7fc28c4 \
"

inherit cargo cargo-update-recipe-crates pkgconfig systemd externalsrc

EXTERNALSRC = "${SIGMA_RACER_CLUSTER_SRC}"

# telemetry (and its sidearm dep) are pinned as git deps but are checked out
# locally under embedded/. Patch them to the in-tree sources so the offline
# (--frozen) cargo build resolves them without ssh/network — the Yocto
# equivalent of the crate's .cargo/config.toml [patch] used for local dev. A
# `paths` override is not enough: cargo resolves the git *source* first, which
# --frozen forbids; `[patch]` replaces the source, and the committed Cargo.lock
# already records these as path deps so --frozen stays satisfied.
require ${THISDIR}/../sigma-cargo-sibling-patches.inc

SRC_URI = " \
    git://github.com/sigmatactical-org/sigma-racer-cluster.git;protocol=https;name=cluster;nobranch=1 \
    file://cluster-ui.service \
    file://sigma-racer-wingman-ui.env \
    file://sigma-racer-wingman-ui-qemu.env \
"

require ${THISDIR}/sigma-racer-cluster-crates.inc

UI_ENV = "${@bb.utils.contains('MACHINE', 'sigma-racer-wingman-qemu', 'sigma-racer-wingman-ui-qemu.env', 'sigma-racer-wingman-ui.env', d)}"

SRCREV = "8e0522d88132bfcfaa1592aca6a79d88c3bcb886"

S = "${WORKDIR}/git"

DEPENDS += " \
    virtual/libgbm \
    libdrm \
    virtual/libgl \
    virtual/libgles2 \
    virtual/egl \
    fontconfig \
    freetype \
    libxkbcommon \
    wayland-native \
"

# Slint FemtoVG + Wayland (via winit) on i.MX Vivante
export SLINT_BACKEND = "femtovg"
export RUSTFLAGS:append = " --cfg sigma_racer_wingman_embedded"

CARGO_BUILD_FLAGS:append = " --bin sigma-racer-cluster"

SYSTEMD_SERVICE:${PN} = "cluster-ui.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/sigma-racer-cluster ${D}${bindir}/sigma-racer-cluster

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/cluster-ui.service ${D}${systemd_system_unitdir}/cluster-ui.service
    install -d ${D}${sysconfdir}/sigma-racer-wingman
    install -m 0644 ${WORKDIR}/${UI_ENV} ${D}${sysconfdir}/sigma-racer-wingman/ui.env
}

FILES:${PN} += " \
    ${bindir}/sigma-racer-cluster \
    ${systemd_system_unitdir}/cluster-ui.service \
    ${sysconfdir}/sigma-racer-wingman/ui.env \
"

RDEPENDS:${PN} += " \
    weston \
    liberation-fonts \
    fontconfig \
    bluez5 \
    connman \
"

# Requires meta-rust in bblayers.conf
