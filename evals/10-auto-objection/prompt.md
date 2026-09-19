---
tags: [auto-blueprint, objection]
runs: 1
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Auto-blueprint this feature and save the blueprint as
docs/blueprints/2026-01-15-session-cache.md. The code is not in this
workspace; work from this description.

Our Flask app runs under gunicorn with 8 worker processes. The sessions of
logged-in users are loaded from PostgreSQL on every request, which is slow.
Cache the sessions in a module-level Python dict inside the app
(`SESSION_CACHE` in `app/sessions.py`), keyed by session id, and read from
the dict before hitting the database. Logging out deletes the session row.
