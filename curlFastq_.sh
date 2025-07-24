#!/bin/bash

# Usage: sh curlFastq.sh accessions.txt

set -euo pipefail

ACCESSION_FILE="$1"

# Check that the input file exists
if [[ ! -f "$ACCESSION_FILE" ]]; then
    echo "Error: input file $ACCESSION_FILE not found."
    exit 1
fi

while read -r ACCESSION; do
  JSON_FILE="${ACCESSION}.json"
  TARGET_DIR="../FastqFiles/${ACCESSION}"  ERROR_LOG="./download_errors.log"
	ERROR_LOG="../downloadSRA/errorLOG.txt"

  cd "$TARGET_DIR"

  echo "🔍 Parsing $JSON_FILE..."

  # Extract urls and md5s from JSON file using grep + sed
  grep -E '"url":|md5' "$JSON_FILE" | paste - - | while IFS=$'\t' read -r url_line md5_line; do
    url=$(echo "$url_line" | sed -E 's/.*"url": *"([^"]+)".*/\1/')
    expected_md5=$(echo "$md5_line" | sed -E 's/.*"md5": *"([^"]+)".*/\1/')
    filename=$(basename "$url")

    echo "📥 Downloading $filename..."

    # Attempt download up to 3 times
    for attempt in {1..3}; do
        curl --progress-bar -C - -O "$url" && break
        echo "⚠️ Attempt $attempt failed for $filename"
        sleep 2
    done

    if [[ ! -f "$filename" ]]; then
        echo "❌ Failed to download $filename after 3 attempts" | tee -a "$ERROR_LOG"
        continue
    fi

    echo "🔍 Verifying MD5 for $filename..."
    actual_md5=$(md5sum "$filename" | awk '{print $1}')

    if [[ "$actual_md5" != "$expected_md5" ]]; then
        echo "❌ MD5 mismatch for $filename: expected $expected_md5 but got $actual_md5" | tee -a "$ERROR_LOG"
    else
        echo "✅ MD5 verified for $filename"
    fi

  done

  echo "✅ All downloads attempted for $ACCESSION"
  if [[ -s "$ERROR_LOG" ]]; then
      echo "⚠️ Some errors were logged in $ERROR_LOG"
  fi

  cd - > /dev/null
done < "$ACCESSION_FILE"
