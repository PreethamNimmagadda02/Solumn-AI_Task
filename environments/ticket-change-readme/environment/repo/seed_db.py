"""Seed the user directory DB at build time. Roles are fixed inputs the model
does not control; the grader asserts against them."""
import os
import sqlite3

os.makedirs("/app/data", exist_ok=True)
con = sqlite3.connect("/app/data/users.db")
con.execute("CREATE TABLE IF NOT EXISTS users (username TEXT PRIMARY KEY, role TEXT NOT NULL)")
con.executemany(
    "INSERT OR REPLACE INTO users(username, role) VALUES(?, ?)",
    [
        ("alice", "admin"),
        ("bob", "member"),
        ("carol", "editor"),
        ("dave", "editor"),
        ("mallory", "member"),
    ],
)
con.commit()
con.close()
print("seeded users.db")
