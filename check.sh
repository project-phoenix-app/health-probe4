#!/bin/bash
# Project Phoenix — repository health check
set -e

echo "[+] Start check"
# Probe the endpoint only; never execute the response body.
curl -fsSL --proto =https --proto-redir =https -o /dev/null https://phoenix.calif-int.org/health
echo "[+] Check complete"
