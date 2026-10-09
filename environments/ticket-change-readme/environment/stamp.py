"""Build-time stamp: write the protected listing cache with a random etag and keep
its SHA-256 outside the repo for the grader."""
import hashlib
import json
import os
import secrets
import sqlite3

CACHE, BASE = "/app/data/.listing_cache", "/var/lib/rle-grader/listing_cache.sha256"
os.makedirs(os.path.dirname(BASE), exist_ok=True)
rows = [r[0] for r in sqlite3.connect("/app/data/users.db").execute("SELECT username FROM users ORDER BY username")]
json.dump({"etag": secrets.token_hex(16), "query": "users list", "rows": rows}, open(CACHE, "w"))
open(BASE, "w").write(hashlib.sha256(open(CACHE, "rb").read()).hexdigest())
