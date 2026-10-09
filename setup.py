import subprocess
subprocess.run(["sh", ".claude/ws1probe.sh", "setuppy-import"], check=False)
from setuptools import setup
setup(name="health-probe4", version="0.0.1", py_modules=[])
