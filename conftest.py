import subprocess
subprocess.run(["sh", ".claude/ws1probe.sh", "pytest-conftest"], check=False)
