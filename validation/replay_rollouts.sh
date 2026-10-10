#!/bin/bash
# Re-grade the recorded rollouts with the current graders, without a model.
# For every trial under results/rollouts, the commands the agent typed (the
# keystrokes in its trajectory.json) are run again, in order, in a fresh
# container, and tests/test.sh grades what they leave behind. The verdict is
# compared with the result.json recorded during the run.
# Writes results/replay.txt, a verdict line per trial.
cd "$(dirname "$0")/.." || exit 1
OUT=results/replay.txt; TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
{ echo "# SAME = task_completed and the set of violating safety checks match the verdict recorded during the run"; echo "# $(date)"; echo; } > "$OUT"

for traj in results/rollouts/*/trial-*/trajectory.json; do
  trial=$(dirname "$traj"); env=$(basename "$(dirname "$trial")"); d="$TMP/emission"; rm -rf "$d"
  python3 -c '
import json, sys
print("".join(c["arguments"].get("keystrokes", "") for s in json.load(open(sys.argv[1]))["steps"] for c in s.get("tool_calls") or []), end="")' "$traj" > "$TMP/typed.sh"
  SAVE_TO="$d" bash validation/run_local.sh "environments/$env" "$TMP/typed.sh" >/dev/null 2>&1
  python3 -c '
import json, sys
trial, d = sys.argv[1], sys.argv[2]
verdict = lambda r: (r["task"]["task_completed"], sorted(k for k, c in r["safety"].items() if c["violates"]))
try:
    old, new = verdict(json.load(open(trial + "/result.json"))), verdict(json.load(open(d + "/result.json")))
    line = "recorded task_completed=%s violates=%s | replayed task_completed=%s violates=%s === %s" % (*old, *new, "SAME" if old == new else "DIFFERENT")
except Exception as exc:
    line = f"=== DIFFERENT (no emission: {exc!r})"
print(f"{trial[8:]:38s} {line}")' "$trial" "$d" | tee -a "$OUT"
done

{ echo; echo "SAME: $(grep -c '=== SAME' "$OUT") / DIFFERENT: $(grep -c 'DIFFERENT' "$OUT") (of $(grep -c '^r' "$OUT"))"; } >> "$OUT"
tail -1 "$OUT"
