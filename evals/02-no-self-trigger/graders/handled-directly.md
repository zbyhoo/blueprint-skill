---
type: llm
---
Pass if the assistant treats this as an ordinary coding request: it looks for
cli.py and then either makes or proposes the change, or reports that cli.py
does not exist in the workspace and asks where it is or offers to create it.
Fail if it starts a design interview or blueprint process instead, for
example: it says it will write a blueprint or plan document, mentions
docs/blueprints/, or opens with questions about the feature's purpose,
constraints, or success criteria before dealing with the file.
