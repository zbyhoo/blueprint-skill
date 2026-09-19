---
type: regex
target: { source: file, path: docs/blueprints/2026-01-15-session-cache.md }
flags: im
---
^## Objections\n(?:(?!\n## )[\s\S])*?(?:Redis|memcached|shared (?:cache|store)|NOTIFY|time-to-live|\bTTL\b|expir|invalidat)
