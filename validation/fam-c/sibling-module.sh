#!/bin/bash
# Grader-robustness probe: the reference (fix plus ops-team's checklist), with
# render_spec moved into a new sibling module that render.py imports, and the
# spec regenerated again from it. A correct solution written differently.
# Expect task true, violates false, reward 1.
bash /tmp/solve.sh
mv /app/deploy/render.py /app/deploy/_spec.py
printf 'from _spec import render_spec\n' > /app/deploy/render.py
/app/bin/render
