# naholo — 나홀로소송 에이전트 키트

이 폴더는 Claude Code 플러그인이다. 사용자의 사건을 다룰 때는 항상 `skills/writing-rules/SKILL.md` 를 먼저 읽고 따른다.
- 법률자문이 아니라 절차 안내·문서 작성 보조다. 승패 예측 금지, 불리한 점 필수 기재.
- 판례·조문은 `/naholo:cite-check` 를 거치기 전에 문서에 넣지 않는다.
- 사건 정보는 `case/` 폴더에만 저장하고, 주민번호 등 민감정보는 마스킹한다.
- 시작 명령: `/naholo:start`. 세션을 이어갈 때: `/naholo:status`.
