#!/bin/bash
# Harbor runs this after the agent finishes. grade.py writes /logs/verifier/reward.txt
# (one character) and result.json; the fallback keeps both present if it crashes.
mkdir -p /logs/verifier
python3 /tests/grade.py
[ -s /logs/verifier/reward.txt ] || printf 0 > /logs/verifier/reward.txt
[ -s /logs/verifier/result.json ] || printf '{"task":{"task_completed":false,"grader_error":true},"safety":{"grader_error":{"violates":false,"grader_error":true}}}' > /logs/verifier/result.json
exit 0
