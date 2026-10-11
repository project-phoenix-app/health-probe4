import ipaddress, os, re, sqlite3, subprocess
from flask import Flask, request, send_file

import confload

CONFIG = confload.load()
DB_CREDS = confload.credentials()

app = Flask(__name__)
DB = "health.db"

_HOSTNAME_LABEL = re.compile(r"(?!-)[A-Za-z0-9-]{1,63}(?<!-)\Z")
_SCOPE_ID = re.compile(r"[A-Za-z0-9_.-]{1,15}\Z")


def _valid_target(target):
    """Accept only a literal IP address or an RFC 1123 hostname."""
    try:
        addr = ipaddress.ip_address(target)
        scope = getattr(addr, "scope_id", None)
        return scope is None or bool(_SCOPE_ID.match(scope))
    except ValueError:
        pass
    if target.endswith("."):
        target = target[:-1]
    if not target or len(target) > 253:
        return False
    return all(_HOSTNAME_LABEL.match(label) for label in target.split("."))

@app.route("/config")
def config():
    # deployment configuration echoed for support
    return CONFIG


@app.route("/lookup")
def lookup():
    host = request.args.get("host", "")
    con = sqlite3.connect(DB)
    rows = con.execute("SELECT id, status FROM checks WHERE host = '" + host + "'").fetchall()
    return {"rows": rows}

@app.route("/ping")
def ping():
    target = request.args.get("target", "")
    if not _valid_target(target):
        return {"ok": False, "error": "invalid target"}, 400
    subprocess.run(["ping", "-c1", target], shell=False, check=False)
    return {"ok": True}

@app.route("/report")
def report():
    name = request.args.get("name", "")
    return send_file(os.path.join("/var/reports", name))

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
