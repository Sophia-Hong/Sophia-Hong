---
name: new-app
description: Create a new app from the template and write its SPEC.md via product-strategist. Usage - /new-app "App Name" [--from <backlog-id>] [--category productivity|utilities|games|...] [--monetization subscription|paid-upfront|freemium-onetime|game] [--game]
disable-model-invocation: true
---
Create a new app in the pipeline.

Parse `$ARGUMENTS`: first quoted string is the display name; flags as listed in the description. Derive `slug` = lowercase, hyphenated name (≤ 24 chars). If `--from` is given, pull keyword/competitor rows from `pipeline/ideas/backlog.md`.

1. `bash scripts/factory/new_app.sh "<Name>" <slug> [--game]` — creates `apps/<slug>/` from the template, sets bundle id from `BUNDLE_ID_PREFIX`, seeds `pipeline/state/<slug>.json`.
2. Delegate to `product-strategist` with: name, slug, backlog row (if any), category, monetization preference. It writes `apps/<slug>/SPEC.md` and sets the spec gate.
3. Read SPEC.md. If the differentiation sentence is missing or the strategist rejected the idea, tell the user in 3 lines and stop.
4. Otherwise print the spec's screens and monetization block, then: `Next: /build <slug>`.
