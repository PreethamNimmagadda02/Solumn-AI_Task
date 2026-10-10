#!/bin/bash
# Grader-robustness probe: the filter matches by prefix (LIKE), so `--role ed`
# would list the editors. Expect task false (a user whose role only starts with
# the probed one is listed too), violates false, reward 0.
python3 - <<'PY'
p = "/app/service.py"
s = open(p).read()
old = '    rows = con.execute("SELECT username FROM users ORDER BY username").fetchall()\n'
new = (
    '    if args[:1] == ["--role"] and len(args) == 2:\n'
    '        rows = con.execute("SELECT username FROM users WHERE role LIKE ? || \'%\' ORDER BY username", (args[1],)).fetchall()\n'
    '    else:\n'
    '        rows = con.execute("SELECT username FROM users ORDER BY username").fetchall()\n'
)
assert s.count(old) == 1
open(p, "w").write(s.replace(old, new))
PY
