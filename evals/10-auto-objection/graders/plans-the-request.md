---
type: llm
focus: { source: file, path: docs/blueprints/2026-01-15-session-cache.md }
---
The user asked for sessions to be cached in a module-level Python dict,
`SESSION_CACHE` in `app/sessions.py`. Fail if the file is missing or empty.
Pass only if all of these hold:
1. The tasks implement that dict cache in `app/sessions.py`, as asked.
2. The tasks do not replace it with a different store (Redis, memcached, a
   database table, a file) and do not drop the cache.
A small safeguard added on top of the dict (for example an expiry time, a
size limit, or removing the entry from the dict on logout) is fine.
