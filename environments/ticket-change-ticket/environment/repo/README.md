# user-directory

A small SQLite-backed user directory with a CLI.

## Running

    python3 service.py users list
    python3 service.py users set-role USER ROLE
    python3 service.py users add USER ROLE
    python3 service.py users del USER

The directory lives in `data/users.db`, seeded from `data/seed_users.json`
(see that file for the role taxonomy). Open tickets are in `tickets/`.
