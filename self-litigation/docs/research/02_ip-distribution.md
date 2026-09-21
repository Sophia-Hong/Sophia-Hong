# 나홀로소송 AI 에이전트 키트 — 배포·프롬프트 보호·업데이트 전략 조사 보고서

작성일: 2026-09-21
대상: Claude Code / OpenAI Codex(CLI·앱)에 설치되는 유료 프롬프트·스킬·에이전트 묶음
범례: **[확인]** 공식 문서로 확인 · **[2차]** 공식 문서 접근 불가로 2차 자료(검색 요약·커뮤니티)로만 확인 · **미확인** 확인 실패

> 조사 환경 제약: `developers.openai.com`, `help.openai.com`, `support.claude.com`, `gumroad.com`, `docs.lemonsqueezy.com`, 국내 법률 사이트 다수가 프록시에서 차단되어 직접 열람하지 못했습니다. 해당 항목은 검색 엔진 요약과 GitHub 원문(raw)으로 보완했고, 아래에 **[2차]** 또는 **미확인**으로 표시했습니다. Claude Code 문서(code.claude.com)는 원문을 직접 확인했습니다.

---

## 0. 한 줄 결론

- **프롬프트 원문은 고객 PC에 내려가는 순간 보호되지 않는다**(파일, 세션 로그, 컨텍스트 모두 평문). 기술적 "은닉"은 포기하고, **① 서버 측 보관(원격 MCP) + 라이선스 키 + ② 법적 장치(약관·영업비밀 관리·고객별 워터마크)** 조합으로 가야 합니다.
- **1주일 MVP**: private GitHub 저장소 1개를 Claude Code 플러그인 마켓플레이스(+ 같은 저장소를 Codex 마켓플레이스로 겸용)로 만들고, 결제는 Gumroad(한국 판매자 KRW 정산 **[2차]**) 또는 국내 PG로 받되 접근권은 GitHub 협업자 초대(또는 read-only 토큰)로 부여. 업데이트는 `git push` 한 번으로 고객 측에 자동/반자동 반영.
- **2단계**: 프롬프트 본문을 원격 MCP 서버로 이전(로컬에는 "껍데기" 스킬만). 라이선스 키로 인증, 사용량 계측, 즉시 업데이트, 고객 데이터는 서버로 보내지 않는 구조.

---

## 1. Claude Code 배포 메커니즘 (공식 문서 기준)

### 1.1 플러그인 & 플러그인 마켓플레이스 **[확인]**

출처: https://code.claude.com/docs/en/plugin-marketplaces , https://code.claude.com/docs/en/discover-plugins , https://code.claude.com/docs/en/plugins , https://code.claude.com/docs/en/plugins-reference

- **구조**: 마켓플레이스 = `.claude-plugin/marketplace.json`이 있는 Git 저장소(또는 URL·로컬). 플러그인 = `.claude-plugin/plugin.json` + `skills/`, `agents/`, `commands/`, `hooks/hooks.json`, `.mcp.json`, `settings.json` 등. 플러그인 하나가 스킬·서브에이전트·훅·MCP 서버를 **한 번에** 배포할 수 있음.
- **설치 명령**
  - `/plugin marketplace add owner/repo` (GitHub 단축형; 기본은 SSH clone, `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1`로 HTTPS 전환)
  - `/plugin install <plugin>@<marketplace>` → 스코프(user/project/local) 선택
  - **한 줄 설치** (v2.1.275+): `/plugin install <plugin> --marketplace owner/repo` — 마켓플레이스 추가 확인 후 바로 설치
  - 셸: `claude plugin marketplace add owner/repo && claude plugin install <plugin>@<marketplace>` (비대화식, user 스코프 기본)
- **Private GitHub 저장소 지원**: 지원됨. "Claude Code uses your existing git credential helpers, so HTTPS access via `gh auth login`, macOS Keychain, or `git-credential-store` works". 즉 고객이 `gh auth login`을 해두거나 SSH 키가 있으면 됨. 환경변수 `GITHUB_TOKEN`만 설정해서는 안 되고, credential helper(gh)가 읽어야 함.
  - 토큰 방식: `git config --global url."https://x-access-token:TOKEN@github.com/owner/repo".insteadOf "https://github.com/owner/repo"` (문서 예시; 평문 저장이므로 read-only 토큰 권장).
