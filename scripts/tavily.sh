#!/usr/bin/env bash
# Research wrapper. All market research goes through the Tavily Search API.
# Usage: bash scripts/tavily.sh "<query>"
# Exits with code 3 if TAVILY_API_KEY is unset so callers can fall back.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

query="${1:-}"
if [[ -z "$query" ]]; then
  echo "usage: bash scripts/tavily.sh \"<query>\"" >&2
  exit 1
fi

if [[ -z "${TAVILY_API_KEY:-}" ]]; then
  echo "WARNING: TAVILY_API_KEY not set. Fall back to WebSearch." >&2
  exit 3
fi

# search_depth: "basic" (1 credit/query, fast) or "advanced" (2 credits, deeper)
DEPTH="${TAVILY_SEARCH_DEPTH:-basic}"

payload="$(python3 -c "
import json, sys
print(json.dumps({
  'query': sys.argv[1],
  'search_depth': sys.argv[2],
  'max_results': 5,
  'include_answer': True,
  'include_raw_content': False,
}))
" "$query" "$DEPTH")"

curl -fsS https://api.tavily.com/search \
  -H "Authorization: Bearer $TAVILY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$payload"

echo
