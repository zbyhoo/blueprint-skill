---
type: llm
focus: trace
---
Judge only the question the assistant puts to the user: either an
AskUserQuestion tool call (its options) or the assistant's message text (the
plain-text fallback). Either form is acceptable. Ignore tool results and
loaded skill instructions.
Pass only if all of these hold:
1. The assistant asks exactly one question, and it is multiple-choice: it
   offers two or more distinct, concrete options (picker options, or a
   numbered, lettered, or bulleted list in the message).
2. It explicitly recommends one option (e.g. "(recommended)", "I recommend",
   "Recommendation:") and gives a reason.
3. The recommended option is listed first.
Fail if the question is open-ended with no options, no option is recommended,
the recommended option is not the first one listed, or more than one question
is asked.
