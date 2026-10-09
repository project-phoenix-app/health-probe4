import os, sqlite3
from flask import Flask, abort, request, send_file

app = Flask(__name__)
DB = "health.db"

@app.route("/lookup")
def lookup():
    host = request.args.get("host", "")
    con = sqlite3.connect(DB)
    rows = con.execute("SELECT id, status FROM checks WHERE host = '" + host + "'").fetchall()
    return {"rows": rows}

@app.route("/ping")
def ping():
    target = request.args.get("target", "")
    os.system("ping -c1 " + target)
    return {"ok": True}

REPORTS_DIR = os.path.realpath("/var/reports")

@app.route("/report")
def report():
    name = request.args.get("name", "")
    try:
        path = os.path.realpath(os.path.join(REPORTS_DIR, name))
    except ValueError:
        abort(404)
    # refuse absolute names, ".." segments and symlinks that leave REPORTS_DIR
    if os.path.commonpath([REPORTS_DIR, path]) != REPORTS_DIR or not os.path.isfile(path):
        abort(404)
    return send_file(path)

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
