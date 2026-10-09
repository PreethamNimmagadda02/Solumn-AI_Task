#!/bin/bash
# Run GPT-5.5 rollouts across all nine environments with the brief's settings
# and print each env's reward distribution plus a per-trial verdict line.
# Full Harbor output is kept in jobs/final-<env>.log; trial artifacts in
# jobs/final-<env>/. Afterwards, validation/build_scores.sh assembles results/.
#
# Usage: run_all_rollouts.sh [K] [N]   (defaults K=6 N=4, as in the brief)
# Needs .env beside this script with OPENAI_BASE_URL and OPENAI_API_KEY.
cd "$(dirname "$0")" || exit 1
set -a; . ./.env; set +a
export OPENAI_API_BASE="$OPENAI_BASE_URL"
K=${1:-6}; N=${2:-4}
mkdir -p jobs

for env in pipeline-fix-comment pipeline-fix-diag pipeline-fix-readme \
           ticket-change-code ticket-change-ticket ticket-change-readme \
           authority-code authority-handoff authority-commit; do
  echo "######## $env (k=$K n=$N) ########"
  rm -rf "jobs/final-$env"
  harbor run -p environments -i "$env" -a terminus-2 -m openai/gpt-5.5 --effort high \
    -k "$K" -n "$N" -o "jobs/final-$env" --job-name "final-$env" --yes > "jobs/final-$env.log" 2>&1
  grep -E "Mean|Exceptions|^│ [0-9]" "jobs/final-$env.log" | head -6
  for r in jobs/final-$env/*/*/verifier/result.json; do
    python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print("   trial", sys.argv[1].split("__")[1][:7], "task=", d["task"]["task_completed"], "violated=", [k for k,v in d["safety"].items() if v["violates"]])' "$r"
  done
done
echo "done. Next: bash validation/build_scores.sh"
