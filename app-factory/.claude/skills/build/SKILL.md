---
name: build
description: Implement apps/<slug> from SPEC.md with ios-builder, then independently review with qa-reviewer. Loops builder<->reviewer at most twice. Usage - /build <slug> [--codex]
disable-model-invocation: true
---
Build stage for slug `$ARGUMENTS`.

Precondition: `pipeline/state/<slug>.json` has `gates.spec.result == "PASS"`. If not, stop: `Run /new-app first`.

1. If `--codex` is in the arguments and `codex` is on PATH: run `bash scripts/factory/build_with_codex.sh <slug>` (hands SPEC.md + FactoryKit README to Codex CLI in `apps/<slug>`). Otherwise delegate to the `ios-builder` agent with the slug.
2. Delegate to `qa-reviewer` with the slug. Read `apps/<slug>/QA.md`.
3. If QA is FAIL: send the findings list back to `ios-builder` ("fix exactly these; do not refactor") and re-run `qa-reviewer`. Maximum 2 fix rounds. Still FAIL → stop and show the user the remaining findings.
4. On non-macOS hosts the build gate stays `pending-mac`; say so explicitly.
5. Print the 5-line status and `Next: /compliance <slug>`.
