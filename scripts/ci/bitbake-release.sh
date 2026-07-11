#!/usr/bin/env bash
# CI entry: build the production imx8mp image (requires meta-imx + EULA).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI_SCRIPT_DIR="${SCRIPT_DIR}"
WINGMAN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EMBEDDED_ROOT="${EMBEDDED_ROOT:-$(cd "${WINGMAN_ROOT}/.." && pwd)}"
MACHINE="${MACHINE:-sigma-racer-wingman-imx8mp}"
BUILD_DIR="${BUILD_DIR:-build}"

export EMBEDDED_ROOT
export YOCTO_BASE="${YOCTO_BASE:-${EMBEDDED_ROOT}}"

cd "${WINGMAN_ROOT}"

"${SCRIPT_DIR}/prepare-workspace.sh"
"${WINGMAN_ROOT}/scripts/bootstrap-layers.sh"

chmod +x "${SCRIPT_DIR}/bootstrap-meta-imx.sh"
"${SCRIPT_DIR}/bootstrap-meta-imx.sh"

if [[ ! -d "${YOCTO_BASE}/meta-imx/meta-bsp" ]]; then
  cat >&2 <<EOF
error: meta-imx is required for ${MACHINE}

Clone the Scarthgap i.MX BSP into \${YOCTO_BASE}/meta-imx, then re-run.
See README.md or docs/CI.md.
EOF
  exit 1
fi

# shellcheck source=/dev/null
export SIGMA_BUILD_SUBDIR="${BUILD_DIR}"
source "${SCRIPT_DIR}/resolve-cache-dirs.sh"
BUILD_DIR="${SIGMA_BUILD_DIR:-${BUILD_DIR}}"

# shellcheck source=/dev/null
set +u
source "${WINGMAN_ROOT}/setup-environment.sh" "${MACHINE}" "${BUILD_DIR}"
set -u

"${CI_SCRIPT_DIR}/prepare-bitbake.sh" "${BUILD_DIR}"

if ! grep -q '^ACCEPT_FSL_EULA' conf/local.conf 2>/dev/null; then
  echo 'ACCEPT_FSL_EULA = "1"' >> conf/local.conf
fi

# Optional RAUC signing for release bundles.
if [[ -n "${RAUC_KEY_FILE:-}" && -n "${RAUC_CERT_FILE:-}" ]]; then
  {
    echo "RAUC_KEY_FILE = \"${RAUC_KEY_FILE}\""
    echo "RAUC_CERT_FILE = \"${RAUC_CERT_FILE}\""
  } >> conf/local.conf
fi

bitbake sigma-racer-wingman-image

if [[ "${BUILD_DIR}" = /* ]]; then
  DEPLOY="${BUILD_DIR}/tmp/deploy/images/${MACHINE}"
else
  DEPLOY="${WINGMAN_ROOT}/${BUILD_DIR}/tmp/deploy/images/${MACHINE}"
fi
STAGING="${WINGMAN_ROOT}/dist/release/${MACHINE}"
rm -rf "${STAGING}"
mkdir -p "${STAGING}"

shopt -s nullglob
for pattern in '*.wic.gz' '*.wic' '*.raucb' '*.manifest' '*.testdata.json'; do
  for f in "${DEPLOY}"/${pattern}; do
    cp -a "${f}" "${STAGING}/"
  done
done

"${SCRIPT_DIR}/write-catalog.sh" "${STAGING}"

echo
echo "Release artifacts staged in ${STAGING}"
ls -la "${STAGING}"
