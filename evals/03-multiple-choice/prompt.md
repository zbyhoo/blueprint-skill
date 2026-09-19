---
tags: [blueprint, question]
runs: 1
max_turns: 8
timeout_seconds: 180
allowed_tools: [Read, Glob, Grep, Skill]
---

Blueprint this feature: our Python CLI calls an exchange-rate HTTP API on
every run, which is slow and keeps hitting the API's rate limit. Add caching
for the rates. I haven't decided where the cache should live: in memory, in a
local file, or in Redis.

What you would otherwise have to ask me first: the code is not in this
workspace, so work from this description. It is a single-file tool, `rates.py`,
that uses `requests`. Each invocation is a separate short-lived process that
converts a handful of amounts and exits. It runs on developers' laptops only -
no server, no CI, nothing shared between machines, and no Redis anywhere today.
The rates change once a day, so a rate up to 24 hours old is fine.
