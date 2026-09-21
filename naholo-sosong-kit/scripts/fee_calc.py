#!/usr/bin/env python3
"""인지·송달료 추정 계산기. 기준: 민사소송 등 인지법 제2조, 송달료규칙/예규.
단가·회수는 개정될 수 있으므로 --postage 로 최신 송달료 1회분을 넘기고, 전자소송 화면 금액을 최종으로 한다."""
import argparse, math

DELIVERY_ROUNDS = {"sosong": 10, "civil": 15, "jigeup": 6, "jojeong": 5}  # 소액/민사1심/지급명령/조정 [확인]
DEFAULT_POSTAGE = 5200  # 송달료 1회분 단가(원) — 최신값 확인 필요

def stamp_fee(amount: int) -> int:
    if amount < 10_000_000:
        fee = amount * 0.005
    elif amount < 100_000_000:
        fee = amount * 0.0045 + 5_000
    elif amount < 1_000_000_000:
        fee = amount * 0.004 + 55_000
    else:
        fee = amount * 0.0035 + 555_000
    fee = max(fee, 1_000)
    return int(math.floor(fee / 100) * 100)

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--amount", type=int, required=True, help="청구 원금(원)")
    p.add_argument("--type", choices=DELIVERY_ROUNDS, default="sosong")
    p.add_argument("--parties", type=int, default=2, help="당사자 수(원고+피고)")
    p.add_argument("--efiling", action="store_true", help="전자소송 제출(인지 10%% 감액)")
    p.add_argument("--postage", type=int, default=DEFAULT_POSTAGE, help="송달료 1회분 단가")
    a = p.parse_args()

    base = stamp_fee(a.amount)
    if a.type == "jigeup":
        base = int(math.floor(base / 10 / 100) * 100)
    elif a.type == "jojeong":
        base = int(math.floor(base / 5 / 100) * 100)
    base = max(base, 1_000)
    stamp = int(math.floor(base * (0.9 if a.efiling else 1.0) / 100) * 100)
    delivery = a.parties * a.postage * DELIVERY_ROUNDS[a.type]
    small = a.amount <= 30_000_000

    print("| 항목 | 값 |\n|---|---|")
    print(f"| 청구 원금(소가) | {a.amount:,}원 |")
    print(f"| 소액사건 해당 | {'예(3,000만원 이하)' if small else '아니오(3,000만원 초과)'} |")
    print(f"| 절차 | {a.type} |")
    print(f"| 인지액(추정) | {stamp:,}원{' (전자소송 10% 감액)' if a.efiling else ''} |")
    print(f"| 송달료(추정) | {a.parties}명 × {a.postage:,}원 × {DELIVERY_ROUNDS[a.type]}회 = {delivery:,}원 |")
    print(f"| 합계(추정) | {stamp + delivery:,}원 |")
    print("\n※ 추정치입니다. 송달료 단가·회수는 개정될 수 있으니 전자소송 제출 화면 금액을 최종으로 하세요.")

if __name__ == "__main__":
    main()
