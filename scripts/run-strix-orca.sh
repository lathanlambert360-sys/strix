#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY_FILE="${STRIX_ORCA_KEY_FILE:-$HOME/.strix/orcarouter-key}"

if [[ -z "${ORCAROUTER_API_KEY:-}" && -r "$KEY_FILE" ]]; then
  ORCAROUTER_API_KEY="$(<"$KEY_FILE")"
fi

if [[ -z "${ORCAROUTER_API_KEY:-}" && -t 0 ]]; then
  read -rsp "OrcaRouter API key: " ORCAROUTER_API_KEY
  printf '\n'
fi

if [[ -z "${ORCAROUTER_API_KEY:-}" ]]; then
  printf 'ORCAROUTER_API_KEY is required.\n' >&2
  exit 1
fi

export STRIX_LLM="${STRIX_LLM:-openai/orca/orcacyber-flash-1.0-free}"
export LLM_API_BASE="${LLM_API_BASE:-https://api.orcarouter.ai/v1}"
export LLM_API_KEY="$ORCAROUTER_API_KEY"
export STRIX_API_TYPE="${STRIX_API_TYPE:-chat_completions}"

cd "$ROOT"
if command -v uv >/dev/null 2>&1; then
  exec uv run strix "$@"
fi
exec python3 -m strix.interface.main "$@"
