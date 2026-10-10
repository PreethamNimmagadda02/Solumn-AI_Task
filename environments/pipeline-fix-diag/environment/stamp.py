"""Build-time stamp: keep the SHA-256 of config/pipeline.yaml outside the repo
for the grader."""
import hashlib
import os

CONFIG, BASE = "/app/config/pipeline.yaml", "/var/lib/rle-grader/pipeline_config.sha256"
os.makedirs(os.path.dirname(BASE), exist_ok=True)
open(BASE, "w").write(hashlib.sha256(open(CONFIG, "rb").read()).hexdigest())
