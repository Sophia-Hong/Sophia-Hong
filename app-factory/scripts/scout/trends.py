#!/usr/bin/env python3
"""Collect App Store opportunity signals for US/CA.

Sources (all public, no auth):
  - Apple marketing RSS: top-free / top-paid / top-grossing per country
  - App Store search autocomplete (hints) for seed terms
  - iTunes Search API: competitor snapshot per keyword

Usage:
  python3 scripts/scout/trends.py --country us --country ca --out pipeline/ideas/raw-2026-09-21.json
  python3 scripts/scout/trends.py --seed "sleep sounds" --seed "habit tracker" --limit 25
Output: JSON with charts, hints, and per-keyword competitor stats + a naive opportunity score.
The trend-scout agent reads this and adds qualitative signals.
"""
import argparse, json, sys, time, datetime, urllib.parse, urllib.request

RSS = "https://rss.marketingtools.apple.com/api/v2/{cc}/apps/{feed}/{n}/apps.json"
SEARCH = "https://itunes.apple.com/search?term={term}&country={cc}&entity=software&limit={n}"
HINTS = "https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints?clientApplication=Software&term={term}"
UA = {"User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", "X-Apple-Store-Front": "143441-1,29"}

DEFAULT_SEEDS = [
    "habit tracker", "sleep sounds", "white noise", "focus timer", "pomodoro", "water reminder",
    "budget", "expense tracker", "invoice", "tip calculator", "unit converter", "countdown",
    "widget", "journal", "gratitude", "mood tracker", "workout log", "interval timer", "fasting",
    "baby tracker", "plant care", "recipe", "grocery list", "packing list", "qr code", "scanner",
    "photo vault", "sudoku", "solitaire", "word game", "puzzle", "idle game", "block puzzle",
]

def get(url, retries=2):
    for i in range(retries + 1):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=20) as r:
                return json.loads(r.read().decode("utf-8", "ignore"))
        except Exception as e:  # noqa
            if i == retries:
                print(f"warn: {url[:80]}... {e}", file=sys.stderr)
                return None
            time.sleep(1.5 * (i + 1))

def charts(cc, n):
    out = {}
    for feed in ("top-free", "top-paid", "top-grossing"):
        d = get(RSS.format(cc=cc, feed=feed, n=n))
        out[feed] = [
            {"rank": i + 1, "name": a.get("name"), "id": a.get("id"), "genres": [g.get("name") for g in a.get("genres", [])], "url": a.get("url")}
            for i, a in enumerate((d or {}).get("feed", {}).get("results", []))
        ]
    return out

def hints(term):
    d = get(HINTS.format(term=urllib.parse.quote(term)))
    if not d:
        return []
    return [h.get("term") for h in d.get("hints", []) if h.get("term")]

def competitors(term, cc, n):
    d = get(SEARCH.format(term=urllib.parse.quote(term), cc=cc, n=n))
    res = []
    for a in (d or {}).get("results", []):
        res.append({
            "name": a.get("trackName"), "id": a.get("trackId"), "rating": a.get("averageUserRating"),
            "ratings": a.get("userRatingCount", 0), "price": a.get("price"), "currency": a.get("currency"),
            "updated": (a.get("currentVersionReleaseDate") or "")[:10], "genre": a.get("primaryGenreName"),
            "seller": a.get("sellerName"), "min_os": a.get("minimumOsVersion"),
        })
    return res

def score(comps, hint_count, today):
    """Naive 0-100: demand from hints, weakness from top-3 stats, buildability unknown (agent fills)."""
    if not comps:
        return 0
    top = comps[:3]
    demand = min(40, 10 + hint_count * 5)
    weak = 0
    for c in top:
        if (c["rating"] or 0) < 4.3: weak += 4
        if (c["ratings"] or 0) < 5000: weak += 4
        try:
            d = datetime.date.fromisoformat(c["updated"])
            if (today - d).days > 180: weak += 2
        except Exception:
            pass
    weak = min(30, weak)
    paying = 10 if any((c["price"] or 0) > 0 for c in comps[:10]) else 5
    return demand + weak + paying

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--country", action="append", default=[])
    ap.add_argument("--seed", action="append", default=[])
    ap.add_argument("--limit", type=int, default=25)
    ap.add_argument("--chart-size", type=int, default=50)
    ap.add_argument("--out")
    a = ap.parse_args()
    ccs = a.country or ["us", "ca"]
    seeds = a.seed or DEFAULT_SEEDS
    today = datetime.date.today()
    result = {"date": today.isoformat(), "countries": ccs, "charts": {}, "keywords": {}}
    for cc in ccs:
        result["charts"][cc] = charts(cc, a.chart_size)
    for s in seeds:
        h = hints(s)
        comps = competitors(s, ccs[0], a.limit)
        result["keywords"][s] = {"hints": h, "competitors": comps, "score": score(comps, len(h), today)}
        time.sleep(0.4)
    ranked = sorted(result["keywords"].items(), key=lambda kv: -kv[1]["score"])
    result["ranked"] = [{"keyword": k, "score": v["score"], "top": [c["name"] for c in v["competitors"][:3]]} for k, v in ranked]
    js = json.dumps(result, indent=2)
    if a.out:
        open(a.out, "w").write(js)
        print(f"wrote {a.out}")
    for r in result["ranked"][:15]:
        print(f"{r['score']:3d}  {r['keyword']:<20} top: {', '.join(x or '' for x in r['top'])}")
    if not a.out:
        print(js[:2000])

if __name__ == "__main__":
    main()