- **자동 업데이트**: 세션 시작 후 최대 10분 랜덤 지연 뒤 백그라운드로 마켓플레이스 새로고침 + 설치 플러그인 갱신 → `/reload-plugins` 알림 또는 다음 실행 시 반영. **단, 서드파티 마켓플레이스는 auto-update 기본 OFF**(사용자가 `/plugin` → Marketplaces에서 켜거나, settings의 `extraKnownMarketplaces[...].autoUpdate: true`).
  - Private HTTPS 저장소는 **백그라운드 체크 시 credential helper가 비활성화**되어 실패할 수 있음(SSH는 영향 없음). 완화책: `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` 또는 `gh auth setup-git`. → **결론: private 저장소 + 자동 업데이트는 SSH 키 고객이 아니면 불안정. 수동 `/plugin marketplace update` + `/plugin update`를 안내하거나 SessionStart 훅으로 보완.** GitHub 이슈에도 autoUpdate 미동작 보고 다수(https://github.com/anthropics/claude-code/issues/61854 , https://github.com/anthropics/claude-code/issues/95175).
- **버전 관리**: `plugin.json`의 `version`을 올려야 갱신됨. `version`을 **생략하면 커밋 SHA가 버전**이 되어 push마다 갱신됨("Commit-SHA version — Internal or team plugins under active development"). 판매용이면 명시 버전+CHANGELOG 권장.
- **다른 소스 타입**: `archive`(HTTPS zip, `sha256` 핀, `headers`/`headersHelper`로 **인증 헤더 부착 가능** → 자체 서버에서 라이선스 키 검증 후 zip 내려주는 구조 가능, v2.1.238+), `npm`(private registry 가능), `command`, `url`.
- **캐시 위치**: `~/.claude/plugins/cache` — **고객이 그대로 열어볼 수 있음**.
- **비개발자 설치 난이도**: 중. 터미널에서 `claude` 실행 후 슬래시 명령 2개. Private이면 `gh auth login` 선행 필요(브라우저 로그인 1회). Claude Desktop 앱에도 플러그인 브라우저가 있으나 "marketplace-based installations만 지원" **[2차]** (https://code.claude.com/docs/en/desktop-quickstart).

### 1.2 settings.json의 `extraKnownMarketplaces` / `enabledPlugins` **[확인]**

출처: https://code.claude.com/docs/en/settings-reference (extraKnownMarketplaces 절), https://code.claude.com/docs/en/discover-plugins#configure-team-marketplaces

```json
{
  "extraKnownMarketplaces": {
    "solo-lawsuit": { "source": { "source": "github", "repo": "yourorg/solo-lawsuit-kit" }, "autoUpdate": true }
  },
  "enabledPlugins": { "solo-lawsuit@solo-lawsuit": true }
}
```
- 저장소의 `.claude/settings.json`에 넣으면 폴더를 **trust**한 사용자에게 마켓플레이스가 자동 등록됨. 단 v2.1.195+에서는 외부 소스 플러그인은 자동 설치되지 않고 `claude plugin install` 명령을 안내함 → "clone하면 끝"은 아님.
- 소스 타입: `github`, `git`, `url`(+`headers`/`headersHelper`), `file`, `directory`, `settings`(인라인).
- **활용**: "스타터 저장소"를 고객에게 주고 그 안의 settings.json으로 마켓플레이스를 자동 등록 + autoUpdate ON. 고객은 폴더 trust 후 install 1회.

### 1.3 Skills (`.claude/skills/*/SKILL.md`) **[확인]**

출처: https://code.claude.com/docs/en/skills
- 위치: `~/.claude/skills/`(개인), `.claude/skills/`(프로젝트), 플러그인 `skills/`, `--add-dir` 디렉터리의 `.claude/skills/`.
- 프론트매터: `description`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `context: fork`, `agent`, `arguments`, `model`, `effort` 등.
- **동적 컨텍스트 주입 `!`command``**: "The command runs before Claude sees the skill, so the output is inlined into the prompt". → **SKILL.md에 프롬프트 본문을 두지 않고 `!`curl -s https://api.example.com/prompt/xxx -H "Authorization: Bearer $KEY"``로 실행 시점에 서버에서 받아오는 "스텁 스킬"이 가능** (원격 MCP 없이도 서버 측 보관 구현 가능한 가장 가벼운 방법). 단 claude.ai 동기화 스킬에서는 `!` 명령이 실행되지 않음.
- 파일 변경은 세션 중 자동 감지(라이브 리로드).
- 난이도: 파일 복사만 하면 되므로 최하. 하지만 업데이트 배포 수단이 없음(다시 복사).

### 1.4 Subagents (`.claude/agents/*.md`) **[확인]**

출처: https://code.claude.com/docs/en/sub-agents
- 위치/우선순위: managed → `--agents` → `.claude/agents/` → `~/.claude/agents/` → 플러그인 `agents/`. 파일 감시로 수 초 내 반영.
- 플러그인 에이전트는 `hooks`, `mcpServers`, `permissionMode` 필드 미지원. 프론트매터 `skills:`로 스킬 사전 로드 가능, `mcpServers:`(비플러그인)로 특정 MCP 서버 부여 가능.

### 1.5 Slash commands (`.claude/commands`) **[확인]**

출처: https://code.claude.com/docs/en/slash-commands — "Custom commands have been merged into skills". 신규는 skills 사용 권장.

### 1.6 Hooks **[확인/2차]**

출처: https://code.claude.com/docs/en/hooks
- 플러그인의 `hooks/hooks.json`으로 배포. `SessionStart` 훅이 stdout/`additionalContext`로 컨텍스트를 주입 가능 → 세션 시작 시 원격에서 최신 안내문·라이선스 상태를 받아 주입하는 용도로 활용 가능 **[2차]**. 훅은 임의 코드 실행이므로 설치 시 신뢰 경고가 뜸.

### 1.7 MCP 서버 (remote MCP, prompts) **[확인]**

출처: https://code.claude.com/docs/en/mcp
- 원격 추가: `claude mcp add --transport http <name> <url> --header "Authorization: Bearer <token>"` (user/project/local 스코프). `.mcp.json`에는 `${LICENSE_KEY}` 같은 환경변수 확장 지원. OAuth(RFC 9728/8414 자동 검색, `claude mcp login`), `headersHelper`(만료 토큰 갱신 스크립트) 지원.
- **MCP prompts → 슬래시 명령**: "Claude Code lists each MCP prompt as `/servername:promptname (MCP)`. Typing `/mcp__servername__promptname` also runs it." 인자 전달 가능, "Prompt results are injected directly into the conversation". `list_changed` 알림으로 서버가 프롬프트 목록을 갱신하면 재접속 없이 반영.
- MCP resources도 `@server:uri`로 첨부 가능.
- 플러그인이 `.mcp.json`을 동봉하면 설치와 동시에 MCP 서버가 등록됨 → **"플러그인 설치 1회 = MCP 접속 설정 완료"**.
- 난이도: `claude mcp add` 한 줄. 토큰 입력만 하면 됨.

### 1.8 `claude --add-dir` **[확인]**

출처: https://code.claude.com/docs/en/skills#loading-from-additional-directories — 해당 디렉터리의 `.claude/skills|commands|agents`가 그 세션에만 로드됨. 배포 수단으로는 부적합(매번 플래그, 업데이트는 git pull 수동).

### 1.9 요약 표 (비개발자 기준)

| 방식 | 설치 난이도 | 업데이트 반영 | 프롬프트 노출 | 비고 |
|---|---|---|---|---|
| 파일 복사(skills/agents) | 최하 | 없음(재복사) | 전부 | 배포 관리 불가 |
| `--add-dir` + git clone | 하 | `git pull` 수동 | 전부 | 세션마다 플래그 |
| **플러그인 마켓플레이스(private GitHub)** | 중(`gh auth login` + 명령 2개) | 자동(옵션)·수동 `/plugin update` | 전부(캐시 평문) | 스킬·에이전트·훅·MCP 일괄 배포 |
| 플러그인 `archive`(자체 서버 zip + 인증 헤더) | 중 | version/sha256 갱신 시 | 전부 | GitHub 계정 불필요, 라이선스 서버 연동 가능 |
| **원격 MCP(prompts/tools)** | 하(`claude mcp add` 1줄 또는 플러그인 동봉) | **즉시**(서버 배포 즉시) | 컨텍스트에만(파일 없음) | 서버 운영 필요 |
| SKILL.md `!curl` 스텁 | 하 | 즉시 | 컨텍스트에만 | curl 의존, 오류 처리 필요 |

---

## 2. OpenAI Codex 쪽

> developers.openai.com / help.openai.com 접근 차단. GitHub 원문(openai/plugins, openai/skills, 커뮤니티 플러그인 README)과 검색 요약으로 확인.

### 2.1 AGENTS.md **[2차]**
- `~/.codex/AGENTS.md`(전역), 저장소 루트~하위 디렉터리 AGENTS.md(가까운 것 우선), `AGENTS.override.md`. 합산 32KiB 기본 한도(`project_doc_max_bytes`). 출처: https://developers.openai.com/codex/guides/agents-md (차단), 2차: https://www.verdent.ai/guides/codex-agents-md-explained , https://shipyard.build/blog/codex-cli-cheat-sheet/
- 배포 수단으로는 "파일 복사"와 동일 — 업데이트 자동화 없음.

### 2.2 Codex Skills **[확인(GitHub 원문)]**
- `$CODEX_HOME/skills/<name>/SKILL.md`(기본 `~/.codex/skills`). 저장소 `.agents/skills` 등도 인식 **[2차]**.
- 설치: Codex 내에서 `$skill-installer <name>` 또는 `$skill-installer install https://github.com/<owner>/<repo>/tree/<ref>/<path>`. skill-installer SKILL.md 원문: "Install from another repo when the user provides a GitHub repo/path (**including private repos**)… Private GitHub repos can be accessed via existing git credentials or optional `GITHUB_TOKEN`/`GH_TOKEN`". 설치 후 Codex 재시작 필요. 출처: https://github.com/openai/skills/blob/main/skills/.system/skill-installer/SKILL.md , https://github.com/openai/skills (deprecated 표시, 플러그인으로 이전 권장)
- 업데이트: 자동 없음("Aborts if the destination skill directory already exists" — 재설치 시 삭제 후 설치).

### 2.3 Codex Plugins / Marketplace **[2차 + GitHub 원문]**
- 2026-03 출시. 플러그인 = `.codex-plugin/plugin.json` + `skills/`, `.mcp.json`, `.app.json`, `hooks.json` 등. 마켓플레이스 = `.agents/plugins/marketplace.json`. 원문 예: https://github.com/openai/plugins (README, `.agents/plugins/marketplace.json`, `plugins/notion/.codex-plugin/plugin.json` 확인).
- CLI: `codex plugin marketplace add owner/repo --ref main` → `codex plugin add <plugin>@<marketplace>`; `codex plugin marketplace list|upgrade|remove`. 앱: Plugins → Add marketplace(소스·ref 입력). 출처(커뮤니티 README, 검증된 명령): https://github.com/the-incubator/incubator-build-plugin
- **Claude Code 형식과 호환**: 같은 README에 "Codex reads the repository's `.claude-plugin/marketplace.json` and the plugin's `.codex-plugin/plugin.json`; both formats are supported". → **한 저장소에 `.claude-plugin/`과 `.codex-plugin/`(및 `.agents/plugins/marketplace.json`)을 함께 두면 양쪽에 동시 배포 가능** (실제 동작은 직접 테스트 필요 — 미확인).
- Private 저장소: "If Git reports a private-repository/authentication error, authenticate… `gh auth login` followed by `gh auth setup-git`" **[2차]**.
- 업데이트: `codex plugin marketplace upgrade`가 `git ls-remote`로 SHA 변경 시 재clone; 시작 시 자동 upgrade PR 존재(https://github.com/openai/codex/pull/17425) **[2차]**. "Marketplace updates don't affect installed plugins until the user re-installs" **[2차, 시점 불명]** → **Codex는 재설치 안내가 필요할 수 있음. 미확인.**
- 자가 등록 공식 디렉터리는 2026-05 기준 "coming soon" **[2차]**.

### 2.4 Codex MCP 설정 **[2차]**
- `~/.codex/config.toml`:
  ```toml
  [mcp_servers.solo_lawsuit]
  url = "https://mcp.example.com/mcp"
  bearer_token_env_var = "SOLO_LAWSUIT_KEY"
  ```
  또는 `codex mcp add solo --url https://mcp.example.com/mcp --bearer-token-env-var SOLO_LAWSUIT_KEY`. 토큰을 config에 직접 쓰지 못하고 환경변수명만 지정. 출처(차단): https://developers.openai.com/codex/mcp ; 2차: https://www.variant.art/blog/codex-mcp-config-reference , https://designrevision.com/blog/add-mcp-server-to-codex
- **MCP prompts를 슬래시 명령으로 노출하는지: 미확인**(검색 결과에 `/mcp`는 서버·툴 목록만 언급). → Codex에서는 **MCP tool**(예: `get_prompt(name)`)로 제공하는 것이 안전. Claude Code에서는 prompts + tools 둘 다.

### 2.5 프롬프트 파일 배포 방식 요약(Codex)
1. 플러그인(마켓플레이스) — 권장, Claude와 저장소 공유.
2. `$skill-installer <private GitHub URL>` — 스킬만, 업데이트 수동.
3. AGENTS.md — 비권장(전역 컨텍스트 소모, 배포 불가).

---

## 3. 프롬프트 보호의 현실

### 3.0 전제: 로컬에 내려간 것은 전부 읽힌다 **[확인]**
- 플러그인 캐시 `~/.claude/plugins/cache`, 스킬 파일, `~/.codex/skills` 모두 평문.
- **세션 로그도 평문**: Claude Code는 대화 전체(툴 결과 포함)를 `~/.claude/projects/<proj>/<session>.jsonl`에 저장, 기본 30일 보관(`cleanupPeriodDays`). 출처: https://code.claude.com/docs/en/sessions **[2차 요약]**. → **원격 MCP로 프롬프트를 내려줘도 대화 컨텍스트에 들어간 텍스트는 로그에 남는다.** "절대 노출 안 됨"은 불가능. 목표를 "대량·손쉬운 복제 방지 + 계약·법적 억지 + 업데이트/해지 통제"로 재정의해야 함.

### 3.1 (a) 원격 MCP 서버 아키텍처 — 권장 2단계

```
고객 PC (Claude Code / Codex)                    판매자 서버 (예: Cloudflare Workers / Vercel / Fly)
┌──────────────────────────────┐   HTTPS+Bearer  ┌──────────────────────────────────────┐
│ 플러그인(껍데기)             │ ──────────────▶ │ MCP 서버 (Streamable HTTP)            │
│  - .mcp.json → 서버 URL       │                 │  - prompts/list, prompts/get (Claude)  │
│  - SKILL.md: "소장 작성은     │ ◀────────────── │  - tools: get_prompt, list_templates   │
│    /solo:complaint 호출"      │  프롬프트 텍스트 │  - 라이선스 키 검증(DB/Gumroad verify) │
│  - 로컬에 사건 데이터 유지    │                 │  - 사용량·버전·고객ID 워터마크 삽입    │
└──────────────────────────────┘                 └──────────────────────────────────────┘
```
- **고객 데이터는 서버로 안 보냄**: 툴 인자는 "어떤 템플릿"만 받고, 사건 사실관계는 로컬 컨텍스트에서 모델이 채움. 프롬프트 텍스트만 하향. (변호사법·개인정보 관점에서도 유리.)
- **인증**: 라이선스 키를 Bearer 토큰으로. Claude Code: `--header "Authorization: Bearer KEY"` 또는 `.mcp.json`의 `${SOLO_KEY}`; Codex: `bearer_token_env_var`. OAuth도 가능하나 MVP엔 과함.
- **즉시 업데이트**: 서버 배포 즉시 반영. Claude Code는 `list_changed`로 프롬프트 목록 갱신.
- **계측/해지**: 키별 호출 수, 마지막 사용일, 기기 수 제한(Lemon Squeezy/Polar activation limit 유사). 환불·불법 재배포 시 키 정지.
- **워터마크**: `prompts/get` 응답에 고객ID 해시를 자연어 속에 삽입(예: 예시 사건번호·의뢰인 가명·문단 순서 변형). 유출본 출처 추적용.
- **장점**: 파일 유출 위험 최소, 업데이트 즉시, 해지 가능, 사용 통계. **단점**: 서버 운영·가용성 책임(서버 다운 = 제품 다운), 컨텍스트/로그 노출은 여전, 오프라인 불가, 구현 난이도 중(MCP SDK로 1~3일).
- **설치 UX**: 플러그인 동봉 `.mcp.json` 방식이면 "`/plugin install solo-lawsuit --marketplace yourorg/kit` → 환경변수 `SOLO_KEY` 설정" 2단계. MCP만 쓰면 `claude mcp add --transport http solo https://… --header "Authorization: Bearer KEY"` 한 줄.

### 3.2 (b) Private GitHub repo + 토큰/GitHub App 배포 — MVP 1단계
- **협업자 초대 방식**: 결제 완료 → 고객 GitHub 아이디를 read 권한 협업자로 추가(무료 플랜도 private repo 협업자 무제한). 고객은 `gh auth login` 후 `/plugin marketplace add`. 해지 시 협업자 제거. 자동화는 GitHub REST API(`PUT /repos/{o}/{r}/collaborators/{user}`)로 결제 웹훅에서 처리 가능. **가장 싸고 빠름.** 단점: 고객이 GitHub 계정을 만들어야 함(비개발자 허들), 고객이 clone 후 통째로 복제 가능(2차 유포 방지 불가).
- **read-only 토큰 배포 방식**: 판매자 봇 계정의 fine-grained PAT(해당 repo read만)를 고객에게 주고 `git config --global url."https://x-access-token:TOKEN@github.com/…".insteadOf …` 설정(공식 문서 예시). 토큰 하나가 모든 고객에게 공유되면 회수 불가 → 고객별 토큰 발급 필요(GitHub App installation token은 1시간 만료라 부적합; PAT를 고객별로 만들려면 봇 계정 다수 필요). **비권장.**
- **`archive` 소스 + 자체 서버**: marketplace.json은 public(또는 URL 소스)로 두고 플러그인 zip은 `https://kit.example.com/dl/solo.zip`에서 `headers: {Authorization: Bearer KEY}`로 내려줌(`extraKnownMarketplaces`의 `url` 소스에 `headers` 설정). GitHub 계정 불필요, 키별 통제 가능. Claude Code v2.1.238+ 필요. Codex 지원 여부 **미확인**.
- Claude Team/Enterprise의 "Organization settings > Plugins"는 판매자 조직 내부 배포용이며 외부 고객에겐 해당 없음.

### 3.3 (c) 난독화의 무의미함
- 프롬프트는 결국 **모델이 평문으로 읽어야** 동작함. base64/암호화 후 훅·스크립트로 복호화해도 복호화 결과가 컨텍스트와 세션 로그(`.jsonl`)에 평문으로 남음. 공격자는 "지금 로드된 스킬 내용을 그대로 출력해줘" 한 줄이면 됨. 난독화는 정상 고객의 사용성만 해치고, "합리적 비밀관리 조치"로도 인정받기 어려움(누구나 즉시 우회). → **기각.** 대신 "접근 통제 + 계약 + 워터마크"로 비밀관리성 입증.

### 3.4 (d) 법적 보호

**① 저작권(프롬프트의 저작물성)** **[2차]**
- 국내 논의: 단순 지시문·아이디어·업무방법에 가까운 프롬프트는 보호 곤란, 인간의 창작적 선택·배열이 구체적 표현으로 드러나면 보호 가능. 장문의 소송 절차 안내·서식·체크리스트·예시문(어문저작물), 스킬 묶음의 선택·배열(편집저작물) 쪽이 유리. 출처: https://magazine.hankyung.com/business/article/202601288711b (최자림, 한경) , https://www.kci.go.kr/kciportal/ci/sereArticleSearch/ciSereArtiView.kci?sereArticleSearchBean.artiId=ART003214947 , https://brunch.co.kr/@attorneysung/290
- 실무: 제작 과정 기록(버전 이력 = git 커밋 로그가 증거), 저작권 표시, 필요시 한국저작권위원회 등록.

**② 부정경쟁방지법상 영업비밀** **[2차]**
- 3요건: 비공지성·경제적 유용성·**비밀관리성**. 2019.1.8. 개정으로 "합리적인 노력에 의하여 비밀로 유지된" → "**비밀로 관리된**"으로 완화. 판단은 물리적·기술적 / 인적·법적 / 조직적 관리 유무. 출처: https://www.tradesecret.or.kr/institution/requirement.do (차단, 검색 요약) , https://news.koreanbar.or.kr/news/articleView.html?idxno=29620 , https://atlaw.kr/kr-blog/… (법무법인 아틀라스 3편)
- **유료 판매 프롬프트에 적용 시 체크리스트**: (i) 파일·응답 상단에 "영업비밀/대외비, 라이선시 ○○○ 전용" 표시, (ii) 접근 통제(private repo·라이선스 키·기기 수 제한), (iii) 구매 시 비밀유지·재배포 금지 동의(클릭랩), (iv) 접근 로그 보관(MCP 서버 로그), (v) 해지 시 접근 차단. 이 다섯 가지가 갖춰지면 "비밀로 관리된" 상태 주장이 가능. 반대로 public repo·난독화만 하고 판매하면 비공지성·비밀관리성 모두 흔들림.
- 한계: 고객이 다수(일반 소비자)에게 판매되는 정보는 "비공지성" 다툼 여지 있음 → NDA 조항·접근 통제로 보강.

**③ 이용약관/EULA**
- 필수 조항: 1인 1라이선스(기기 N대), 재배포·공개·역공학 금지, 프롬프트 원문 공개 금지, 파생물 상업 이용 금지, 위반 시 라이선스 해지·손해배상 예정, **법률자문 아님(정보 제공)** 고지, 결과물 책임 제한. 변호사법 제109조(비변호사 법률사무) 관련 표현 주의: "변호사가 만든 자기소송 도구"로 포지셔닝하고 개별 사건 자문은 별도.
- 클릭랩(구매 페이지 체크박스)+플러그인 README 재게시로 동의 증거 확보.

**④ 워터마크·고객별 식별자**
- 정적 배포(1단계): 결제 웹훅에서 고객별 zip을 생성해 SKILL.md 주석·예시 이름·공백 패턴에 식별자 삽입(private repo 협업자 방식에서는 불가 → archive 방식이나 MCP에서 가능).
- 동적 배포(2단계): MCP 응답마다 삽입. 유출본 발견 시 키 정지 + 약관상 위약금.

### 3.5 방식별 비교

| | 구현 난이도 | 고객 설치 UX | 보호 수준 | 즉시 업데이트 | 해지 가능 |
|---|---|---|---|---|---|
| private repo 협업자 초대 | 최하(반나절) | GitHub 계정+`gh auth login`+명령 2개 | 낮음(clone 후 자유) | 중(auto-update 불안정) | 협업자 제거 |
| archive zip + 인증 헤더 | 하~중(1~2일) | 명령 2개+키 | 중(키별 워터마크) | version bump 시 | 키 정지 |
| 원격 MCP | 중(2~5일) | 명령 1~2개+키 | 중상(파일 無, 로그 有) | 즉시 | 키 정지 |
| 난독화 | 하 | 나쁨 | 없음 | — | — |

---

## 4. "GitHub 링크 + 첫 프롬프트 한 줄로 AI가 알아서 설치" 시나리오

### Claude Code **[확인 + 추론]**
- `claude` 실행 후 "https://github.com/yourorg/kit 를 플러그인으로 설치해줘"라고 하면 모델이 Bash로 `claude plugin marketplace add …` / `claude plugin install …`를 실행할 수 있음. 셸 명령이므로 **권한 프롬프트**("Yes / Yes, and don't ask again / No")가 뜨고 고객이 Enter로 승인. 출처: https://code.claude.com/docs/en/permissions ("Bash commands — Approval required: Yes, except a built-in set of read-only commands").
- 더 확실한 방법: 고객에게 **슬래시 명령 자체**를 첫 입력으로 주기 — `/plugin install solo-lawsuit --marketplace yourorg/kit` (v2.1.275+). 모델 판단 없이 결정적으로 동작하고 마켓플레이스 추가 확인 → 스코프 선택만 하면 끝. 설치 직후 `/reload-plugins` 자동 실행.
- Private repo이면 사전 `gh auth login` 필요(모델이 대신 브라우저 로그인을 해줄 수는 없음). "GitHub 계정 만들기 → `gh auth login` → 첫 명령" 3단계 안내문 필요.
- 첫 프롬프트에 "clone해서 `~/.claude/skills`에 복사해줘"라고 하면 동작은 하지만 업데이트 경로가 없어 비권장.
- Claude Desktop/Cowork(비개발자용 앱): 플러그인 브라우저는 마켓플레이스 기반만 지원 **[2차]**; 외부 GitHub 마켓플레이스 추가 가능 여부 **미확인**. 판매 대상이 터미널을 못 쓰는 층이면 이 경로 실기기 테스트 필수.

### Codex **[2차]**
- `codex` 실행 후 "이 레포 플러그인 설치해줘" → 모델이 `codex plugin marketplace add … && codex plugin add …` 실행. 샌드박스 밖 네트워크 명령은 승인 요청(escalation) 발생. 또는 `$skill-installer install <URL>`이 공식 경로. 설치 후 **재시작 필요**. 앱에서는 Plugins → Add marketplace UI.
- 프라이빗 저장소는 `gh auth login && gh auth setup-git` 선행.

→ 결론: **"한 줄 설치"는 양쪽 모두 가능하나, private 접근 인증(GitHub 로그인 또는 라이선스 키 환경변수)은 사람이 1회 해야 한다.** 이 1회를 최대한 쉽게 만드는 것이 온보딩 문서의 핵심.

---

## 5. 결제 연동

### 5.1 해외 플랫폼
- **Gumroad** **[2차]**: 한국 판매자 KRW 은행 직접 정산 지원(2022-08~, 최소 40,000 KRW) — 출처: https://gumroad.gumroad.com/p/local-bank-account-support-in-more-countries , https://gumroad.com/help/article/13-getting-paid (차단). 라이선스 키 자동 발급("Generate a unique license key per sale") + 검증 API `POST https://api.gumroad.com/v2/licenses/verify` (`product_id`, `license_key`, `increment_uses_count`) — 출처: https://help.gumroad.com/article/76-license-keys , https://dev.to/zsevic/license-key-verification-with-gumroad-api-58f9 . 수수료 10%+결제수수료 수준 **[2차]**. **MVP 최적**: 결제·키 발급·검증 API를 다 제공하고 MCP 서버가 verify 호출만 하면 됨. 한국 판매자 가입 자체는 실제 가입으로 확인 필요(**미확인**).
- **Lemon Squeezy** **[2차]**: 라이선스 API `POST /v1/licenses/activate|validate|deactivate`(키 자체가 인증, 60 req/min) — https://docs.lemonsqueezy.com/api/license-api (차단). 2024 Stripe 인수, 2026 현재 신규 가입 가능하나 Stripe Managed Payments로 이행 중(https://www.lemonsqueezy.com/blog/2026-update). 한국 판매자 정산 지원 여부 **미확인**. 장기 안정성 의문 → 보류.
- **Polar.sh** **[2차]**: MoR, 라이선스 키 benefit + 검증 엔드포인트(https://polar.sh/docs). 한국 판매자 지원 **미확인**(https://polar.apidocumentation.com/documentation/polar-as-merchant-of-record/supported-countries 확인 필요).
- **Stripe 직접** **[2차]**: 한국은 Stripe 계정 개설 미지원 국가(https://stripe.com/global). 해외 법인 없으면 불가. → **기각.**

### 5.2 국내
- **토스페이먼츠/카카오페이**: 사업자등록 + 통신판매업 신고 필요(간이과세자·연 50건 미만 면제) — https://docs.tosspayments.com/resources/glossary/online-business , https://www.tosspayments.com/blog/articles/sales-registration . 결제 승인 웹훅 → 자체 키 발급/협업자 초대 코드를 직접 짜야 함(반나절~1일). 변호사 사무소는 이미 사업자이므로 통신판매업 신고만 추가.
- 실무 패턴: 결제 성공 웹훅 → (a) 키 생성·DB 저장·이메일 발송, (b) 고객 GitHub 아이디 입력 폼 → GitHub API로 협업자 초대. MCP 서버는 자체 DB에서 키 검증.
- 크몽·스마트스토어 등 디지털파일 판매: 키 발급 자동화가 안 되어 수작업 → 소량 초기엔 가능하나 비권장.

### 5.3 권장
- **1주차**: Gumroad(가입 가능 확인 시) — 결제+키 발급+verify API 일괄. 국내 고객 카드 결제 가능(달러 표시 단점).
- **병행/대체**: 토스페이먼츠 + 자체 키 발급(간단한 Cloudflare Worker + KV). 한국 고객 UX 우수.

---

## 6. 권고 아키텍처

### 1안 (MVP, 1주일 내 판매): Private GitHub 마켓플레이스 + 결제 연동 협업자 초대
1. 저장소 `yourorg/solo-lawsuit-kit`(private): `.claude-plugin/marketplace.json` + `plugins/solo-lawsuit/{.claude-plugin/plugin.json, .codex-plugin/plugin.json, skills/*, agents/*, hooks/hooks.json}` + `.agents/plugins/marketplace.json`(Codex용) + `LICENSE.md`(EULA) + `README`(설치 3단계).
2. `plugin.json` `version` 명시 + CHANGELOG. 마켓플레이스 settings 예시(`extraKnownMarketplaces` + `autoUpdate: true`)를 README에 제공.
3. 결제: Gumroad(또는 토스) → 웹훅(Cloudflare Worker/Vercel) → 고객 GitHub ID 수집 폼 → `PUT /repos/.../collaborators/{user}` (permission: pull). 환불 시 DELETE.
4. 고객 온보딩(3단계): ① GitHub 가입 + 초대 수락 ② 터미널에서 `gh auth login` ③ `claude` 실행 후 `/plugin install solo-lawsuit --marketplace yourorg/solo-lawsuit-kit` (Codex: `codex plugin marketplace add yourorg/solo-lawsuit-kit --ref main && codex plugin add solo-lawsuit@solo-lawsuit`).
5. 업데이트: 판매자 `git push` + version bump → 고객은 세션 시작 시 auto-update(켜져 있고 SSH/gh 인증이 되면) 또는 `/plugin update solo-lawsuit@solo-lawsuit` 안내. SessionStart 훅으로 "새 버전 있음" 알림 가능(훅이 `git ls-remote`로 비교).
6. 보호: 파일 헤더 영업비밀 표시, EULA 클릭랩, 커밋 로그 보존. (워터마크는 이 안에서 불가.)

### 2안 (2~6주 후 진화): 원격 MCP 서버로 프롬프트 본문 이전
1. 저장소는 유지하되 **public 또는 archive**로 전환(껍데기만): SKILL.md는 "이 작업은 `/solo:complaint` MCP 프롬프트를 호출" 정도의 라우팅 + `.mcp.json`(`url`, `headers: {Authorization: Bearer ${SOLO_KEY}}`).
2. MCP 서버(Streamable HTTP; TypeScript MCP SDK, Cloudflare Workers/Fly): `prompts/list|get`(Claude Code 슬래시 명령) + `tools: get_prompt/list_templates`(Codex 호환). 키 검증(자체 DB 또는 Gumroad verify 캐시), 기기 수 제한, 호출 로깅, 응답에 고객 식별 워터마크.
3. 고객 데이터 비전송 원칙을 코드·약관에 명시(입력 인자는 템플릿 ID·옵션만).
4. 업데이트 즉시 반영, 키 정지로 해지. 오프라인 대비 "최근 버전 24시간 캐시"는 보호 목적상 두지 않음(또는 메모리만).
5. 확인 필요: Codex의 MCP prompts 지원(미확인 → tools로 폴백), Claude Desktop/Cowork에서 외부 마켓플레이스 추가 가능 여부(미확인).

### MVP 순서(1주일)
- D1: 저장소 구조·plugin.json·SKILL.md 정리, 로컬 `claude --plugin-dir ./plugins/solo-lawsuit` 테스트, `claude plugin validate`.
- D2: Codex 매니페스트 추가 후 `codex plugin marketplace add`로 교차 테스트(private 인증 포함).
- D3: EULA·영업비밀 표시·README 온보딩 3단계 작성. Gumroad 판매자 가입 시도(불가 시 토스 신청).
- D4: 결제 웹훅 → GitHub 협업자 초대 Worker(50줄). 환불 → 제거.
- D5: 지인 2~3명 비개발자 설치 테스트(Windows 포함), 온보딩 문서 수정.
- D6~7: 랜딩·판매 개시. 동시에 2안 MCP 서버 스캐폴딩 시작.

---

## 7. 결론: 권고 / 기각

**권고**
- 배포 단위는 **플러그인(마켓플레이스)**로 통일 — Claude Code·Codex 모두 같은 저장소로 커버(양쪽 매니페스트 동봉).
- MVP는 **private GitHub + 결제 웹훅 협업자 초대**, 명시 `version` + CHANGELOG, `extraKnownMarketplaces autoUpdate` 예시 제공.
- 온보딩은 "**GitHub 로그인 1회 + 슬래시 명령 1줄**"로 설계(`/plugin install X --marketplace owner/repo`).
- 2단계로 **원격 MCP 서버**(prompts+tools, Bearer 라이선스 키, 워터마크, 사용량 로그, 고객 데이터 비전송).
- 법적 장치 필수: EULA 클릭랩(재배포 금지·1인 라이선스·법률자문 아님), 파일/응답에 영업비밀 표시, 접근 통제·로그로 **비밀관리성** 입증, 커밋 이력으로 저작 과정 기록.
- 결제: Gumroad(한국 정산 가능 확인 시) 우선, 토스페이먼츠+자체 키 발급 병행.

**기각**
- 난독화/암호화 스킬 파일 — 모델이 읽는 순간 평문, 세션 로그에 남음, 비밀관리 조치로도 약함.
- 공용 read-only 토큰 하나를 전 고객에게 배포 — 회수 불가, 유출 시 전면 노출.
- AGENTS.md / CLAUDE.md에 프롬프트 본문 배포 — 업데이트 불가, 컨텍스트 낭비.
- `--add-dir` + 수동 git pull — 세션마다 플래그, 비개발자에 부적합.
- Stripe 직접 계정 — 한국 법인 미지원.
- Lemon Squeezy 단독 의존 — Stripe Managed Payments로 이행 중, 한국 정산 미확인.
- "완전 비노출" 목표 자체 — 달성 불가. 목표를 "복제 억지 + 계약·법적 억지 + 해지 통제"로 재정의.

---

## 부록: 확인 못 한 항목(미확인 목록)
1. Codex 공식 문서(plugins/skills/mcp/AGENTS.md) 원문 — 프록시 차단으로 2차 자료만.
2. Codex에서 MCP **prompts**가 사용자 명령으로 노출되는지.
3. Codex 설치 플러그인의 자동 업데이트(마켓플레이스 upgrade 후 재설치 필요 여부).
4. 한 저장소에 `.claude-plugin`과 `.codex-plugin`을 동봉했을 때 양쪽 동시 동작(커뮤니티 README는 "지원"이라 하나 직접 테스트 필요).
5. Claude Desktop/Cowork에서 외부 GitHub 마켓플레이스 추가 가능 여부.
6. Gumroad 한국 판매자 신규 가입 가능 여부(정산 지원은 2차 확인), Lemon Squeezy·Polar의 한국 판매자 지원.
7. Claude Code `archive` 소스 + `headers` 인증이 Codex에서도 동작하는지.
8. 국내 판례상 "판매용 프롬프트"의 비공지성 인정 사례 — 직접 판례 확인 못 함.

## 부록: 주요 출처
- Claude Code 플러그인 마켓플레이스: https://code.claude.com/docs/en/plugin-marketplaces
- 플러그인 검색·설치·auto-update: https://code.claude.com/docs/en/discover-plugins
- 플러그인 작성: https://code.claude.com/docs/en/plugins
- 플러그인 레퍼런스(캐시·버전): https://code.claude.com/docs/en/plugins-reference
- Skills: https://code.claude.com/docs/en/skills
- Subagents: https://code.claude.com/docs/en/sub-agents
- Slash commands: https://code.claude.com/docs/en/slash-commands
- MCP(원격·인증·prompts): https://code.claude.com/docs/en/mcp
- Settings reference(extraKnownMarketplaces): https://code.claude.com/docs/en/settings-reference
- Permissions(권한 프롬프트·trust): https://code.claude.com/docs/en/permissions
- Hooks: https://code.claude.com/docs/en/hooks
- Sessions(로컬 transcript): https://code.claude.com/docs/en/sessions
- OpenAI plugins 예제 저장소: https://github.com/openai/plugins
- OpenAI skills / skill-installer: https://github.com/openai/skills , https://github.com/openai/skills/blob/main/skills/.system/skill-installer/SKILL.md
- Codex plugins 공식(차단): https://developers.openai.com/codex/plugins , https://developers.openai.com/codex/plugins/build , https://developers.openai.com/codex/mcp , https://developers.openai.com/codex/guides/agents-md
- Codex 교차 설치 검증 README: https://github.com/the-incubator/incubator-build-plugin
- Codex marketplace 자동 upgrade PR: https://github.com/openai/codex/pull/17425
- MCP prompts 스펙: https://spec.modelcontextprotocol.io/specification/2024-11-05/server/prompts/
- Gumroad 라이선스 키: https://help.gumroad.com/article/76-license-keys ; 한국 정산: https://gumroad.gumroad.com/p/local-bank-account-support-in-more-countries
- Lemon Squeezy License API: https://docs.lemonsqueezy.com/api/license-api ; 2026 업데이트: https://www.lemonsqueezy.com/blog/2026-update
- Stripe 지원 국가: https://stripe.com/global
- 토스페이먼츠 통신판매업: https://docs.tosspayments.com/resources/glossary/online-business
- 영업비밀 요건: https://www.tradesecret.or.kr/institution/requirement.do ; 2019 개정 해설: https://news.koreanbar.or.kr/news/articleView.html?idxno=29620
- 프롬프트 저작물성: https://magazine.hankyung.com/business/article/202601288711b ; https://www.kci.go.kr/kciportal/ci/sereArticleSearch/ciSereArtiView.kci?sereArticleSearchBean.artiId=ART003214947
