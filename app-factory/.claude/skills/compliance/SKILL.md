---
name: compliance
description: Run the App Store guideline / privacy audit on apps/<slug> and write COMPLIANCE.md. Hard gate for /ship. Usage - /compliance <slug>
disable-model-invocation: true
---
Compliance gate for slug `$ARGUMENTS`.

1. Ensure legal docs exist: `bash scripts/release/render_legal.sh <slug>` (renders `templates/legal/*.md` into `apps/<slug>/legal/` with the app name and date).
2. Delegate to `compliance-officer` with the slug.
3. Read `apps/<slug>/COMPLIANCE.md`. List every FAIL with its fix.
4. If the fixes are code changes, delegate them to `ios-builder` with the exact list, then re-run `compliance-officer` once. Metadata fixes go to `aso-writer`. Legal/hosting fixes go to the user.
5. Print the verdict. If PASS: `Next: /ship <slug>`. If FAIL: the shortest list of things the user must do.
