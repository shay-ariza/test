#!/bin/bash
set -euo pipefail

VIDEO_FILE=$(find "$ATTACHMENTS_PATH" -type f \( -name "*.mov" -o -name "*.mp4" \) | head -1)
if [ -z "$VIDEO_FILE" ]; then
  echo "No video file found in $ATTACHMENTS_PATH"
  exit 1
fi

FILE_NAME=$(basename "$VIDEO_FILE")
echo "Sending as JSON: $VIDEO_FILE"

base64 -w 0 "$VIDEO_FILE" > /tmp/video_b64.txt

jq -n \
  --rawfile file         /tmp/video_b64.txt \
  --arg fileName         "$FILE_NAME" \
  --arg componentName    "$COMPONENT_NAME" \
  --arg shortDescription "$SHORT_DESCRIPTION" \
  --arg description      "$PR_BODY" \
  --arg group            "$GROUP" \
  '{
    file:                $file,
    fileName:            $fileName,
    componentName:       $componentName,
    "short-description": $shortDescription,
    description:         $description,
    group:               $group
  }' > /tmp/payload.json

curl -X POST \
  -H "Content-Type: application/json" \
  -d @/tmp/payload.json \
  "$POWER_AUTOMATE_URL"
