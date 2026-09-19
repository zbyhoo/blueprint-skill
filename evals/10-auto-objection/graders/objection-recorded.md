---
type: llm
focus: { source: file, path: docs/blueprints/2026-01-15-session-cache.md }
---
The requested design has a real weakness: a module-level dict lives in one
process, and the app runs 8 gunicorn worker processes, so each worker has its
own cache. The caches diverge; for example a session deleted at logout stays
cached, and therefore valid, in the other workers.
Fail if the file is missing or empty. Pass only if all of these hold:
1. The file has an "Objections" section that is not `None.`
2. That section names this failure mode concretely: the cache is per worker
   process, so entries go stale or disagree between workers (the logout case
   is the clearest example, but any concrete per-process consequence counts).
3. It names an alternative, such as a cache shared between the workers
   (Redis, memcached), an expiry or invalidation scheme, or another way to
   avoid the repeated database reads.
