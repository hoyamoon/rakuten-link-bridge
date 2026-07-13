# claudex — Claude Code(메인) + GPT-5.6 Sol(서브에이전트) 협업 모드
# 사용법: ~/.zshrc 또는 ~/.bashrc 에 `source /path/to/claudex.sh` 추가
#
# 전제: CLIProxyAPI 가 localhost:8317 에서 실행 중이고 --codex-login 완료 상태여야 합니다.
#       (setup-cliproxy.sh 참고)
#
# 원리: 메인 에이전트는 평소처럼 Claude 구독으로 돌고,
#       서브에이전트(Agent tool)만 프록시를 통해 GPT-5.6 Sol 로 실행됩니다.

claudex() {
  # 프록시 살아있는지 확인
  if ! curl -sf -o /dev/null "http://localhost:8317/" 2>/dev/null; then
    echo "⚠️  CLIProxyAPI가 localhost:8317 에서 응답하지 않습니다."
    echo "   먼저 실행하세요:  ~/.cli-proxy-api/cli-proxy-api"
    return 1
  fi

  CLAUDE_CODE_SUBAGENT_MODEL=gpt-5.6-sol \
  CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1 \
  CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY=3 \
  claude "$@"
}

# GPT를 메인 모델로도 쓰고 싶을 때 (전체를 GPT로 — Claude 구독 대신 ChatGPT 구독 사용)
claudex-full() {
  if ! curl -sf -o /dev/null "http://localhost:8317/" 2>/dev/null; then
    echo "⚠️  CLIProxyAPI가 localhost:8317 에서 응답하지 않습니다."
    return 1
  fi

  ANTHROPIC_BASE_URL=http://localhost:8317 \
  ANTHROPIC_AUTH_TOKEN=dummy \
  CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1 \
  CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY=3 \
  claude --model gpt-5.6-sol "$@"
}
