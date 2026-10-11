#!/bin/bash
# Project Phoenix — repository health check
set -euo pipefail

echo "[+] Start check"
curl -fsSL --proto '=https' https://phoenix.calif-int.org/health > /dev/null
echo "[+] Check complete"
