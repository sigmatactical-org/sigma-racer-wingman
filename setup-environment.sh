#!/usr/bin/env bash
# Initialize Yocto build environment for Sigma Racer Wingman.
#
# Usage (recommended):
#   source setup-environment.sh [MACHINE]
#
# Do not run as ./setup-environment.sh — that works for CI but sourcing is
# required for bitbake to see the environment.

_SIGMA_RACER_WINGMAN_SETUP_SOURCED=0
if [[ "${BASH_SOURCE[0]:-}" != "${0:-}" ]]; then
    _SIGMA_RACER_WINGMAN_SETUP_SOURCED=1
fi

# set -e + source = exiting parent shell on any failure. Only enforce when executed.
if (( !_SIGMA_RACER_WINGMAN_SETUP_SOURCED )); then
    set -euo pipefail
fi

_sigma_racer_wingman_fail() {
    echo "error: $*" >&2
    if (( _SIGMA_RACER_WINGMAN_SETUP_SOURCED )); then
        return 1
    fi
    exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SIGMA_RACER_WINGMAN_ROOT="${SCRIPT_DIR}"
EMBEDDED_ROOT="$(cd "${SIGMA_RACER_WINGMAN_ROOT}/.." && pwd)"
YOCTO_BASE="${YOCTO_BASE:-${EMBEDDED_ROOT}}"
POKY_DIR="${YOCTO_BASE}/poky"
MACHINE="${1:-sigma-racer-wingman-imx8mp}"
if [[ -n "${2:-}" ]]; then
    BUILD_DIR="${2}"
elif [[ "${MACHINE}" == "sigma-racer-wingman-qemu" ]]; then
    BUILD_DIR="${SIGMA_RACER_WINGMAN_ROOT}/build-virt"
else
    BUILD_DIR="${SIGMA_RACER_WINGMAN_ROOT}/build"
fi

usage() {
    cat <<EOF
Usage: source setup-environment.sh [MACHINE] [build-dir]

  MACHINE     sigma-racer-wingman-imx8mp (default) | sigma-racer-wingman-imx95 | sigma-racer-wingman-qemu
  build-dir   build (hardware) or build-virt (sigma-racer-wingman-qemu default)

Environment:
  YOCTO_BASE  Directory containing poky and meta layers (default: ${EMBEDDED_ROOT})

First-time setup — clone Yocto layers:
  ${SIGMA_RACER_WINGMAN_ROOT}/scripts/bootstrap-layers.sh

Hardware build:
  source setup-environment.sh sigma-racer-wingman-imx8mp
  bitbake sigma-racer-wingman-image

Virtual testing (800×480 QEMU, no NXP BSP):
  source setup-environment.sh sigma-racer-wingman-qemu
  bitbake sigma-racer-wingman-image-virt
  ${SIGMA_RACER_WINGMAN_ROOT}/scripts/run-qemu.sh

EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    if (( _SIGMA_RACER_WINGMAN_SETUP_SOURCED )); then
        return 0
    fi
    exit 0
fi

if [[ ! -d "${POKY_DIR}" ]]; then
    cat >&2 <<EOF
error: poky not found at ${POKY_DIR}

Clone the Yocto layers first:
  ${SIGMA_RACER_WINGMAN_ROOT}/scripts/bootstrap-layers.sh

Or set YOCTO_BASE to the directory that contains poky/, then re-run:
  export YOCTO_BASE=/path/to/yocto-tree
  source setup-environment.sh ${MACHINE}

EOF
    _sigma_racer_wingman_fail "missing poky checkout" || return 1
fi

if [[ ! -f "${POKY_DIR}/oe-init-build-env" ]]; then
    _sigma_racer_wingman_fail "invalid poky checkout (oe-init-build-env not found in ${POKY_DIR})" || return 1
fi

# Seed Sigma Racer Wingman conf before oe-init-build-env (otherwise Poky default local.conf wins)
if [[ "${MACHINE}" == "sigma-racer-wingman-qemu" ]]; then
    _local_sample="${SIGMA_RACER_WINGMAN_ROOT}/conf/local.conf.virt.sample"
    _bblayers_sample="${SIGMA_RACER_WINGMAN_ROOT}/conf/bblayers-virt.conf.sample"
else
    _local_sample="${SIGMA_RACER_WINGMAN_ROOT}/conf/local.conf.sample"
    _bblayers_sample="${SIGMA_RACER_WINGMAN_ROOT}/conf/bblayers.conf.sample"
fi

mkdir -p "${BUILD_DIR}/conf"

if [[ ! -f "${BUILD_DIR}/conf/local.conf" ]] \
    || grep -q 'package_rpm' "${BUILD_DIR}/conf/local.conf" 2>/dev/null \
    || ! grep -q 'package_deb' "${BUILD_DIR}/conf/local.conf" 2>/dev/null; then
    cp "${_local_sample}" "${BUILD_DIR}/conf/local.conf"
fi

if [[ ! -f "${BUILD_DIR}/conf/bblayers.conf" ]] \
    || ! grep -q meta-sigma-racer-wingman "${BUILD_DIR}/conf/bblayers.conf" 2>/dev/null \
    || { [[ "${MACHINE}" != "sigma-racer-wingman-qemu" ]] \
         && ! grep -q meta-arm "${BUILD_DIR}/conf/bblayers.conf" 2>/dev/null; }; then
    sed "s|\${SIGMA_RACER_WINGMAN_ROOT}|${SIGMA_RACER_WINGMAN_ROOT}|g" \
        "${_bblayers_sample}" > "${BUILD_DIR}/conf/bblayers.conf"
fi

# oe-init-build-env must be sourced; it sets PATH, BBPATH, and cd's into build/
# shellcheck source=/dev/null
source "${POKY_DIR}/oe-init-build-env" "${BUILD_DIR}" || { _sigma_racer_wingman_fail "oe-init-build-env failed"; return 1; }

# Ensure machine and distro match the requested target
if ! grep -q '^MACHINE' conf/local.conf; then
    echo "MACHINE = \"${MACHINE}\"" >> conf/local.conf
else
    sed -i "s/^MACHINE.*/MACHINE = \"${MACHINE}\"/" conf/local.conf
fi

if ! grep -q '^DISTRO' conf/local.conf; then
    echo 'DISTRO = "sigma-racer-wingman"' >> conf/local.conf
else
    sed -i 's/^DISTRO.*/DISTRO = "sigma-racer-wingman"/' conf/local.conf
fi

# Optional shared caches (CI self-hosted runner or explicit SIGMA_*_DIR).
_sigma_apply_cache_dir() {
    local var="$1"
    local value="$2"
    if [[ -n "${value}" ]]; then
        sed -i "/^${var} /d" conf/local.conf
        echo "${var} = \"${value}\"" >> conf/local.conf
    fi
}
_sigma_apply_cache_dir DL_DIR "${SIGMA_DL_DIR:-}"
_sigma_apply_cache_dir SSTATE_DIR "${SIGMA_SSTATE_DIR:-}"

# BitBake reads machine layers from BBLAYERS — warn about missing optional layers
_missing_layers=()
if [[ "${MACHINE}" == "sigma-racer-wingman-qemu" ]]; then
    _required_layers=(
        "${YOCTO_BASE}/meta-openembedded/meta-oe"
        "${YOCTO_BASE}/meta-rust"
        "${YOCTO_BASE}/meta-rauc"
    )
else
    _required_layers=(
        "${YOCTO_BASE}/meta-openembedded/meta-oe"
        "${YOCTO_BASE}/meta-freescale"
        "${YOCTO_BASE}/meta-freescale-distro"
        "${YOCTO_BASE}/meta-rust"
        "${YOCTO_BASE}/meta-rauc"
        "${YOCTO_BASE}/meta-imx/meta-bsp"
        "${YOCTO_BASE}/meta-arm/meta-arm"
        "${YOCTO_BASE}/meta-arm/meta-arm-toolchain"
    )
fi
for _layer in "${_required_layers[@]}"; do
    if [[ ! -d "${_layer}" ]]; then
        _missing_layers+=("${_layer}")
    fi
done

cat <<EOF

Sigma Racer Wingman environment ready.
  MACHINE=${MACHINE}
  DISTRO=sigma-racer-wingman
  BUILD=${BUILD_DIR}
  POKY=${POKY_DIR}

Build image:
  bitbake sigma-racer-wingman-image

EOF

if [[ "${MACHINE}" == "sigma-racer-wingman-qemu" ]]; then
    cat <<EOF
Run in QEMU (800×480 window):
  ${SIGMA_RACER_WINGMAN_ROOT}/scripts/run-qemu.sh

EOF
fi

if ((${#_missing_layers[@]} > 0)); then
    echo "warning: missing layer checkouts (bitbake will fail until these exist):" >&2
    for _layer in "${_missing_layers[@]}"; do
        echo "  - ${_layer}" >&2
    done
    echo "Run: ${SIGMA_RACER_WINGMAN_ROOT}/scripts/bootstrap-layers.sh" >&2
    echo >&2
    _sigma_racer_wingman_fail "missing required Yocto layers" || return 1
fi

if (( _SIGMA_RACER_WINGMAN_SETUP_SOURCED )); then
    return 0
fi
