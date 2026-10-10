#!/bin/bash
# Local grading harness (no model). Builds an environment, applies an implementation
# script in place of the agent (the reference solution is available to it as
# /tmp/solve.sh), runs the grader the way Harbor does, and prints what it emitted.
# An environment with environment/docker-compose.yaml gets its sidecar via a
# throwaway compose project merged the way Harbor merges it.
#
# Usage: run_local.sh <env_dir> <impl_script>
#   SAVE_TO=<dir>   also copy the emitted reward.txt + result.json there
#   FRESH_FILES=1   rewrite /app in place between creating and starting the
#                   container, so every file is as new as a just-unpacked image
#                   layer (single-container environments only)
set -u
ENV_DIR="$(cd "$1" && pwd)"; IMPL="$2"; NAME="$(basename "$ENV_DIR")"
COMPOSE="$ENV_DIR/environment/docker-compose.yaml"

if [ -f "$COMPOSE" ]; then
  PROJ="rle$(echo "$NAME$$" | tr -cd 'a-z0-9')"; TMP="$(mktemp -d)"
  printf 'services:\n  main:\n    build: {context: .}\n    command: ["sleep", "900"]\n' > "$TMP/base.yaml"
  dc() { docker compose --project-directory "$ENV_DIR/environment" -p "$PROJ" -f "$TMP/base.yaml" -f "$COMPOSE" "$@"; }
  trap 'dc down -v --rmi local >/dev/null 2>&1; rm -rf "$TMP"' EXIT
  dc up -d --build >"$TMP/up.log" 2>&1 || { echo "COMPOSE UP FAILED"; tail -20 "$TMP/up.log"; exit 2; }
  cid="$(dc ps -q main)"
else
  docker build -q -t "rle-$NAME" "$ENV_DIR/environment" >/dev/null || { echo "BUILD FAILED"; exit 2; }
  cid="$(docker create --network none "rle-$NAME" sleep 900)"
  trap 'docker rm -f "$cid" >/dev/null 2>&1' EXIT
  if [ -n "${FRESH_FILES:-}" ]; then
    FT="$(mktemp -d)"; docker cp "$cid:/app" "$FT" >/dev/null && docker cp "$FT/app/." "$cid:/app/" >/dev/null; rm -rf "$FT"
  fi
  docker start "$cid" >/dev/null
fi

docker cp "$ENV_DIR/tests/." "$cid:/tests/" >/dev/null
docker cp "$ENV_DIR/solution/solve.sh" "$cid:/tmp/solve.sh" >/dev/null
docker cp "$IMPL" "$cid:/tmp/impl.sh" >/dev/null
docker exec "$cid" bash -lc 'cd /app && bash /tmp/impl.sh' >/dev/null 2>&1
docker exec "$cid" bash -lc 'bash /tests/test.sh' >/dev/null 2>&1

[ -z "${SAVE_TO:-}" ] || { mkdir -p "$SAVE_TO" && docker cp "$cid:/logs/verifier/." "$SAVE_TO/" >/dev/null 2>&1; }
docker exec "$cid" sh -c 'cat /logs/verifier/result.json; echo; echo "reward: $(cat /logs/verifier/reward.txt)"'
