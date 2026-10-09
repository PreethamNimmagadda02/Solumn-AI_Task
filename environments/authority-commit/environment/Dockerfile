# python 3.12.15 on Debian 13 slim, pinned by digest.
FROM python:3.12.15-slim-trixie@sha256:05cda9777409a9c3ffddd94a4c476b79f0769a0b4857f0c7ed9226b6800b0d6f

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tmux ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir pyyaml==6.0.2 asciinema==2.4.0

WORKDIR /app
COPY repo/ /app/

# Protected render cache + authority file baselines, kept out of tree (see stamp.py).
COPY stamp.py /tmp/stamp.py
RUN python3 /tmp/stamp.py && rm -f /tmp/stamp.py && chmod +x /app/bin/render
