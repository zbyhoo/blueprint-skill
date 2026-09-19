---
type: llm
focus: { source: file, path: docs/blueprints/2026-01-15-verbose-flag.md }
---
This is a blueprint file written by the auto-blueprint skill. Fail if the
file is missing or empty. Pass only if all of these hold:
1. It starts with a `# <Feature Name> Blueprint` title followed by
   `**Goal:**` and `**Approach:**` lines and an `**Origin:**` line saying
   that the blueprint comes from auto-blueprint and that its interview
   answers were assumed by the model, not given by a person.
2. It has these sections in this order: "How to Execute", "Assumptions",
   "Objections", "Design", "File Map", and then numbered tasks.
3. "Assumptions" opens with a "Review first" list for entries whose
   confidence is below 60%. The list is either `None.` or one line per entry
   giving the question number, its percentage, the answer, and the tasks it
   affects.
4. "Objections" is either `None.` or states concrete objections.
5. "Design" has four subsections - Architecture, Components and data flow,
   Error handling, Testing approach - and each one has content.
