SUMMARY = "Sigma Racer Wingman mTLS telemetry WiFi relay"
HOMEPAGE = "https://github.com/sigmatactical-org/sigma-racer-telemetry"
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-MIT;md5=a082e45a87ea9bc152345be779914257 \
    file://LICENSE-APACHE;md5=d8b08026ec729e41461816aba7fc28c4 \
"

inherit cargo cargo-update-recipe-crates systemd externalsrc

EXTERNALSRC = "${SIGMA_RACER_TELEMETRY_SRC}"

require ${THISDIR}/../sigma-cargo-sibling-patches.inc

SRC_URI = " \
    git://github.com/sigmatactical-org/sigma-racer-telemetry.git;protocol=https;name=telemetry;nobranch=1 \
    file://diagnostics.service \
    file://diagnostics.env \
    file://diagnostics-qemu.env \
"

require ${THISDIR}/sigma-telemetry-relay-crates.inc

SRCREV = "864e4d7b5d6843c1bd959c4790990633e1aebafa"

S = "${WORKDIR}/git"

DEPENDS += "openssl-native"

CARGO_BUILD_FLAGS:append = " --bin sigma-telemetry-relay"

SYSTEMD_SERVICE:${PN} = "diagnostics.service"
SYSTEMD_AUTO_ENABLE = "enable"

DIAGNOSTICS_ENV = "${@bb.utils.contains('MACHINE', 'sigma-racer-wingman-qemu', 'diagnostics-qemu.env', 'diagnostics.env', d)}"
TELEMETRY_TLS_SAN ??= "DNS:wingman-telemetry"
TELEMETRY_TLS_SAN:sigma-racer-wingman-qemu = "IP:127.0.0.1"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/sigma-telemetry-relay ${D}${bindir}/sigma-telemetry-relay

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/diagnostics.service ${D}${systemd_system_unitdir}/diagnostics.service

    install -d ${D}${sysconfdir}/sigma-racer-wingman
    install -m 0644 ${WORKDIR}/${DIAGNOSTICS_ENV} ${D}${sysconfdir}/sigma-racer-wingman/diagnostics.env

    install -d ${D}${sysconfdir}/sigma-racer-wingman/telemetry-tls
    chmod 700 ${D}${sysconfdir}/sigma-racer-wingman/telemetry-tls
    PATH="${STAGING_BINDIR_NATIVE}:${PATH}" \
        bash ${SIGMA_RACER_TELEMETRY_SRC}/scripts/gen-telemetry-tls.sh \
            ${D}${sysconfdir}/sigma-racer-wingman/telemetry-tls \
            "${TELEMETRY_TLS_SAN}"
    chmod 600 ${D}${sysconfdir}/sigma-racer-wingman/telemetry-tls/*.key
}

FILES:${PN} = " \
    ${bindir}/sigma-telemetry-relay \
    ${systemd_system_unitdir}/diagnostics.service \
    ${sysconfdir}/sigma-racer-wingman/diagnostics.env \
    ${sysconfdir}/sigma-racer-wingman/telemetry-tls/* \
"

RDEPENDS:${PN} += " \
    bash \
    sigma-racer-vehicle \
"
