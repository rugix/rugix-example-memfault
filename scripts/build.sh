#!/usr/bin/env bash
set -euo pipefail

cd -- "$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f .env ]]; then
    set -a
    # shellcheck source=/dev/null
    source .env
    set +a
fi

system="${1:-customized-efi-arm64}"
if [[ $# -gt 0 ]]; then
    shift
fi
./run-bakery bake image "$system"
./run-bakery bake bundle "$system" "$@"
