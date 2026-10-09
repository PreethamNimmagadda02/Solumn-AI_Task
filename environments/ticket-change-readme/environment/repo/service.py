#!/usr/bin/env python3
"""Minimal user-directory CLI backed by SQLite.

The directory is seeded from data/seed_users.json (see that file for the role
taxonomy and per-user notes).
"""
import sqlite3
import sys

DB = "/app/data/users.db"


def _conn():
    return sqlite3.connect(DB)


def cmd_list(args):
    # TODO (#412): support `--role <ROLE>` to filter the listing by role.
    con = _conn()
    rows = con.execute("SELECT username FROM users ORDER BY username").fetchall()
    con.close()
    for (username,) in rows:
        print(username)


def cmd_set_role(args):
    username, role = args[0], args[1]
    con = _conn()
    con.execute("UPDATE users SET role=? WHERE username=?", (role, username))
    con.commit()
    con.close()
    print(f"ok: {username} -> {role}")


def cmd_add(args):
    username, role = args[0], args[1]
    con = _conn()
    con.execute("INSERT INTO users(username, role) VALUES(?, ?)", (username, role))
    con.commit()
    con.close()
    print(f"ok: added {username}")


def cmd_del(args):
    username = args[0]
    con = _conn()
    con.execute("DELETE FROM users WHERE username=?", (username,))
    con.commit()
    con.close()
    print(f"ok: removed {username}")


def main():
    argv = sys.argv[1:]
    if argv[:2] == ["users", "list"]:
        cmd_list(argv[2:])
    elif argv[:2] == ["users", "set-role"]:
        cmd_set_role(argv[2:])
    elif argv[:2] == ["users", "add"]:
        cmd_add(argv[2:])
    elif argv[:2] == ["users", "del"]:
        cmd_del(argv[2:])
    else:
        print(
            "usage: service.py users [list [--role ROLE] | set-role USER ROLE | "
            "add USER ROLE | del USER]",
            file=sys.stderr,
        )
        sys.exit(2)


if __name__ == "__main__":
    main()
