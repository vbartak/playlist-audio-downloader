#!/bin/bash

# Spotify playlist downloader
# Requires: yt-dlp  (pip install yt-dlp)
#           ffmpeg  (sudo apt install ffmpeg)
#           mutagen (pip install mutagen)
# Usage: bash download_neuro_dub.sh playlist.csv [output_dir]

CSV="$1"
CSV_NAME="$(basename "$CSV" .csv)"
OUTPUT_DIR="${2:-./output}/$CSV_NAME"

if [[ -z "$CSV" ]]; then
  echo "Použití: $0 playlist.csv [output_dir]"
  exit 1
fi

if [[ ! -f "$CSV" ]]; then
  echo "Soubor nenalezen: $CSV"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Přečti CSV, přeskoč hlavičku, sestav "Artist - Track" pro každý řádek
mapfile -t TRACKS < <(tail -n +2 "$CSV" | awk -F',' '{
  # Track Name je sloupec 2, Artist Name(s) je sloupec 4
  gsub(/"/, "", $2)
  gsub(/"/, "", $4)
  # Nahraď středník (více interpretů) mezerou
  gsub(/;/, " ", $4)
  print $4 " - " $2
}')

total=${#TRACKS[@]}
count=0

for track in "${TRACKS[@]}"; do
  count=$((count + 1))
  echo ""
  echo "[$count/$total] Stahuji: $track"
  yt-dlp \
    "ytsearch1:$track" \
    --format "bestaudio/best" \
    --extract-audio \
    --audio-format flac \
    --audio-quality 0 \
    --output "$OUTPUT_DIR/%(title)s.%(ext)s" \
    --no-playlist \
    --quiet \
    --progress \
    --embed-thumbnail \
    --add-metadata \
    --download-archive "$OUTPUT_DIR/.downloaded.txt"
done

echo ""
echo "Hotovo! Skladby jsou v: $OUTPUT_DIR"
