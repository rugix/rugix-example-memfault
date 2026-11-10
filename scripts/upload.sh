#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

system="${1:-customized-efi-arm64}"
if [ -f .env ]; then set -a; source .env; set +a; fi
BUNDLE_PATH="build/$system/system.rugixb"
if [ ! -e "$BUNDLE_PATH" ]; then
    echo "ERROR: Need to build bundle first. Run 'mise run build $system'."
    exit 1
fi
. "build/$system/artifacts/memfault-vars"
echo "MEMFAULT_SOFTWARE_VERSION=${MEMFAULT_SOFTWARE_VERSION}"
echo "MEMFAULT_HARDWARE_VERSION=${MEMFAULT_HARDWARE_VERSION}"
uv run --locked memfault \
    --project "${MEMFAULT_PROJECT_SLUG}" \
    --org "${MEMFAULT_ORG_SLUG}" \
    --org-token "${MEMFAULT_ORG_TOKEN}" \
    upload-ota-payload \
    --hardware-version "${MEMFAULT_HARDWARE_VERSION}" \
    --software-type rugix-debian \
    --software-version "${MEMFAULT_SOFTWARE_VERSION}" \
    "$BUNDLE_PATH"
