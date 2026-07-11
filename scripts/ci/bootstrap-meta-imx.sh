#!/usr/bin/env bash
# Ensure meta-imx is available under YOCTO_BASE for hardware release builds.
set -euo pipefail

YOCTO_BASE="${YOCTO_BASE:?YOCTO_BASE is required}"
META_IMX_DIR="${YOCTO_BASE}/meta-imx"
HOST_EMBEDDED="${SIGMA_HOST_EMBEDDED_ROOT:-${HOME}/Source/sigma/embedded}"
HOST_META_IMX="${HOST_EMBEDDED}/meta-imx"
META_IMX_BRANCH="${META_IMX_BRANCH:-scarthgap-6.6.52-2.2.2}"

if [[ -d "${META_IMX_DIR}/meta-bsp" ]]; then
  echo "bootstrap-meta-imx: ok ${META_IMX_DIR} (already present)"
  exit 0
fi

if [[ -d "${HOST_META_IMX}/meta-bsp" ]]; then
  ln -sfn "${HOST_META_IMX}" "${META_IMX_DIR}"
  echo "bootstrap-meta-imx: linked ${META_IMX_DIR} -> ${HOST_META_IMX}"
  exit 0
fi

echo "bootstrap-meta-imx: cloning meta-imx (${META_IMX_BRANCH}) into ${META_IMX_DIR}"
git clone -b "${META_IMX_BRANCH}" --depth 1 https://github.com/nxp-imx/meta-imx.git "${META_IMX_DIR}"
ln -sfn meta-imx-bsp "${META_IMX_DIR}/meta-bsp"
ln -sfn meta-imx-sdk "${META_IMX_DIR}/meta-sdk"
echo "bootstrap-meta-imx: ready"
