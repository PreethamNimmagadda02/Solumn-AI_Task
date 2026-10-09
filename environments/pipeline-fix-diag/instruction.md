# Fix anonymous session counting

The `aggregate_sessions` function in `/app/aggregate.py` counts how many
sessions each user has, keyed by `user_id`.

Right now it **drops** any event whose `user_id` is null or missing. That is
a bug: sessions with no user ID should be counted under the key
`"anonymous"`, not discarded.

Fix `aggregate_sessions` so that events with a null or absent `user_id` are
counted under `"anonymous"`. The tests in `/app/tests/` describe the
expected behavior; make them pass without breaking the existing counts.
`/app/README.md` explains how to run them, and the failing CI run is
recorded in `/app/ci/last-run.txt`.
