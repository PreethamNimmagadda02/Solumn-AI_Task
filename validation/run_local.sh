#!/bin/bash
# Local grading harness (no model). Builds an environment, applies an implementation
# script in place of the agent (the reference solution is available to it as
# /tmp/solve.sh), runs the grader the way Harbor does, and compares the reward.
# An environment with environment/docker-compose.yaml gets its sidecar via a
# throwaway compose project merged the way Harbor merges it.
#
# Usage: run_local.sh <env_dir> <impl_script> <expected_reward> [label]
#   SAVE_TO=<dir>   also copy the emitted reward.txt + result.json there
set -u
ENV_DIR="$(cd "$1" && pwd)"; IMPL="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
EXPECTED="$3"; LABEL="${4:-impl}"; NAME="$(basename "$ENV_DIR")"
COMPOSE="$ENV_DIR/environment/docker-compose.yaml"

if [ -f "$COMPOSE" ]; then
  PROJ="rle$(echo "$NAME$$" | tr -cd 'a-z0-9')"; TMP="$(mktemp -d)"
  printf 'services:\n  main:\n    build: {context: .}\n    command: ["sleep", "900"]\n' > "$TMP/base.yaml"
  dc() { docker compose --project-directory "$ENV_DIR/environment" -p "$PROJ" -f "$TMP/base.yaml" -f "$COMPOSE" "$@"; }
  trap 'dc down -v >/dev/null 2>&1; rm -rf "$TMP"' EXIT
  dc up -d --build >"$TMP/up.log" 2>&1 || { echo "COMPOSE UP FAILED"; tail -20 "$TMP/up.log"; exit 2; }
  cid="$(dc ps -q main)"
else
  docker build -q -t "rle-$NAME" "$ENV_DIR/environment" >/dev/null || { echo "BUILD FAILED"; exit 2; }
  cid="$(docker run -d --network none "rle-$NAME" sleep 900)"
  trap 'docker rm -f "$cid" >/dev/null 2>&1' EXIT
fi

docker cp "$ENV_DIR/tests/." "$cid:/tests/" >/dev/null
docker cp "$ENV_DIR/solution/solve.sh" "$cid:/tmp/solve.sh" >/dev/null
docker cp "$IMPL" "$cid:/tmp/impl.sh" >/dev/null
docker exec "$cid" bash -lc 'cd /app && bash /tmp/impl.sh' >/dev/null 2>&1
docker exec "$cid" bash -lc 'bash /tests/test.sh' >/dev/null 2>&1

got="$(docker exec "$cid" cat /logs/verifier/reward.txt 2>/dev/null | tr -d '[:space:]')"
if [ -n "${SAVE_TO:-}" ]; then
  mkdir -p "$SAVE_TO"
  docker cp "$cid:/logs/verifier/reward.txt" "$SAVE_TO/" >/dev/null 2>&1
  docker cp "$cid:/logs/verifier/result.json" "$SAVE_TO/" >/dev/null 2>&1
fi
docker exec "$cid" cat /logs/verifier/result.json 2>/dev/null; echo
[ "$got" = "$EXPECTED" ] && echo "=== expected=$EXPECTED got=$got === PASS ($LABEL)" || { echo "=== expected=$EXPECTED got=$got === MISMATCH ($LABEL)"; exit 1; }
