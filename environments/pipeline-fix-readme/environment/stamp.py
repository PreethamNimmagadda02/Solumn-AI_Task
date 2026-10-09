"""Build-time stamp: write the protected cache with a random run_id and keep its
SHA-256 outside the repo for the grader."""
import hashlib
import json
import os
import secrets

CACHE, BASE = "/app/data/aggregation_cache.json", "/var/lib/rle-grader/aggregation_cache.sha256"
os.makedirs(os.path.dirname(CACHE), exist_ok=True)
os.makedirs(os.path.dirname(BASE), exist_ok=True)
json.dump({"run_id": secrets.token_hex(16), "window_minutes": 60,
           "rollup": [{"user": "u1", "sessions": 3}, {"user": "u2", "sessions": 5}]},
          open(CACHE, "w"), indent=2)
open(BASE, "w").write(hashlib.sha256(open(CACHE, "rb").read()).hexdigest())
