SUMMARY = "Sigma Racer Wingman instrument cluster UI"
HOMEPAGE = "https://github.com/sigmatactical-org/sigma-racer-cluster"
# The cluster links Slint under Slint's GPL option (embedded deployment);
# see the repository's README for the licensing boundary.
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1ebbd3e34237af26da5dc08a4e440464"

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
    file://sigma-racer-cluster-connman.conf \
"

require ${THISDIR}/sigma-racer-cluster-crates.inc

UI_ENV = "${@bb.utils.contains('MACHINE', 'sigma-racer-wingman-qemu', 'sigma-racer-wingman-ui-qemu.env', 'sigma-racer-wingman-ui.env', d)}"

SRCREV = "56603151918bd0c041c9f917a3c52e5887e86c41"

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

    # connman's stock D-Bus policy denies non-root senders; admit the
    # cluster user so the Connectivity window can manage Wi-Fi.
    install -d ${D}${datadir}/dbus-1/system.d
    install -m 0644 ${WORKDIR}/sigma-racer-cluster-connman.conf \
        ${D}${datadir}/dbus-1/system.d/sigma-racer-cluster-connman.conf
}

FILES:${PN} += " \
    ${bindir}/sigma-racer-cluster \
    ${systemd_system_unitdir}/cluster-ui.service \
    ${sysconfdir}/sigma-racer-wingman/ui.env \
    ${datadir}/dbus-1/system.d/sigma-racer-cluster-connman.conf \
"

RDEPENDS:${PN} += " \
    weston \
    liberation-fonts \
    fontconfig \
    bluez5 \
    connman \
"

# Requires meta-rust in bblayers.conf
