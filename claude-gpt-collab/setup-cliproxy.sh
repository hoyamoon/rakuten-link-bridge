#!/usr/bin/env bash
# CLIProxyAPI 설치 스크립트 (macOS / Linux)
# ChatGPT 구독을 로컬 API 엔드포인트로 변환해 Claude Code 서브에이전트에서 GPT를 쓰기 위한 준비.
# 사용법: ./setup-cliproxy.sh
set -euo pipefail

INSTALL_DIR="$HOME/.cli-proxy-api"
REPO="router-for-me/CLIProxyAPI"
PORT=8317

echo "==> CLIProxyAPI 설치를 시작합니다 (설치 위치: $INSTALL_DIR)"
mkdir -p "$INSTALL_DIR"

# OS/아키텍처 판별
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"   # darwin | linux
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  ARCH="amd64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *) echo "지원하지 않는 아키텍처: $ARCH"; exit 1 ;;
esac

# 최신 릴리스에서 바이너리 다운로드 (자산 이름은 릴리스마다 다를 수 있어 패턴 매칭)
echo "==> 최신 릴리스 확인 중..."
ASSET_URL=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
  | grep -o "\"browser_download_url\": *\"[^\"]*${OS}[^\"]*${ARCH}[^\"]*\"" \
  | head -1 | sed 's/.*"\(https[^"]*\)"/\1/')

if [ -z "$ASSET_URL" ]; then
  echo "!! 사전 빌드 바이너리를 찾지 못했습니다. Go로 직접 빌드합니다 (go 필요)."
  command -v go >/dev/null || { echo "go가 설치되어 있지 않습니다. https://go.dev/dl/ 에서 설치 후 재실행하세요."; exit 1; }
  TMP=$(mktemp -d)
  git clone --depth 1 "https://github.com/$REPO.git" "$TMP/src"
  (cd "$TMP/src" && go build -o "$INSTALL_DIR/cli-proxy-api" ./cmd/server)
  rm -rf "$TMP"
else
  echo "==> 다운로드: $ASSET_URL"
  curl -fsSL "$ASSET_URL" -o "$INSTALL_DIR/cli-proxy-api.download"
  # tar.gz 로 배포되는 경우 압축 해제
  if file "$INSTALL_DIR/cli-proxy-api.download" | grep -q gzip; then
    tar -xzf "$INSTALL_DIR/cli-proxy-api.download" -C "$INSTALL_DIR"
    rm "$INSTALL_DIR/cli-proxy-api.download"
    BIN=$(find "$INSTALL_DIR" -maxdepth 2 -type f -name 'cli-proxy-api*' ! -name '*.yaml' | head -1)
    [ "$BIN" != "$INSTALL_DIR/cli-proxy-api" ] && mv "$BIN" "$INSTALL_DIR/cli-proxy-api"
  else
    mv "$INSTALL_DIR/cli-proxy-api.download" "$INSTALL_DIR/cli-proxy-api"
  fi
fi
chmod +x "$INSTALL_DIR/cli-proxy-api"

# 기본 설정 파일 생성 (이미 있으면 보존)
CONFIG="$INSTALL_DIR/config.yaml"
if [ ! -f "$CONFIG" ]; then
  cat > "$CONFIG" <<EOF
port: $PORT
auth-dir: "$INSTALL_DIR"
debug: false
EOF
  echo "==> 설정 파일 생성: $CONFIG"
else
  echo "==> 기존 설정 파일 유지: $CONFIG"
fi

echo ""
echo "✅ 설치 완료! 다음 단계:"
echo ""
echo "  1) ChatGPT 계정 OAuth 연결 (브라우저가 열립니다):"
echo "       $INSTALL_DIR/cli-proxy-api --codex-login"
echo ""
echo "  2) 프록시 서버 실행 (사용하는 동안 켜 두세요):"
echo "       $INSTALL_DIR/cli-proxy-api"
echo ""
echo "  3) claudex 별칭 등록:"
echo "       echo \"source $(cd "$(dirname "$0")" && pwd)/claudex.sh\" >> ~/.zshrc && source ~/.zshrc"
echo ""
echo "  4) 프로젝트 폴더에서 claudex 실행!"
