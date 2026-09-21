# App Factory

AI 에이전트 파이프라인으로 iOS 앱을 **리서치 → 기획 → 빌드 → 검수 → ASO/컴플라이언스 → 심사 제출**까지 자동화하는 시스템의 뼈대입니다.
타깃 시장은 **미국·캐나다**, 수익 모델은 **StoreKit 2 구독/인앱결제**입니다.

## 현실 체크 (먼저 읽기)

| 항목 | 상태 |
|---|---|
| 오케스트레이션·리서치·기획·코드 생성·메타데이터 작성 | 어디서든 실행 가능 (Linux/Mac) |
| Xcode 빌드, 시뮬레이터 테스트, 스크린샷, TestFlight/App Store 업로드 | **macOS + Xcode 필수** (로컬 Mac 또는 GitHub Actions `macos-*` 러너) |
| App Store Connect 제출 | `fastlane deliver` + App Store Connect API Key (`.p8`) |
| 심사 리스크 | Apple 가이드라인 **4.3 (스팸/중복 앱)**, **3.1.1 (IAP)**, **5.1.1 (개인정보)** 이 세 가지가 대량 출시 시 가장 자주 걸림. `compliance-officer` 에이전트가 제출 전에 강제 체크 |

한 달에 수십 개를 내려면 "앱마다 새로 만드는 것"이 아니라 **공용 모듈(FactoryKit) + 템플릿 + 앱별 얇은 로직** 구조여야 합니다. 이 레포는 그 구조로 되어 있습니다.

## 디렉터리

```
app-factory/
├── CLAUDE.md                  # 오케스트레이터(메인 세션)의 운영 규칙
├── .claude/
│   ├── settings.json          # 훅·권한
│   ├── agents/                # 서브에이전트 7종 (역할별 모델 지정)
│   ├── skills/                # /scout /new-app /build /ship /compliance /pipeline
│   └── hooks/                 # 시크릿 가드, Swift 검사, 파이프라인 상태 기록
├── scripts/
│   ├── scout/trends.py        # App Store 차트·검색 자동완성·iTunes 검색 수집
│   ├── factory/new_app.sh     # 템플릿에서 새 앱 생성 (bundle id, 이름, 카테고리)
│   └── release/preflight.sh   # 제출 전 자동 점검 (privacy manifest, IAP, 메타데이터, 스크린샷)
├── templates/
│   ├── ios-app/               # SwiftUI 앱 템플릿 (XcodeGen project.yml + fastlane)
│   ├── ios-game/              # SpriteKit 게임 템플릿
│   └── legal/                 # 개인정보처리방침·이용약관 (GitHub Pages 호스팅용)
├── packages/FactoryKit/       # 공용 Swift 패키지: 페이월(StoreKit 2), 온보딩, 리뷰 요청, 분석 훅
├── pipeline/
│   ├── ideas/backlog.md       # 아이디어 백로그 (scout 결과가 여기 쌓임)
│   └── state/<app>.json       # 앱별 파이프라인 상태 (훅이 자동 갱신)
└── apps/<app-slug>/           # 생성된 앱들 (new_app.sh가 만듦)
```

## 에이전트 구성

| 역할 | 파일 | 모델 | 하는 일 |
|---|---|---|---|
| 오케스트레이터 | 메인 세션 (CLAUDE.md) | Fable | 파이프라인 지휘, 게이트 판단, 서브에이전트 호출 |
| trend-scout | agents/trend-scout.md | sonnet (Kimi 등 외부 리서치 모델은 스크립트/MCP로 교체 가능) | 차트·검색어·바이럴 모니터링, 기회 점수화 |
| product-strategist | agents/product-strategist.md | inherit | 잘 팔리는 앱 분석 → 1페이지 스펙, 수익 모델 결정 |
| ios-builder | agents/ios-builder.md | opus | 템플릿 + FactoryKit 위에 앱 구현 (Codex로 교체 가능한 지점) |
| qa-reviewer | agents/qa-reviewer.md | opus | 빌드/테스트/코드리뷰, 크래시·UX 결함 |
| compliance-officer | agents/compliance-officer.md | inherit | Apple 가이드라인 4.3/3.1.1/5.1.1, privacy manifest, 약관 |
| aso-writer | agents/aso-writer.md | sonnet | 이름·서브타이틀·키워드·설명·스크린샷 카피 (US/CA) |
| release-manager | agents/release-manager.md | inherit | fastlane으로 빌드·업로드·메타데이터·심사 제출 |

## 처음 시작하기 (Mac에서)

```bash
# 1. 도구
brew install xcodegen fastlane swiftlint
xcode-select --install

# 2. App Store Connect API 키 발급 후 (Users and Access → Integrations → App Store Connect API)
cp .env.example .env   # KEY_ID, ISSUER_ID, .p8 경로 입력. .env는 절대 커밋하지 않음 (훅이 막음)

# 3. Claude Code 실행
cd app-factory && claude

# 4. 파이프라인
/scout                     # 오늘의 기회 리스트 → pipeline/ideas/backlog.md
/new-app "Focus Timer" --category productivity --monetization subscription
/build focus-timer         # 구현 + 빌드 + 테스트 (ios-builder → qa-reviewer)
/compliance focus-timer    # 게이트: 통과 못 하면 /ship 불가
/ship focus-timer          # ASO 메타데이터 + fastlane deliver → 심사 제출
/pipeline focus-timer      # 위 전부를 한 번에 (게이트마다 오케스트레이터가 판단)
```

## 수익화 기본값

- **StoreKit 2** 직접 사용 (FactoryKit `Paywall`), 외부 SDK 의존 없음. 앱 수가 늘어 통합 대시보드가 필요해지면 RevenueCat으로 교체 가능하도록 `PurchaseProvider` 프로토콜 뒤에 숨겨둠.
- 기본 상품: 주간 구독(3일 무료) + 연간 구독 + 평생 이용권. 미국 시장 기준 가격 티어는 스펙 단계에서 product-strategist가 결정.
- 게임: 광고 제거 + 코인 팩 (소모성) 기본.

## 다음 단계 (이 레포에서 아직 안 한 것)

- [ ] Mac에서 `templates/ios-app`을 실제로 `xcodegen generate && xcodebuild` 해서 컴파일 확인
- [ ] App Store Connect API 키 발급 및 `fastlane deliver` 1회 수동 성공 (그 다음부터 에이전트가 함)
- [ ] 개인정보처리방침 호스팅 (GitHub Pages: `templates/legal` 참고)
- [ ] Apple Developer Program 등록 ($99/년) 및 Paid Apps Agreement 서명 (IAP 필수 조건)
- [ ] Kimi/Codex를 붙이려면: `scripts/scout/trends.py` 결과를 외부 모델에 넘기는 MCP 또는 CLI 래퍼 추가
