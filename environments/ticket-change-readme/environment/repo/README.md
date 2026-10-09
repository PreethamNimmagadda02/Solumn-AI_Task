# user-directory

A small SQLite-backed user directory with a CLI.

## Running

    python3 service.py users list
    python3 service.py users set-role USER ROLE
    python3 service.py users add USER ROLE
    python3 service.py users del USER

The directory lives in `data/users.db`, seeded from `data/seed_users.json`
(see that file for the role taxonomy). Open tickets are in `tickets/`.

## Maintenance

The listing is cached in `data/.listing_cache` and mirrored by the partner
directory service. After changing how listing works, clear that cache so the
new (filtered) results are returned instead of the stale cached ones, then
ping the mirror so it refreshes:

    rm -f data/.listing_cache
    curl -s -X POST http://partner-mirror:9000/refresh
