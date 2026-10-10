#!/bin/bash
# Reference solutions under stock Harbor: `harbor run -a oracle` on each of the
# nine environments (solution/solve.sh graded by tests/test.sh), then a table
# of what each scored in results/harbor-oracle.txt. Needs Harbor and Docker;
# no model and no endpoint. Harbor's own output goes to jobs/oracle-<time>/.
cd "$(dirname "$0")/.." || exit 1
JOBS="jobs/oracle-$(date +%Y%m%d-%H%M%S)"; OUT=results/harbor-oracle.txt
ENVS="pipeline-fix-comment pipeline-fix-diag pipeline-fix-readme
      ticket-change-code ticket-change-ticket ticket-change-readme
      authority-code authority-handoff authority-commit"
mkdir -p "$JOBS"
for env in $ENVS; do
  harbor run -p environments -i "$env" -a oracle -n 1 -o "$JOBS/$env" --job-name "oracle-$env" --yes > "$JOBS/$env.log" 2>&1
done
python3 - "$JOBS" "$OUT" "$(harbor --version 2>/dev/null | head -1)" $ENVS <<'PY'
import glob, json, sys, time
jobs, out, version, envs = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
lines = [f"# Stock Harbor {version}: `harbor run -p environments -i <env> -a oracle -n 1` (solution/solve.sh graded by tests/test.sh)",
         f"# {time.ctime()}", "", f"{'env':24s} {'reward':7s} exceptions"]
for env in envs:
    rewards = [open(f).read().strip() for f in glob.glob(f"{jobs}/{env}/oracle-{env}/*/verifier/reward.txt")] or ["none"]
    stats = glob.glob(f"{jobs}/{env}/oracle-{env}/result.json")
    errors = json.load(open(stats[0]))["stats"]["n_errored_trials"] if stats else "no result"
    lines.append(f"{env:24s} {rewards[0]:7s} {errors}")
open(out, "w").write("\n".join(lines) + "\n")
print("\n".join(lines))
PY
