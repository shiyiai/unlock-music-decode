#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage:
  decode_original.sh <input-file-or-dir> [output-dir] [extra um flags...]

Examples:
  decode_original.sh ./songs ./songs/original-files
  decode_original.sh ./track.ncm ./original-files --overwrite
USAGE
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
input_path="$1"
shift

if [[ ! -e "$input_path" ]]; then
  printf 'Input path does not exist: %s\n' "$input_path" >&2
  exit 1
fi

if [[ $# -gt 0 && "${1:-}" != -* ]]; then
  output_dir="$1"
  shift
else
  if [[ -d "$input_path" ]]; then
    output_dir="${input_path%/}/original-files"
  else
    output_dir="$(dirname "$input_path")/original-files"
  fi
fi

mkdir -p "$output_dir"
um_path="$("$SCRIPT_DIR/ensure_um_darwin_arm64.sh" --print-path)"

exec "$um_path" -i "$input_path" -o "$output_dir" "$@"
