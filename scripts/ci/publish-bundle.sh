#!/usr/bin/env bash
# Publish the RAUC bundle to the updates service dev/production channel as
# <image_version>.raucb — the filename the env-backed catalog advertises.
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <artifact-dir>" >&2
  exit 1
fi

ARTIFACT_DIR="$(cd "$1" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINGMAN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MANIFEST="${MANIFEST:-${WINGMAN_ROOT}/release-manifest.json}"

: "${SIGMA_UPDATES_URL:?SIGMA_UPDATES_URL is required}"
: "${SIGMA_INTERNAL_TOKEN:?SIGMA_INTERNAL_TOKEN is required}"
CHANNEL="${SIGMA_UPDATES_CHANNEL:-dev}"

VERSION="$(python3 - "${MANIFEST}" <<'PY'
import json, sys
print(json.load(open(sys.argv[1])).get("image_version", "0.0.0"))
PY
)"

bundle="$(find "${ARTIFACT_DIR}" -maxdepth 1 -name '*.raucb' -print -quit || true)"
if [[ -z "${bundle}" ]]; then
  echo "no .raucb in ${ARTIFACT_DIR} — nothing to publish" >&2
  exit 0
fi

url="${SIGMA_UPDATES_URL%/}/v1/channel/${CHANNEL}/bundle/${VERSION}.raucb"
echo "==> publishing $(basename "${bundle}") to ${url}"
curl -fsS -X POST \
  -H "x-sigma-internal-token: ${SIGMA_INTERNAL_TOKEN}" \
  --data-binary "@${bundle}" \
  "${url}"
echo "publish complete"
