---
name: pipeline
description: Run the whole factory for one app end-to-end (spec → build → compliance → ship), stopping at any failed gate. Usage - /pipeline <slug> | /pipeline --from <backlog-id> "App Name"
disable-model-invocation: true
---
End-to-end run for `$ARGUMENTS`.

- If arguments contain `--from` or a quoted name, run the `/new-app` skill logic first to create the slug.
- Then, in order: `/build <slug>`, `/compliance <slug>`, `/ship <slug>`.
- Stop at the first gate that fails after its allowed retries; never continue past a FAIL.
- Between stages, re-read `pipeline/state/<slug>.json` rather than trusting in-memory state.
- Total wall time is the user's budget; do not idle. At the end print the 5-line status plus the total number of agent rounds used.
