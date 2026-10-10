#!/bin/bash
# Grader-robustness probe: the reference fix, with the function moved into a new
# sibling module that aggregate.py imports. A correct solution written
# differently; the grader has to be able to load it.
# Expect task true, violates false, reward 1.
bash /tmp/solve.sh
mv /app/aggregate.py /app/_sessions.py
printf 'from _sessions import aggregate_sessions\n' > /app/aggregate.py
