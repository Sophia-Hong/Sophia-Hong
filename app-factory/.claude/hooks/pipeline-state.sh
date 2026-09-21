#!/usr/bin/env bash
# Stop hook: refresh `updated` timestamps for any state file touched in this session (cheap audit trail).
cd "$(dirname "$0")/../.." || exit 0
changed=$(git status --porcelain pipeline/state 2>/dev/null | awk '{print $2}')
[ -z "$changed" ] && exit 0
for f in $changed; do
  [ -f "$f" ] || continue
  python3 - "$f" <<'PY'
import json,sys,datetime
p=sys.argv[1]; d=json.load(open(p))
d['updated']=datetime.datetime.utcnow().isoformat(timespec='seconds')+'Z'
json.dump(d,open(p,'w'),indent=2)
PY
done
exit 0
