#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM="$ROOT/upstream"
REPO="https://github.com/FareedKhan-dev/kimi-k3-in-c.git"
PIN="117e9d29bde14db9742f54fb66a191fd0bf03903"

if ! command -v git >/dev/null 2>&1; then
  echo "error: git is required" >&2
  exit 2
fi
if ! command -v make >/dev/null 2>&1; then
  echo "error: GNU make is required (Windows: run inside MSYS2 MinGW64)" >&2
  exit 2
fi

if [[ ! -d "$UPSTREAM/.git" ]]; then
  git clone "$REPO" "$UPSTREAM"
fi

git -C "$UPSTREAM" fetch --tags origin
git -C "$UPSTREAM" checkout --detach "$PIN"

# Portable = generic AVX2/FMA on x86_64; architecture baseline on ARM64.
make -C "$UPSTREAM" portable -j"${KIMIK3_JOBS:-2}"

echo
echo "KimiK3-4G bootstrap complete."
echo "Pinned upstream: $(git -C "$UPSTREAM" rev-parse HEAD)"
echo "Run: $ROOT/scripts/verify.sh"
