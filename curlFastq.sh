#!/bin/bash

# Usage: sh curlFastq.sh accessions.txt

set -euo pipefail

ACCESSION_FILE="$1"
ERROR_LOG="../downloadSRA/errorLOG.txt"
touch $ERROR_LOG
NOHUP_LOG="../downloadSRA/nohupLOG.txt"

# Check that the input file exists
if [[ ! -f "$ACCESSION_FILE" ]]; then
    echo "❌ Error: input file $ACCESSION_FILE not found."
    exit 1
fi

while read -r ACCESSION; do
  JSON_FILE="${ACCESSION}.json"
  TARGET_DIR="../FastqFiles/${ACCESSION}"
  ERROR_LOG="../downloadSRA/errorLOG.txt"
 

  cd "$TARGET_DIR"

  echo "🔍 Parsing $JSON_FILE..."


  # Extract each JSON object block (between { and }) and process it
  awk '/{/{flag=1; obj=$0; next} /}/{obj=obj"\n"$0; flag=0; print obj; next} flag{obj=obj"\n"$0}' "$JSON_FILE" | while read -r block; do
      url=$(echo "$block" | grep '"url":' | sed -E 's/.*"url": *"([^"]+)".*/\1/')
      expected_md5=$(echo "$block" | grep '"md5":' | sed -E 's/.*"md5": *"([^"]+)".*/\1/')

      if [[ -z "$url" || -z "$expected_md5" ]]; then
          echo "⚠️ Skipping invalid entry in $JSON_FILE" | tee -a "$ERROR_LOG"
          continue
      fi

      filename=$(basename "$url")
	  echo "📥 Downloading $filename..." | tee -a "$NOHUP_LOG"
	  
      for attempt in {1..3}; do
          curl --progress-bar -C - -O "$url" && break
          echo "⚠️ Attempt $attempt failed for $filename" | tee -a "$NOHUP_LOG"
          sleep 2
      done

      if [[ ! -f "$filename" ]]; then
          echo "❌ Failed to download $filename after 3 attempts" | tee -a "$ERROR_LOG"
          continue
      fi

      echo "🔍 Verifying MD5 for $filename..." | tee -a "$NOHUP_LOG"
      actual_md5=$(md5sum "$filename" | awk '{print $1}')

      if [[ "$actual_md5" != "$expected_md5" ]]; then
          echo "❌ MD5 mismatch for $filename: expected $expected_md5 but got $actual_md5" | tee -a "$ERROR_LOG"
      else
          echo "✅ MD5 verified for $filename" | tee -a "$NOHUP_LOG"
      fi
  done

  echo "✅ All downloads attempted for $ACCESSION" | tee -a "$NOHUP_LOG"
  if [[ -s "$ERROR_LOG" ]]; then
      echo "⚠️ Some errors were logged in $ERROR_LOG" | tee -a "$NOHUP_LOG"
  fi

  cd - > /dev/null
done < "$ACCESSION_FILE"
