#!/usr/bin/env bash
set -euo pipefail

VERSION="v0.2.12"
BINARY_NAME="um-darwin-arm64"
DOWNLOAD_URL="https://git.unlock-music.dev/um/cli/releases/download/${VERSION}/${BINARY_NAME}.tar.gz"
INSTALL_DIR="${UM_INSTALL_DIR:-$HOME/.codex/tools/unlock-music/${VERSION}}"
INSTALL_PATH="${INSTALL_DIR}/${BINARY_NAME}"

print_path=false
if [[ "${1:-}" == "--print-path" ]]; then
  print_path=true
fi

is_usable() {
  local candidate="$1"
  [[ -x "$candidate" ]] || return 1
  "$candidate" --version >/dev/null 2>&1
}

emit_path() {
  local candidate="$1"
  if [[ "$print_path" == true ]]; then
    printf '%s\n' "$candidate"
  else
    "$candidate" --version
  fi
}

if command -v "$BINARY_NAME" >/dev/null 2>&1; then
  candidate="$(command -v "$BINARY_NAME")"
  if is_usable "$candidate"; then
    emit_path "$candidate"
    exit 0
  fi
fi

if is_usable "$INSTALL_PATH"; then
  emit_path "$INSTALL_PATH"
  exit 0
fi

mkdir -p "$INSTALL_DIR"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

if curl -L --fail --progress-bar -o "$tmp_dir/${BINARY_NAME}.tar.gz" "$DOWNLOAD_URL"; then
  tar -xzf "$tmp_dir/${BINARY_NAME}.tar.gz" -C "$tmp_dir"
  install -m 0755 "$tmp_dir/$BINARY_NAME" "$INSTALL_PATH"
  emit_path "$INSTALL_PATH"
  exit 0
fi

if ! command -v go >/dev/null 2>&1; then
  printf 'Failed to download %s and Go is not available for fallback build.\n' "$DOWNLOAD_URL" >&2
  exit 1
fi

build_dir="$tmp_dir/build"
mkdir -p "$build_dir"
GOOS=darwin GOARCH=arm64 GOBIN="$build_dir" go install -trimpath -ldflags "-s -w -X main.AppVersion=${VERSION}" "unlock-music.dev/cli/cmd/um@${VERSION}"
install -m 0755 "$build_dir/um" "$INSTALL_PATH"
emit_path "$INSTALL_PATH"
