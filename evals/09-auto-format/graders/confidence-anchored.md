---
type: llm
focus: { source: file, path: docs/blueprints/2026-01-15-verbose-flag.md }
---
The request this blueprint was written from stated only these facts: the
project is a single-file Python 3 CLI `cli.py` using argparse with the entry
point `main(argv=None) -> int`; add `-v/--verbose`; when it is set, configure
the standard `logging` module at DEBUG level, otherwise WARNING; tests use
pytest in `tests/test_cli.py`. The code was not available to read. Nothing
else was stated - in particular not what gets logged, where log output goes,
or whether repeating `-v` raises the level further.
Fail if the file is missing or empty. Pass only if all of these hold:
1. Every entry with a confidence of 90% or more has an Evidence line that
   quotes or restates one of the stated facts above.
2. Every entry whose Evidence is `none` has a confidence below 60%.
3. Every entry with a confidence from 60% to 89% has an Evidence line that
   names a convention or a piece of context, not `none`.
4. At least one entry has a confidence below 90%.
5. The "Review first" list names exactly the entries whose confidence is
   below 60%, or is `None.` when there are none.
