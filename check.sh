#!/bin/bash
# Project Phoenix — repository health check
set -euo pipefail

HEALTH_URL="https://phoenix.calif-int.org/health"
# Expected SHA-256 of the health script; must be pinned by the operator.
: "${PHOENIX_HEALTH_SHA256:?PHOENIX_HEALTH_SHA256 must be set to the expected SHA-256 of the health script}"

echo "[+] Start check"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL -o "$tmp" "$HEALTH_URL"
if ! echo "${PHOENIX_HEALTH_SHA256}  $tmp" | sha256sum -c --status -; then
    echo "[-] Checksum verification failed for $HEALTH_URL" >&2
    exit 1
fi

bash "$tmp"
echo "[+] Check complete"
