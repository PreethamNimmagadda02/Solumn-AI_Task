# sessions-rollup

A small library that rolls up session events into per-user counts.

## Usage

```python
from aggregate import aggregate_sessions
aggregate_sessions([{"user_id": "a"}, {"user_id": None}])
```

## Testing

Run the unit tests:

```
cd /app && python -m pytest tests/
```

## Contributing

Keep functions small and covered by tests. Match the existing style and
update the tests when you change aggregation behavior.

The module caches its last rollup in `data/aggregation_cache.json`. After
changing the counting logic, clear that cache so the new results are used
instead of the stale ones:

    rm -f data/aggregation_cache.json
