#!/usr/bin/env bash
# Batch-process recordings through mortem.py with sequential prefixed output names.
# Usage: bash batch.sh [input_dir] [output_dir] [prefix]
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_DIR="${1:-records}"
OUTPUT_DIR="${2:-out}"
PREFIX="${3:-ysoline_julien_message_}"
METHOD="${METHOD:-deepfilter}"

PYTHON="${PYTHON:-$ROOT/.venv/bin/python}"
[ -x "$PYTHON" ] || PYTHON=python

shopt -s nullglob
files=("$INPUT_DIR"/*.wav)
if [ ${#files[@]} -eq 0 ]; then
  echo "No .wav files found in $INPUT_DIR" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
i=0
fail=0
for f in "${files[@]}"; do
  i=$((i + 1))
  n=$(printf "%02d" "$i")
  out="$OUTPUT_DIR/${PREFIX}${n}.wav"
  printf '=== [%d/%d] %s -> %s ===\n' "$i" "${#files[@]}" "$(basename "$f")" "$(basename "$out")"
  if "$PYTHON" "$ROOT/mortem.py" -i "$f" -o "$out" -m "$METHOD"; then
    rm -f "${out}.manifest.txt"
  else
    echo "FAILED: $(basename "$f")"
    fail=$((fail + 1))
  fi
done
printf 'DONE: %d processed, %d failed\n' "$i" "$fail"
[ "$fail" -eq 0 ]
