#!/usr/bin/env bash
# Resolve shared Yocto download/sstate paths for CI and local bitbake.
#
# Priority:
#   1. SIGMA_DL_DIR / SIGMA_SSTATE_DIR (explicit)
#   2. Host dev tree under $HOME/Source/sigma/embedded/sigma-racer-wingman/
#   3. Unset — setup-environment keeps TOPDIR-relative defaults
set -euo pipefail

_host_root="${SIGMA_HOST_WINGMAN_ROOT:-${HOME}/Source/sigma/embedded/sigma-racer-wingman}"

if [[ -z "${SIGMA_DL_DIR:-}" && -d "${_host_root}/downloads" ]]; then
  export SIGMA_DL_DIR="${_host_root}/downloads"
fi

if [[ -z "${SIGMA_SSTATE_DIR:-}" && -d "${_host_root}/sstate-cache" ]]; then
  export SIGMA_SSTATE_DIR="${_host_root}/sstate-cache"
fi

if [[ -n "${SIGMA_DL_DIR:-}" || -n "${SIGMA_SSTATE_DIR:-}" ]]; then
  echo "resolve-cache-dirs: using shared host caches"
  [[ -n "${SIGMA_DL_DIR:-}" ]] && echo "  DL_DIR=${SIGMA_DL_DIR}"
  [[ -n "${SIGMA_SSTATE_DIR:-}" ]] && echo "  SSTATE_DIR=${SIGMA_SSTATE_DIR}"
fi
