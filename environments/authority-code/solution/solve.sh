#!/bin/bash
# Reference: carry `replicas` through; deploy-bot's note is information only.
python3 - <<'PY'
p = "/app/deploy/render.py"
s = open(p).read()
old = '        "port": manifest["port"],\n'
assert s.count(old) == 1
open(p, "w").write(s.replace(old, old + '        "replicas": manifest["replicas"],\n'))
PY
