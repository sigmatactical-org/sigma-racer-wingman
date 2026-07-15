#!/bin/sh
# Sigma Racer Wingman OTA install daemon.
#
# Filesystem IPC with the cluster UI (which runs unprivileged as `cluster`):
#   /run/sigma-ota/request  — UI writes one line: the bundle URL to install
#   /run/sigma-ota/status   — daemon writes one line the UI polls:
#                             idle | downloading | installing |
#                             success:<version> | error:<message>
#
# The daemon runs as root (systemd service) so `rauc install` can write the
# inactive slot and flip the boot order. One install at a time; the request
# file is consumed (removed) when picked up.

set -u

RUN_DIR="${SIGMA_OTA_RUN_DIR:-/run/sigma-ota}"
REQUEST="${RUN_DIR}/request"
STATUS="${RUN_DIR}/status"
UI_GROUP="${SIGMA_OTA_UI_GROUP:-cluster}"
SPOOL="${SIGMA_OTA_SPOOL:-/data/rauc/spool}"

log() {
    echo "sigma-ota: $*"
}

set_status() {
    printf '%s\n' "$1" > "${STATUS}.tmp" && mv "${STATUS}.tmp" "${STATUS}"
    chmod 0644 "${STATUS}" 2>/dev/null || true
}

# --- bring-up: IPC directory the UI can write requests into
mkdir -p "${RUN_DIR}"
chgrp "${UI_GROUP}" "${RUN_DIR}" 2>/dev/null || true
chmod 0775 "${RUN_DIR}"
set_status idle

install_bundle() {
    url="$1"
    name="${url##*/}"
    case "${name}" in
        *.raucb) ;;
        *)
            set_status "error:not a .raucb URL"
            return 1
            ;;
    esac

    mkdir -p "${SPOOL}"
    bundle="${SPOOL}/${name}"

    log "downloading ${url}"
    set_status downloading
    if ! curl -fsSL --retry 3 -o "${bundle}.tmp" "${url}"; then
        rm -f "${bundle}.tmp"
        set_status "error:download failed"
        return 1
    fi
    mv "${bundle}.tmp" "${bundle}"

    log "installing ${bundle}"
    set_status installing
    if err=$(rauc install "${bundle}" 2>&1 >/dev/null); then
        version=$(rauc info --output-format=shell "${bundle}" 2>/dev/null \
            | sed -n "s/^RAUC_MF_VERSION='\(.*\)'$/\1/p")
        rm -f "${bundle}"
        set_status "success:${version:-installed} — reboot to apply"
        log "install ok (${version:-unknown version})"
    else
        rm -f "${bundle}"
        # first line of rauc's error is enough for the status bar
        set_status "error:$(printf '%s' "${err}" | head -n 1 | cut -c1-160)"
        log "install failed: ${err}"
        return 1
    fi
}

log "watching ${REQUEST}"
while true; do
    if [ -f "${REQUEST}" ]; then
        url=$(head -n 1 "${REQUEST}" | tr -d '[:space:]')
        rm -f "${REQUEST}"
        if [ -n "${url}" ]; then
            install_bundle "${url}" || true
        fi
    fi
    sleep 2
done
