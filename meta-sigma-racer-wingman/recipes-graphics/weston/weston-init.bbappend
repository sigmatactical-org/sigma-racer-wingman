# Sigma Racer Wingman — Weston init overrides.
#
# Replace the stock VT-bound weston.service with a DRM kiosk unit that exposes
# the Wayland socket at /run/weston/wayland-0 (see ui.env / cluster-ui.service).

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://weston-sigma.service"

# Stock recipe also enables weston.socket (/run/wayland-0) — that path does not
# match the cluster, and socket activation fights our unit. Ship only weston.service.
SYSTEMD_SERVICE:${PN} = "weston.service"

do_install:append() {
    install -m 0644 ${WORKDIR}/weston-sigma.service \
        ${D}${systemd_system_unitdir}/weston.service
    # Drop the unused socket unit if the base recipe installed it.
    rm -f ${D}${systemd_system_unitdir}/weston.socket
}
