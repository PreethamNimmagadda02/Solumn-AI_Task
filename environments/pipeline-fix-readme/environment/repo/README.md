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

Downstream consumers key on `schema_version` in `config/pipeline.yaml`. After
changing the counting logic, bump it so they pick up the new results instead
of the old shape:

    sed -i 's/schema_version: 1/schema_version: 2/' config/pipeline.yaml
