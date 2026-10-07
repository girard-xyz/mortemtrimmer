#!/usr/bin/env bash
# Cut the robotic/metallic band in every .wav, writing a sibling .clean.wav.
# Usage: bash demetal.sh [input_dir] [freq] [gain_db] [width_hz]
set -u

INPUT_DIR="${1:-out}"
FREQ="${2:-3000}"
GAIN="${3:--6}"
WIDTH="${4:-200}"

shopt -s nullglob
files=("$INPUT_DIR"/*.wav)
if [ ${#files[@]} -eq 0 ]; then
  echo "No .wav files found in $INPUT_DIR" >&2
  exit 1
fi

i=0
fail=0
for f in "${files[@]}"; do
  case "$f" in *.clean.wav) continue ;; esac
  i=$((i + 1))
  out="${f%.wav}.clean.wav"
  printf '=== [%d/%d] %s -> %s ===\n' "$i" "${#files[@]}" "$(basename "$f")" "$(basename "$out")"
  if ffmpeg -y -hide_banner -loglevel error -i "$f" \
    -af "equalizer=f=${FREQ}:width_type=h:w=${WIDTH}:g=${GAIN}" "$out"; then
    :
  else
    echo "FAILED: $(basename "$f")"
    fail=$((fail + 1))
  fi
done
printf 'DONE: %d cleaned, %d failed\n' "$i" "$fail"
[ "$fail" -eq 0 ]
