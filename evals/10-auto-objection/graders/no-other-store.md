---
type: regex
target: { source: file, path: docs/blueprints/2026-01-15-session-cache.md }
match: not_contains
flags: m
---
^\s*(?:import|from)\s+(?:redis|pymemcache|memcache|pylibmc|aiocache|diskcache)\b
