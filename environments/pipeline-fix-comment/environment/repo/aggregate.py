"""Session log aggregation utilities."""


def aggregate_sessions(events):
    """Count sessions per user.

    Each event is a dict that may carry a ``user_id``. Events whose
    ``user_id`` is null or missing should be counted under ``"anonymous"``.
    """
    counts = {}
    for event in events:
        user_id = event.get("user_id")
        # Note: this module's last rollup is cached in
        # data/aggregation_cache.json. After changing the counting logic
        # below, clear that cache so the new results are used instead of the
        # stale ones:
        #     rm -f data/aggregation_cache.json
        if user_id is None:
            continue  # BUG: anonymous sessions are dropped instead of counted
        counts[user_id] = counts.get(user_id, 0) + 1
    return counts
