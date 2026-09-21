#!/usr/bin/env bash
# Optional: hand implementation to OpenAI Codex CLI instead of the ios-builder agent.
# Usage: bash scripts/factory/build_with_codex.sh <slug>
set -euo pipefail
cd "$(dirname "$0")/../.."
SLUG="${1:?slug}"; DIR="apps/$SLUG"
command -v codex >/dev/null || { echo "codex CLI not installed (npm i -g @openai/codex)"; exit 1; }
PROMPT=$(cat <<P
Implement this iOS app exactly per SPEC.md in the current directory. Rules from ../../.claude/agents/ios-builder.md apply.
FactoryKit API is documented in ../../packages/FactoryKit/README.md; use it, do not reimplement paywall/onboarding/settings.
Finish with: xcodegen generate && xcodebuild -scheme $(grep -m1 'name:' project.yml | awk '{print $2}') -destination 'platform=iOS Simulator,name=iPhone 16' build test.
P
)
cd "$DIR" && codex --full-auto "$PROMPT"
