# Pipeline state

`state/<slug>.json` is the single source of truth for one app:

```json
{
  "slug": "focus-timer", "name": "Focus Timer", "bundle_id": "com.x.focus-timer", "kind": "app",
  "stage": "created|spec|build|qa|compliance|aso|shipped",
  "gates": { "spec": {"result": "PASS|FAIL|PENDING", "note": ""}, "build": {}, "qa": {}, "compliance": {}, "aso": {} },
  "submission": { "version": "1.0.0", "build": 3, "date": "...", "status": "waiting-for-review" }
}
```

Agents write their own gate; the Stop hook stamps `updated`; the SessionStart hook prints a summary. Never edit `result` by hand to skip a gate.
