#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <contract_path>" >&2
  exit 2
fi

CONTRACT_PATH="$1"
if [[ ! -f "$CONTRACT_PATH" ]]; then
  echo "Contract file not found: $CONTRACT_PATH" >&2
  exit 2
fi

API_URL="${CONTRACT_API_URL:-http://localhost:8080}"

if [[ -n "${CONTRACT_IMPERSONATE_SERVICE_ACCOUNT:-}" ]]; then
  TOKEN="$(gcloud auth print-identity-token \
    --audiences="$CONTRACT_API_URL" \
    --impersonate-service-account="$CONTRACT_IMPERSONATE_SERVICE_ACCOUNT")"
else
  TOKEN="$(gcloud auth print-identity-token \
    --audiences="$CONTRACT_API_URL")"
fi

AUTO_GCLOUD_TOKEN="${CONTRACT_AUTO_GCLOUD_TOKEN:-0}"

if [[ -z "$TOKEN" && "$AUTO_GCLOUD_TOKEN" == "1" ]]; then
  TOKEN="$(gcloud auth print-identity-token --audiences="$API_URL")"
fi

if [[ -n "$TOKEN" ]]; then
  curl -sS -X POST "${API_URL%/}/contracts/publish" \
    -H "Authorization: Bearer ${TOKEN}" \
    -F "file=@${CONTRACT_PATH};type=application/x-yaml"
else
  curl -sS -X POST "${API_URL%/}/contracts/publish" \
    -F "file=@${CONTRACT_PATH};type=application/x-yaml"
fi

echo
