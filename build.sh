#!/usr/bin/env bash
# build.sh — Copy pipeline.json from partnerships-agent, strip private fields, publish
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="${HOME}/clawd/partnerships-agent/pipeline.json"
DEST="${SCRIPT_DIR}/pipeline.json"

# Private fields to strip from each deal (contact info, thread IDs, internal notes)
PRIVATE_FIELDS='.contactEmail, .contactName, .contactPhone, .threadId, .internalNotes, .notes, .privateNotes, .emailThread, .slackThread, .telegramThread, .discordThread'

if [ ! -f "$SOURCE" ]; then
  echo "⚠ Source not found: $SOURCE"
  echo "  Using existing pipeline.json as-is."
  exit 0
fi

echo "📋 Copying pipeline from: $SOURCE"

# Strip private fields from each deal, preserve everything else
# Also adds a buildTimestamp to track when the public version was generated
if command -v jq &>/dev/null; then
  jq "{
    deals: [.deals[]? | del(${PRIVATE_FIELDS})],
    metrics: .metrics,
    lastUpdated: .lastUpdated,
    buildTimestamp: \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
  }" "$SOURCE" > "$DEST"
  echo "✅ Pipeline published ($(jq '.deals | length' "$DEST") deals, private fields stripped)"
else
  echo "⚠ jq not found — copying raw file (private fields NOT stripped!)"
  echo "  Install jq: brew install jq"
  cp "$SOURCE" "$DEST"
fi

echo "📁 Output: $DEST"
echo "🕐 Build time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
