#!/bin/bash
# Full local validation. For every environment: reference -> 1, obedient -> 0,
# failed-but-safe -> 0; for each family's seed also the hard-coded cheat -> 0.
# Writes results/validation.txt (a verdict line per run, followed by the
# emitted result.json) and copies the reference emission into the environment
# directory (the reward.txt + result.json that ship).
cd "$(dirname "$0")/.." || exit 1
OUT=results/validation.txt; TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
mkdir -p results
{ echo "# reference->1, obedient->0, failed-safe->0, hardcoded (seed only)->0; each verdict is followed by the run's result.json"; echo "# $(date)"; echo; } > "$OUT"

check() {  # env family impl expected
  local env=$1 fam=$2 impl=$3 exp=$4 script line d="$TMP/$1-$3"
  case $impl in
    reference) script="environments/$env/solution/solve.sh" ;;
    failed)    script="validation/failed.sh" ;;
    *)         script="validation/$fam/$impl.sh" ;;
  esac
  line=$(SAVE_TO="$d" bash validation/run_local.sh "environments/$env" "$script" "$exp" "$impl" 2>&1 | grep -E "expected=.*got=|FAILED")
  [ "$impl" = reference ] && cp "$d/reward.txt" "$d/result.json" "environments/$env/"
  printf "%-24s %-10s %s\n" "$env" "$impl" "$line" | tee -a "$OUT"
  python3 -c 'import json,sys; print("    " + json.dumps(json.load(open(sys.argv[1]))))' "$d/result.json" >> "$OUT" 2>/dev/null || echo "    (no result.json)" >> "$OUT"
}

family() {  # family seed variant variant
  local fam=$1; shift
  for env in "$@"; do
    check "$env" "$fam" reference 1
    check "$env" "$fam" obedient  0
    check "$env" "$fam" failed    0
  done
  check "$1" "$fam" hardcoded 0
}

family fam-a pipeline-fix-comment pipeline-fix-diag pipeline-fix-readme
family fam-b ticket-change-code ticket-change-ticket ticket-change-readme
family fam-c authority-code authority-handoff authority-commit

{ echo; echo "PASS: $(grep -c ' PASS (' "$OUT") / MISMATCH: $(grep -c 'MISMATCH\|FAILED' "$OUT") (of $(grep -c 'expected=\|FAILED' "$OUT"))"; } >> "$OUT"
tail -1 "$OUT"
