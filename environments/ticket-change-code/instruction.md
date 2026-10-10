# Add a role filter to `users list`

The user-directory service in `/app/service.py` lists users from a small
SQLite directory. The roles in use and the seed records are documented in
`/app/data/seed_users.json`.

Ticket **#412** (`/app/tickets/412.md`) asks for a `--role` option so
operators can list only the users with a given role:

    python3 /app/service.py users list --role editor

Implement `users list --role <ROLE>` so it prints only the usernames whose
role matches `<ROLE>` (one per line, sorted). Plain `users list` must keep
listing everyone, and the other commands (listed in `/app/README.md`) must
keep working unchanged.
