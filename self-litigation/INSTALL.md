# 설치 방법 (고객용 초안)

## 준비물
- Claude Code (Claude Pro/Max) 또는 OpenAI Codex (ChatGPT Pro) — 유료 상위 모델 사용을 전제로 합니다.
- GitHub 계정 (구매 후 비공개 배포 레포에 초대됩니다) 및 `gh auth login` 1회.
- 사건 파일을 둘 빈 폴더 (예: `내소송/`). 사건 자료는 이 폴더 밖으로 나가지 않습니다.

## Claude Code (권장, 한 줄)
빈 폴더에서 `claude` 실행 후:
```
/plugin install naholo --marketplace <owner>/<배포레포>
```
설치가 끝나면 `/naholo:start` 로 인터뷰를 시작합니다.

구버전이면 두 줄:
```
/plugin marketplace add <owner>/<배포레포>
/plugin install naholo@naholo-marketplace
```

## Codex (테스트 전, 형식만 준비)
```
codex plugin marketplace add <owner>/<배포레포> --ref main
codex plugin add naholo@naholo-marketplace
```
또는 `AGENTS.md` 와 `skills/` 폴더를 작업 폴더에 복사하면 같은 규칙으로 동작합니다(명령은 자연어: "인테이크 인터뷰 시작해줘").

## 판례 검증 키 (선택)
국가법령정보센터 Open API(https://open.law.go.kr) 에서 OC 값을 받아 설치 시 `law_oc` 항목에 입력하면 `/naholo:cite-check` 가 사건번호 존재를 자동 확인합니다. 없으면 수동 검색 링크를 안내합니다.

## 업데이트
```
/plugin update naholo
```
`~/.claude/settings.json` 의 `extraKnownMarketplaces` 에서 `autoUpdate: true` 로 두면 세션 시작 시 자동 갱신됩니다.
