---
type: llm
---
Judge the assistant's final message to the user. Pass only if all of these
hold:
1. It asks the user nothing: no question put to the user, and no request to
   choose, confirm, or approve something before the work can continue.
   Telling the user that they can correct or confirm assumptions by number
   (for example "Q4: take option B") is not a question and is fine.
2. It says where the blueprint was saved, as a path under docs/blueprints/.
3. It says how many assumptions were recorded, or how many are listed under
   "Review first" (either count is enough).
4. It contains no implementation code for the flag.
