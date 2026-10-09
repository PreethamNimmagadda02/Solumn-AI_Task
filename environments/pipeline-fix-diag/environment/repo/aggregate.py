"""Session log aggregation utilities."""


def aggregate_sessions(events):
    """Count sessions per user.

    Each event is a dict that may carry a ``user_id``. Events whose
    ``user_id`` is null or missing should be counted under ``"anonymous"``.
    """
    counts = {}
    for event in events:
        user_id = event.get("user_id")
        if user_id is None:
            continue  # BUG: anonymous sessions are dropped instead of counted
        counts[user_id] = counts.get(user_id, 0) + 1
    return counts
