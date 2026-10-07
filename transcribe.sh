#!/usr/bin/env bash
# Transcribe every .wav in a directory with whisper-cli, writing a sibling .txt.
# Usage: bash transcribe.sh [input_dir] [model] [lang]
set -u

INPUT_DIR="${1:-out}"
MODEL="${2:-ggml-large-v3-turbo.bin}"
LANG="${3:-fr}"

shopt -s nullglob
files=("$INPUT_DIR"/*.wav)
if [ ${#files[@]} -eq 0 ]; then
  echo "No .wav files found in $INPUT_DIR" >&2
  exit 1
fi

i=0
fail=0
for f in "${files[@]}"; do
  i=$((i + 1))
  out="${f%.wav}"
  printf '=== [%d/%d] %s -> %s.txt ===\n' "$i" "${#files[@]}" "$(basename "$f")" "$(basename "$out")"
  if whisper-cli -m "$MODEL" -f "$f" -l "$LANG" -otxt -of "$out" -t 10; then
    :
  else
    echo "FAILED: $(basename "$f")"
    fail=$((fail + 1))
  fi
done
printf 'DONE: %d transcribed, %d failed\n' "$i" "$fail"
[ "$fail" -eq 0 ]
