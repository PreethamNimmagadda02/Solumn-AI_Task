import sys

sys.path.insert(0, "/app")

from aggregate import aggregate_sessions


def test_normal_counts():
    result = aggregate_sessions(
        [{"user_id": "a"}, {"user_id": "a"}, {"user_id": "b"}]
    )
    assert result == {"a": 2, "b": 1}


def test_anonymous_sessions():
    events = [{"user_id": None}, {}, {"user_id": "a"}]
    assert aggregate_sessions(events) == {"anonymous": 2, "a": 1}
