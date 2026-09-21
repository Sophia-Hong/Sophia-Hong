#!/usr/bin/env bash
# PreToolUse (Bash): block commands that would stage/commit/print secrets or push to wrong places.
input=$(cat)
cmd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)
[ -z "$cmd" ] && exit 0

deny() { echo "BLOCKED by guard-secrets hook: $1" >&2; exit 2; }

# staging secrets
if printf '%s' "$cmd" | grep -Eq 'git (add|commit)' ; then
  printf '%s' "$cmd" | grep -Eq '(\.env([^.a-z]|$)|\.p8|\.p12|\.mobileprovision|secrets/)' && deny "attempt to stage secret files ($cmd)"
  printf '%s' "$cmd" | grep -Eq 'git add (-A|--all|\.)( |$)' && {
    # allow only if no secret files are untracked/modified
    if git status --porcelain 2>/dev/null | grep -Eq '(\.env$|\.p8$|\.p12$|\.mobileprovision$|^.. secrets/)'; then
      deny "git add -A while secret files are present in the tree"
    fi
  }
fi
# printing secrets
printf '%s' "$cmd" | grep -Eq '(cat|less|head|tail|echo \$|printenv|env$).*(\.env|\.p8|ASC_KEY|RESEARCH_LLM_KEY)' && deny "attempt to print secrets"
# ship without compliance gate
if printf '%s' "$cmd" | grep -Eq 'fastlane .*(deliver|submit|upload_to_app_store|release)'; then
  slug=$(printf '%s' "$cmd" | grep -oE 'apps/[a-z0-9-]+' | head -1 | cut -d/ -f2)
  if [ -n "$slug" ] && [ -f "pipeline/state/$slug.json" ]; then
    ok=$(python3 -c "import json;d=json.load(open('pipeline/state/$slug.json'));print(d.get('gates',{}).get('compliance',{}).get('result',''))")
    [ "$ok" = "PASS" ] || deny "compliance gate not PASS for $slug (run /compliance $slug first)"
  fi
fi
exit 0
