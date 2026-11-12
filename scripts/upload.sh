#!/usr/bin/env bash
set -euo pipefail

cd -- "$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ $# -gt 1 ]]; then
    echo "Usage: upload.sh [SYSTEM]" >&2
    exit 2
fi
system="${1:-customized-efi-arm64}"
if [[ -f .env ]]; then
    set -a
    # shellcheck source=/dev/null
    source .env
    set +a
fi

bundle_path="build/$system/system.rugixb"
metadata_path="build/$system/artifacts/memfault-vars"
if [[ ! -f "$bundle_path" ]]; then
    echo "Build the bundle first: mise run build $system" >&2
    exit 1
fi
if [[ ! -f "$metadata_path" ]]; then
    echo "Missing build metadata: $metadata_path. Rebuild the bundle." >&2
    exit 1
fi
# shellcheck source=/dev/null
source "$metadata_path"

: "${MEMFAULT_PROJECT_SLUG:?Set MEMFAULT_PROJECT_SLUG in .env or the environment.}"
: "${MEMFAULT_ORG_SLUG:?Set MEMFAULT_ORG_SLUG in .env or the environment.}"
: "${MEMFAULT_ORG_TOKEN:?Set MEMFAULT_ORG_TOKEN in .env or the environment.}"
: "${MEMFAULT_SOFTWARE_VERSION:?Missing MEMFAULT_SOFTWARE_VERSION in build metadata.}"
: "${MEMFAULT_HARDWARE_VERSION:?Missing MEMFAULT_HARDWARE_VERSION in build metadata.}"

echo "MEMFAULT_SOFTWARE_VERSION=$MEMFAULT_SOFTWARE_VERSION"
echo "MEMFAULT_HARDWARE_VERSION=$MEMFAULT_HARDWARE_VERSION"
exec uv run --locked memfault \
    --project "$MEMFAULT_PROJECT_SLUG" \
    --org "$MEMFAULT_ORG_SLUG" \
    --org-token "$MEMFAULT_ORG_TOKEN" \
    upload-ota-payload \
    --hardware-version "$MEMFAULT_HARDWARE_VERSION" \
    --software-type rugix-debian \
    --software-version "$MEMFAULT_SOFTWARE_VERSION" \
    "$bundle_path"
