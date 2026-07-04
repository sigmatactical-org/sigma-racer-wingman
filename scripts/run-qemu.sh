#!/usr/bin/env bash
# Boot a co-pilot-qemu image in a fixed 800×480 GTK window.
#
# Prerequisites:
#   source setup-environment.sh co-pilot-qemu
#   bitbake co-pilot-image-virt
#
# Usage (works from any directory):
#   /path/to/co-pilot/scripts/run-qemu.sh [runqemu extra args...]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CO_PILOT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${CO_PILOT_ROOT}/build-virt"
DEPLOY_DIR="${BUILD_DIR}/tmp/deploy/images/co-pilot-qemu"
ROOTFS="${DEPLOY_DIR}/co-pilot-image-virt-co-pilot-qemu.rootfs.ext4"

if [[ ! -f "${ROOTFS}" ]]; then
    echo "error: ${ROOTFS} not found" >&2
    echo "  source setup-environment.sh co-pilot-qemu" >&2
    echo "  bitbake co-pilot-image-virt" >&2
    exit 1
fi

if ! command -v runqemu >/dev/null 2>&1; then
    echo "error: runqemu not in PATH — source setup-environment.sh co-pilot-qemu first" >&2
    exit 1
fi

cd "${BUILD_DIR}"

# Pass the rootfs file explicitly — avoids runqemu lazy-rootfs / IMAGE_LINK_NAME bugs
# when given recipe names like co-pilot-image-virt.
exec runqemu co-pilot-qemu "${ROOTFS}" slirp "$@"
