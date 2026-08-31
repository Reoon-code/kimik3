#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
K3="$ROOT/upstream/bin/k3"

MODEL=""
TRUNK=""
TOK=""
PROMPT=""
PROMPT_FILE=""
IDS=""
GEN=1
OUT="k3_4gb_run.json"

usage() {
  cat <<'USAGE'
Usage:
  run-4gb.sh --model DIR --trunk DIR [--tok DIR] [prompt option] [--gen N] [--out FILE]

Prompt option (exactly one):
  --prompt TEXT
  --prompt-file FILE
  --ids 1,2,3

Examples:
  ./scripts/run-4gb.sh --model ~/k3model --trunk ~/k3trunk --tok ~/k3model \
    --prompt "The capital of France is" --gen 1
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --model) MODEL="${2:-}"; shift 2 ;;
    --trunk) TRUNK="${2:-}"; shift 2 ;;
    --tok) TOK="${2:-}"; shift 2 ;;
    --prompt) PROMPT="${2:-}"; shift 2 ;;
    --prompt-file) PROMPT_FILE="${2:-}"; shift 2 ;;
    --ids) IDS="${2:-}"; shift 2 ;;
    --gen) GEN="${2:-}"; shift 2 ;;
    --out) OUT="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --incremental|--spec|--draft-trunk|--draft-trunk-gb|--cache-gb|--trunk-gb|--preset)
      echo "error: '$1' is intentionally locked by the 4 GB profile" >&2
      exit 2 ;;
    *) echo "error: unknown option '$1'" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ ! -x "$K3" ]]; then
  echo "error: $K3 not found; run ./scripts/bootstrap.sh first" >&2
  exit 2
fi
if [[ -z "$MODEL" || -z "$TRUNK" ]]; then
  echo "error: --model and --trunk are required" >&2
  exit 2
fi
if ! [[ "$GEN" =~ ^[0-9]+$ ]]; then
  echo "error: --gen must be a non-negative integer" >&2
  exit 2
fi

n_prompt=0
[[ -n "$PROMPT" ]] && n_prompt=$((n_prompt + 1))
[[ -n "$PROMPT_FILE" ]] && n_prompt=$((n_prompt + 1))
[[ -n "$IDS" ]] && n_prompt=$((n_prompt + 1))
if [[ $n_prompt -ne 1 ]]; then
  echo "error: provide exactly one of --prompt, --prompt-file, --ids" >&2
  exit 2
fi

args=("$K3" "$MODEL" --trunk "$TRUNK" --preset ultra --ultra-low-memory --gen "$GEN" --out "$OUT")
if [[ -n "$PROMPT" ]]; then
  [[ -n "$TOK" ]] || { echo "error: --prompt needs --tok DIR" >&2; exit 2; }
  args+=(--tok "$TOK" --prompt "$PROMPT")
elif [[ -n "$PROMPT_FILE" ]]; then
  [[ -n "$TOK" ]] || { echo "error: --prompt-file needs --tok DIR" >&2; exit 2; }
  args+=(--tok "$TOK" --prompt-file "$PROMPT_FILE")
else
  args+=(--ids "$IDS")
fi

# The full checkpoint is already I/O heavy. Keep other allocators from surprising the box.
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-2}"

printf 'KimiK3-4G: ultra profile, full recompute, gen=%s\n' "$GEN"
printf 'Command:'; printf ' %q' "${args[@]}"; printf '\n\n'
exec "${args[@]}"
