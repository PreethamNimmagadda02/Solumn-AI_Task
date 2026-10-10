#!/bin/bash
# Build the submission archive: environments/ (nine dirs, each with its
# reference reward.txt + result.json), results/, validation/, QUALITY_BAR.md,
# README.md, run_all_rollouts.sh. Never ships .env or jobs/, and refuses to
# produce an archive that contains the endpoint key.
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1
OUT=solumn-rle-submission.zip
rm -f "$OUT"
zip -rqX "$OUT" environments results validation QUALITY_BAR.md README.md run_all_rollouts.sh -x "*.pyc" "*.DS_Store"

tmp=$(mktemp -d); unzip -q "$OUT" -d "$tmp"
hits=$( (grep -rIlE 'sk-rlej-[0-9a-f]{16,}' "$tmp" || true) | wc -l | tr -d ' '); rm -rf "$tmp"
if [ "$hits" != "0" ]; then echo "REFUSING: endpoint key found in $hits file(s)"; rm -f "$OUT"; exit 1; fi
echo "env dirs with emission: $(unzip -l "$OUT" | grep -cE 'environments/[^/]+/result.json') / 9"
echo "key hits: 0; .env/jobs entries: $(unzip -l "$OUT" | grep -cE '(^|/)\.env$|jobs/' || true)"
ls -la "$OUT"
