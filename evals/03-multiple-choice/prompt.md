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
