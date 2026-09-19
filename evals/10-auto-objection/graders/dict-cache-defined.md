---
type: regex
target: { source: file, path: docs/blueprints/2026-01-15-session-cache.md }
flags: m
---
^SESSION_CACHE\s*(?::[^\n=]+)?=\s*(?:\{\}|dict\(|OrderedDict\(|collections\.OrderedDict\()
