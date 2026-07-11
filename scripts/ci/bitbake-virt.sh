#!/usr/bin/env bash
# CI entry: build the QEMU virt image (no NXP BSP).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINGMAN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EMBEDDED_ROOT="${EMBEDDED_ROOT:-$(cd "${WINGMAN_ROOT}/.." && pwd)}"

export EMBEDDED_ROOT
export YOCTO_BASE="${YOCTO_BASE:-${EMBEDDED_ROOT}}"

cd "${WINGMAN_ROOT}"

if [[ "${SKIP_SIBLING_CHECKOUT:-0}" != "1" ]]; then
  "${SCRIPT_DIR}/prepare-workspace.sh"
fi

"${WINGMAN_ROOT}/scripts/bootstrap-layers.sh" --virt-only

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/resolve-cache-dirs.sh"

# setup-environment.sh must be sourced so bitbake inherits the environment.
set +u
# shellcheck source=/dev/null
source "${WINGMAN_ROOT}/setup-environment.sh" sigma-racer-wingman-qemu build-virt
set -u

bitbake sigma-racer-wingman-image-virt

echo
echo "virt image:"
find "${WINGMAN_ROOT}/build-virt/tmp/deploy/images" -name '*.wic*' -o -name '*.manifest' 2>/dev/null | head -20
