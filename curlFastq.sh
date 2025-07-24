#!/bin/bash

# Usage: ./download_fastqs.sh SRR8269810

set -euo pipefail

ACCESSION="$1"
JSON_FILE="../../${ACCESSION}.json"
TARGET_DIR="../FastqFiles/${ACCESSION}"
ERROR_LOG="download_errors.log"

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# Check that the JSON file exists
if [[ ! -f "${JSON_FILE}" ]]; then
    echo "Error: JSON file ${JSON_FILE} not found."
    exit 1
fi

# Clear previous error log
> "$ERROR_LOG"

# Loop through each file object in the JSON
jq -c '.[]' "$JSON_FILE" | while read -r file_entry; do
    url=$(echo "$file_entry" | jq -r '.url')
    expected_md5=$(echo "$file_entry" | jq -r '.md5')
    filename=$(basename "$url")

    echo "📥 Downloading $filename..."

    # Try downloading with 3 attempts
    for attempt in {1..3}; do
        curl --progress-bar -C - -O "$url" && break
        echo "⚠️ Attempt $attempt failed for $filename"
        sleep 2
    done

    if [[ ! -f "$filename" ]]; then
        echo "❌ Failed to download $filename after 3 attempts" | tee -a "$ERROR_LOG"
        continue
    fi

    # MD5 verification
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
    echo "⚠️ Some errors were logged in $TARGET_DIR/$ERROR_LOG"
fi
