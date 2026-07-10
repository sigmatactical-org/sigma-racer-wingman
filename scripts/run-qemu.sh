#!/usr/bin/env bash
# Boot a sigma-racer-wingman-qemu image in an 800×480 window.
#
# Prerequisites:
#   source setup-environment.sh sigma-racer-wingman-qemu
#   bitbake sigma-racer-wingman-image
#
# Boots sigma-racer-wingman-image (ext4 on the qemu machine). Override with:
#   IMAGE=sigma-racer-wingman-image-virt ../scripts/run-qemu.sh
#
# Yocto's qemu-system-native is often headless-only (no gtk/sdl). This script
# falls back to the host qemu-system-x86 package when needed:
#   sudo apt install qemu-system-x86
#
# Usage (works from any directory after sourcing setup-environment):
#   /path/to/sigma-racer-wingman/scripts/run-qemu.sh [runqemu extra args...]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIGMA_RACER_WINGMAN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${SIGMA_RACER_WINGMAN_ROOT}/build-virt"
DEPLOY_DIR="${BUILD_DIR}/tmp/deploy/images/sigma-racer-wingman-qemu"
IMAGE="${IMAGE:-sigma-racer-wingman-image}"
ROOTFS="${DEPLOY_DIR}/${IMAGE}-sigma-racer-wingman-qemu.rootfs.ext4"
QBCONF="${DEPLOY_DIR}/${IMAGE}-sigma-racer-wingman-qemu.rootfs.qemuboot.conf"
YOCTO_QEMU="${BUILD_DIR}/tmp/work/x86_64-linux/qemu-helper-native/1.0/recipe-sysroot-native/usr/bin/qemu-system-x86_64"

if [[ ! -f "${ROOTFS}" ]]; then
    echo "error: ${ROOTFS} not found" >&2
    echo "  source setup-environment.sh sigma-racer-wingman-qemu" >&2
    echo "  bitbake ${IMAGE}" >&2
    exit 1
fi

if [[ ! -f "${QBCONF}" ]]; then
    echo "error: ${QBCONF} not found" >&2
    exit 1
fi

echo "run-qemu: booting ${IMAGE} ($(readlink -f "${ROOTFS}" 2>/dev/null || echo "${ROOTFS}"))" >&2

if ! command -v runqemu >/dev/null 2>&1; then
    echo "error: runqemu not in PATH — source setup-environment.sh sigma-racer-wingman-qemu first" >&2
    exit 1
fi

qemu_has_window_display() {
    local qemu="$1"
    [[ -x "${qemu}" ]] || return 1
    local help
    help="$("${qemu}" -display help 2>&1)" || return 1
    grep -qE '(^|[[:space:]])(sdl|gtk)([[:space:]]|$)' <<< "${help}"
}

host_qemu="$(command -v qemu-system-x86_64 2>/dev/null || true)"
use_qbconf="${QBCONF}"
tmp_qbconf=""

if [[ -x "${YOCTO_QEMU}" ]] && ! qemu_has_window_display "${YOCTO_QEMU}"; then
    if [[ -z "${host_qemu}" ]] || ! qemu_has_window_display "${host_qemu}"; then
        cat >&2 <<EOF
error: no QEMU with sdl/gtk display found.

Yocto QEMU (${YOCTO_QEMU}) is headless-only. Install host QEMU:
  sudo apt install qemu-system-x86

Then re-run this script. To rebuild Yocto QEMU with sdl instead:
  bitbake qemu-system-native -c cleansstate && bitbake qemu-system-native
EOF
        exit 1
    fi
    host_bindir="$(dirname "${host_qemu}")"
    tmp_qbconf="$(mktemp)"
    sed "s|^staging_bindir_native = .*|staging_bindir_native = ${host_bindir}|" \
        "${QBCONF}" > "${tmp_qbconf}"
    use_qbconf="${tmp_qbconf}"
    trap 'rm -f "${tmp_qbconf}"' EXIT
fi

cd "${BUILD_DIR}"

# Kill stale instances that hold the rootfs write lock.
# pgrep -x misses qemu-system-x86_64 (name truncated to 15 chars on Linux).
if pgrep -f "${DEPLOY_DIR}/.*rootfs.ext4" >/dev/null 2>&1; then
    echo "warning: stopping existing QEMU using a rootfs under ${DEPLOY_DIR}" >&2
    pkill -f "${DEPLOY_DIR}/.*rootfs.ext4" || true
    sleep 2
fi

# novga skips runqemu's virtio-vga but also skips -display; add both via qemuparams.
# serialstdio: boot log on the host terminal, not tiny text in the SDL window.
exec runqemu sigma-racer-wingman-qemu "${ROOTFS}" "${use_qbconf}" sdl slirp novga serialstdio \
    'qemuparams=-display sdl,show-cursor=on -device virtio-gpu-pci' "$@"
