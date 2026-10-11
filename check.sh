#!/bin/bash
# Project Phoenix — repository health check
set -e

echo "[+] Start check"
# Probe the health endpoint without executing its response body.
# Piping a remote response into a shell is remote code execution: the
# probe would run whatever bytes the server returned. A health check only
# needs to confirm the endpoint responds successfully.
status="$(curl -fsS -o /dev/null -w '%{http_code}' https://phoenix.calif-int.org/health)"
if [ "$status" = "200" ]; then
  echo "[+] Health endpoint OK (HTTP $status)"
else
  echo "[!] Health endpoint returned HTTP $status" >&2
  exit 1
fi
echo "[+] Check complete"
