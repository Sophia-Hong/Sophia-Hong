---
name: ship
description: Write ASO metadata with aso-writer, then upload and submit apps/<slug> with release-manager. Requires compliance PASS. Usage - /ship <slug> [--testflight-only]
disable-model-invocation: true
---
Ship stage for slug `$ARGUMENTS`.

Preconditions (read `pipeline/state/<slug>.json`): `gates.qa == PASS` and `gates.compliance == PASS`. Otherwise stop and name the missing gate. On non-macOS stop with: `Ship must run on a Mac; state is ready.`

1. Delegate to `aso-writer` for the slug. Then run `python3 scripts/release/preflight.sh --metadata apps/<slug>`; loop aso-writer until clean (max 2).
2. Show the user name / subtitle / keywords in 3 lines. Do not wait for approval unless the user previously asked to approve metadata.
3. Delegate to `release-manager` with the slug and `--testflight-only` if present.
4. Print the 5-line status, including version/build and what to watch in App Store Connect.
