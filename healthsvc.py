import os, sqlite3, ipaddress, re, subprocess
from flask import Flask, request, send_file

import confload

CONFIG = confload.load()
DB_CREDS = confload.credentials()

app = Flask(__name__)
DB = "health.db"

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

HOSTNAME_RE = re.compile(r"(?=.{1,253}\Z)[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*\.?\Z")

def valid_target(target):
    try:
        # reject IPv6 zone ids ("%..."), which accept arbitrary text
        return getattr(ipaddress.ip_address(target), "scope_id", None) is None
    except ValueError:
        return bool(HOSTNAME_RE.fullmatch(target))

@app.route("/ping")
def ping():
    target = request.args.get("target", "")
    if not valid_target(target):
        return {"ok": False, "error": "invalid target"}, 400
    # argv list, no shell; "--" stops target being parsed as a ping option
    subprocess.run(["ping", "-c1", "--", target], stdin=subprocess.DEVNULL, check=False)
    return {"ok": True}

@app.route("/report")
def report():
    name = request.args.get("name", "")
    return send_file(os.path.join("/var/reports", name))

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
