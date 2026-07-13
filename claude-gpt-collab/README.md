# Claude Code × GPT 협업 설정 킷

Claude Code 안에서 GPT(GPT-5.6 Sol 등)를 함께 사용하는 두 가지 방법을 정리하고,
로컬에서 바로 실행할 수 있는 설치 스크립트를 제공합니다.

**둘 다 API 종량제가 아니라 구독 요금으로 동작합니다:**
Claude 구독(Pro/Max) + ChatGPT 구독(Plus/Pro)이 각각 필요합니다.

> 이 설정은 전부 **로컬 PC의 터미널**에서 실행하는 것입니다.
> (Claude Code CLI 기준. 데스크탑 앱은 방법 1만 해당)

---

## 방법 1 — OpenAI 공식 Codex 플러그인 (권장 ✅)

OpenAI가 직접 배포하는 공식 플러그인입니다. 약관 문제가 없고 가장 간단합니다.

### 사전 준비
- Claude Code 설치 및 로그인 (Claude 구독)
- [Codex CLI](https://github.com/openai/codex) 설치: `npm install -g @openai/codex`
- Codex CLI에서 ChatGPT 계정으로 로그인: `codex` 실행 후 **Sign in with ChatGPT** 선택
  (이게 바로 "GPT OAuth 연결"입니다 — ChatGPT 구독 요금으로 과금)

### 설치 (Claude Code 안에서 실행)

```
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

### 사용법

| 명령 | 동작 |
|------|------|
| `/codex:review` | GPT가 현재 변경사항을 코드 리뷰 |
| `/codex:adversarial-review` | GPT가 적대적(비판적) 관점으로 교차 검증 |
| `/codex:delegate <작업>` | 작업을 GPT에게 위임 |
| `/codex:transfer` | 현재 세션을 Codex로 이전 |

Claude가 메인으로 일하고, 필요할 때 GPT를 호출하는 구조 — 이것이 "자동 협업"의 실체입니다.

---

## 방법 2 — CLIProxyAPI + `claudex` 별칭 (비공식 ⚠️)

[CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI)로 ChatGPT 구독을
로컬 API 엔드포인트로 변환한 뒤, Claude Code의 **서브에이전트만 GPT-5.6 Sol**로
돌리는 방식입니다. (메인 에이전트 = Claude, 서브에이전트 = GPT)

> ⚠️ **주의**: ChatGPT OAuth 토큰을 Codex CLI 밖에서 사용하는 것은 OpenAI 약관상
> 회색지대입니다. 계정 제재 가능성을 감수하고 사용하세요. 안전하게 가려면 방법 1을 쓰세요.

### 빠른 시작

```bash
# 1단계: CLIProxyAPI 설치 + 설정 파일 생성
./setup-cliproxy.sh

# 2단계: ChatGPT 계정 OAuth 연결 (브라우저 창이 열립니다)
~/.cli-proxy-api/cli-proxy-api --codex-login

# 3단계: 프록시 서버 실행 (백그라운드 유지)
~/.cli-proxy-api/cli-proxy-api

# 4단계: 별칭 등록 후 claudex 실행
echo "source $(pwd)/claudex.sh" >> ~/.zshrc   # bash라면 ~/.bashrc
source ~/.zshrc
claudex
```

### 동작 원리

```
┌─────────────┐   Claude 구독    ┌──────────────┐
│ Claude Code │ ───────────────▶ │  Anthropic   │  메인 에이전트 (Claude)
│  (claudex)  │                  └──────────────┘
│             │   localhost:8317 ┌──────────────┐   ChatGPT 구독(OAuth)
│ 서브에이전트  │ ───────────────▶ │ CLIProxyAPI  │ ─▶ OpenAI (GPT-5.6 Sol)
└─────────────┘                  └──────────────┘
```

`claudex.sh`가 설정하는 환경 변수:

| 변수 | 값 | 의미 |
|------|-----|------|
| `CLAUDE_CODE_SUBAGENT_MODEL` | `gpt-5.6-sol` | 서브에이전트를 GPT로 |
| `CLAUDE_CODE_ALWAYS_ENABLE_EFFORT` | `1` | reasoning effort 제어 활성화 |
| `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` | `3` | 동시 툴 실행 제한 (토큰 폭주 방지) |

---

## 어떤 걸 써야 하나?

| | 방법 1 (공식 플러그인) | 방법 2 (CLIProxyAPI) |
|---|---|---|
| 공식 지원 | ✅ OpenAI 공식 | ❌ 커뮤니티 |
| 약관 리스크 | 없음 | 있음 (계정 제재 가능) |
| 설정 난이도 | 5분, 명령 4줄 | 15분, 프록시 상시 실행 필요 |
| 협업 형태 | 명시적 호출 (`/codex:review` 등) | 서브에이전트 자동 위임 |
| 데스크탑 앱 | 지원 | CLI 전용 |

**처음이라면 방법 1부터 시작하세요.** 서브에이전트까지 GPT로 돌리고 싶어지면 그때 방법 2를 검토하면 됩니다.

## 참고 자료

- [openai/codex-plugin-cc](https://github.com/openai/codex-plugin-cc) — 공식 플러그인
- [router-for-me/CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) — 프록시
- [원문 트윗 (Tibo)](https://x.com/thsottiaux/status/2076119366647894371) — `claudex` 별칭 출처
