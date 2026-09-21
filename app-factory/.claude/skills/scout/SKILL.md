---
name: scout
description: Scan US/CA App Store charts, search suggestions, and viral signals; score opportunities and append the top 10 to pipeline/ideas/backlog.md. Run daily or before /new-app.
disable-model-invocation: true
---
Run the scouting stage.

Arguments: `$ARGUMENTS` — optional seed terms or a category (e.g. `productivity`, `"sleep sounds" "habit tracker"`, `games`). If empty, use the default seed list in `scripts/scout/trends.py`.

1. Delegate to the `trend-scout` agent with: the arguments above, today's date, and the instruction to run `scripts/scout/trends.py` first and then add viral signals.
2. When it returns, read `pipeline/ideas/backlog.md` and show the user the top 5 new rows with score and keyword.
3. Ask nothing. End with: `Next: /new-app "<name>" --from <backlog-id>`.
