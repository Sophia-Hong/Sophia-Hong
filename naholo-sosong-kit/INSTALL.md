# 설치 방법 (고객용 초안)

## 준비물
- Claude Code (Claude Pro/Max 계정) 또는 OpenAI Codex (ChatGPT Pro 계정)
- 사건 파일을 둘 빈 폴더 (예: `내소송/`)

## Claude Code — 방법 A (플러그인 마켓플레이스, 권장)
```
claude
/plugin marketplace add <배포 레포 주소>
/plugin install naholo@naholo-marketplace
/naholo:start
```
비공개 레포인 경우 구매 시 안내한 GitHub 접근 방법(초대 또는 토큰)을 먼저 설정합니다.

## Claude Code — 방법 B (첫 프롬프트 한 줄)
빈 폴더에서 `claude` 를 실행하고 아래를 붙여넣습니다.
```
<배포 레포 주소> 를 clone 해서 이 폴더에 naholo 플러그인으로 설치하고, 설치가 끝나면 /naholo:start 를 실행해줘.
```

## Codex
`AGENTS.md` 와 `skills/` 폴더를 작업 폴더에 복사하면 동일한 규칙으로 동작합니다(명령어는 자연어로: "인테이크 인터뷰 시작해줘").

## 업데이트
```
/plugin update naholo
```
