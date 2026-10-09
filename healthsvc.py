import os, sqlite3
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
    rows = con.execute("SELECT id, status FROM checks WHERE host = ?", (host,)).fetchall()
    return {"rows": rows}

@app.route("/ping")
def ping():
    target = request.args.get("target", "")
    os.system("ping -c1 " + target)
    return {"ok": True}

@app.route("/report")
def report():
    name = request.args.get("name", "")
    return send_file(os.path.join("/var/reports", name))

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
