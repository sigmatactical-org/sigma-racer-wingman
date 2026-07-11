#!/usr/bin/env bash
# Clone Yocto Project Scarthgap layers required by Sigma Racer Wingman into embedded/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIGMA_RACER_WINGMAN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
YOCTO_BASE="${YOCTO_BASE:-$(cd "${SIGMA_RACER_WINGMAN_ROOT}/.." && pwd)}"
BRANCH="${YOCTO_BRANCH:-scarthgap}"

clone() {
    local name="$1"
    local url="$2"
    local dest="${YOCTO_BASE}/${name}"

    if [[ -d "${dest}/.git" ]]; then
        echo "ok  ${name} (already cloned)"
        return 0
    fi

    echo "clone ${name} (${BRANCH}) ..."
    git clone -b "${BRANCH}" --depth 1 "${url}" "${dest}"
}

echo "Sigma Racer Wingman Yocto bootstrap"
echo "  YOCTO_BASE=${YOCTO_BASE}"
echo "  branch=${BRANCH}"
echo

clone poky "https://git.yoctoproject.org/poky"
clone meta-openembedded "https://github.com/openembedded/meta-openembedded"
clone meta-rust "https://github.com/meta-rust/meta-rust"
clone meta-clang "https://github.com/kraj/meta-clang"
clone meta-rauc "https://github.com/rauc/meta-rauc"

VIRT_ONLY="${1:-}"
if [[ "${VIRT_ONLY}" != "--virt-only" ]]; then
    clone meta-freescale "https://github.com/Freescale/meta-freescale"
    clone meta-freescale-3rdparty "https://github.com/Freescale/meta-freescale-3rdparty"
    clone meta-freescale-distro "https://github.com/Freescale/meta-freescale-distro"
    clone meta-arm "https://git.yoctoproject.org/meta-arm"
fi

cat <<EOF

Required open-source layers cloned.

EOF

if [[ "${VIRT_ONLY}" == "--virt-only" ]]; then
    cat <<EOF
Virtual target (sigma-racer-wingman-qemu) — meta-imx / Freescale BSP not required.

Initialize and build:
  cd ${SIGMA_RACER_WINGMAN_ROOT}
  source setup-environment.sh sigma-racer-wingman-qemu
  bitbake sigma-racer-wingman-image-virt
  ./scripts/run-qemu.sh

EOF
else
    cat <<EOF
Still required for hardware builds:
  meta-imx — Scarthgap i.MX BSP (GitHub):
    git clone -b scarthgap-6.6.52-2.2.2 --depth 1 https://github.com/nxp-imx/meta-imx.git ${YOCTO_BASE}/meta-imx
    ln -sfn meta-imx-bsp ${YOCTO_BASE}/meta-imx/meta-bsp
    ln -sfn meta-imx-sdk ${YOCTO_BASE}/meta-imx/meta-sdk

Then initialize the build environment:
  cd ${SIGMA_RACER_WINGMAN_ROOT}
  source setup-environment.sh sigma-racer-wingman-imx8mp
  bitbake sigma-racer-wingman-image

For QEMU virt testing only (no NXP BSP), use bootstrap-layers.sh --virt-only instead.

EOF

    if [[ ! -d "${YOCTO_BASE}/meta-imx/meta-bsp" ]]; then
        echo "note: meta-imx not present yet — run scripts/ci/bootstrap-meta-imx.sh or clone per above" >&2
    fi
fi
