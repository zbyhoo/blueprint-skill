---
type: llm
focus: trace
---
Judge only what the assistant itself shows the user (its message text and any
AskUserQuestion tool call), not tool results or loaded skill instructions.
Pass only if all of these hold:
1. The assistant ends its turn by asking the user a question about the
   feature (its purpose, scope, constraints, or a design choice) instead of
   finishing the work.
2. It asks exactly ONE question: a single AskUserQuestion call with one
   question, or a message that poses one question. One multiple-choice
   question with listed options counts as one question. Two or more separate
   questions (numbered, bulleted, or in prose) fail.
3. It does not present implementation code for the flag.
