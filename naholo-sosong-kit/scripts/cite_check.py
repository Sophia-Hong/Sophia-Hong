#!/usr/bin/env python3
"""판례 사건번호 형식 검사 + 국가법령정보센터 Open API 존재 확인.
사용: python3 scripts/cite_check.py 2019다12345 2020가소1234
환경변수 NAHOLO_LAW_OC (law.go.kr Open API 신청 시 받은 OC 값)가 있으면 존재 확인까지 수행."""
import json, os, re, sys, urllib.parse, urllib.request

CASE_RE = re.compile(r"^(?P<year>19[5-9]\d|20\d\d)(?P<code>다|나|가단|가소|가합|가|도|두|누|카|마|므|므단|르|재다|허|후|초|구|고|노|모|재|헌마|헌바|헌가|헌사)(?P<num>\d{1,7})$")
API = "https://www.law.go.kr/DRF/lawSearch.do?OC={oc}&target=prec&type=JSON&query={q}"

def check_format(s: str):
    m = CASE_RE.match(s.replace(" ", ""))
    return bool(m)

def check_exists(s: str, oc: str):
    url = API.format(oc=oc, q=urllib.parse.quote(s))
    try:
        with urllib.request.urlopen(url, timeout=15) as r:
            data = json.loads(r.read().decode("utf-8"))
    except Exception as e:
        return None, f"API 오류: {e}"
    items = data.get("PrecSearch", {}).get("prec", [])
    if isinstance(items, dict):
        items = [items]
    for it in items:
        if it.get("사건번호", "").replace(" ", "") == s.replace(" ", ""):
            return True, f"{it.get('법원명','')} {it.get('선고일자','')} {it.get('사건명','')} | https://www.law.go.kr/DRF/lawService.do?OC={oc}&target=prec&ID={it.get('판례일련번호')}&type=HTML"
    return False, "law.go.kr 검색 결과에 해당 사건번호 없음"

def main(argv):
    if not argv:
        print(__doc__); return 2
    oc = os.environ.get("NAHOLO_LAW_OC")
    print("| 인용 | 형식 | 존재 | 판정 | 근거 |\n|---|---|---|---|---|")
    for s in argv:
        fmt = check_format(s)
        if not fmt:
            print(f"| {s} | ❌ | - | 기각 | 사건번호 형식 아님 |"); continue
        if not oc:
            print(f"| {s} | ✅ | ❓ | 확인 불가 | NAHOLO_LAW_OC 미설정 — https://glaw.scourt.go.kr 에서 직접 검색 |"); continue
        ok, note = check_exists(s, oc)
        verdict = "존재(내용 대조 필요)" if ok else ("기각" if ok is False else "확인 불가")
        mark = "✅" if ok else ("❌" if ok is False else "❓")
        print(f"| {s} | ✅ | {mark} | {verdict} | {note} |")
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
