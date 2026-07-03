SUMMARY = "Sigma instrument cluster UI (instrumentation / sigma-dash)"
HOMEPAGE = "https://github.com/sigmatactical-org/instrumentation"
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-MIT;md5=a082e45a87ea9bc152345be779914257 \
    file://LICENSE-APACHE;md5=d8b08026ec729e41461816aba7fc28c4 \
"

inherit cargo cargo-update-recipe-crates systemd

SRC_URI = " \
    git://github.com/sigmatactical-org/instrumentation.git;protocol=https;branch=main;name=instrumentation;nobranch=1 \
    file://cluster-ui.service \
    file://co-pilot-ui.env \
"

# After SRC_URI assignment — crates.inc uses SRC_URI +=
require ${THISDIR}/instrumentation-crates.inc

SRCREV = "8a97ff37495d3d5cb37b1a39315c7563014d7b13"

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
export RUSTFLAGS:append = " --cfg co_pilot_embedded"

CARGO_BUILD_FLAGS:append = " --bin sigma-dash"

SYSTEMD_SERVICE:${PN} = "cluster-ui.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/sigma-dash ${D}${bindir}/sigma-dash

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${UNPACKDIR}/cluster-ui.service ${D}${systemd_system_unitdir}/cluster-ui.service
    install -d ${D}${sysconfdir}/co-pilot
    install -m 0644 ${UNPACKDIR}/co-pilot-ui.env ${D}${sysconfdir}/co-pilot/ui.env
}

FILES:${PN} += " \
    ${bindir}/sigma-dash \
    ${systemd_system_unitdir}/cluster-ui.service \
    ${sysconfdir}/co-pilot/ui.env \
"

RDEPENDS:${PN} += " \
    weston \
    liberation-fonts \
    fontconfig \
"

RPROVIDES:${PN} += "sigma-dash"

# Requires meta-rust in bblayers.conf
