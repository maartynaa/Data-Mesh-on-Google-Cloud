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

API_URL="${CONTRACT_API_URL:-https://contract-publisher-owjo6liqja-lm.a.run.app}"

# zawsze jedno źródło prawdy
SERVICE_ACCOUNT="${CONTRACT_IMPERSONATE_SERVICE_ACCOUNT:-${DOMAIN_SA:-crm-sa@bw-bigdata-2026-data-mesh.iam.gserviceaccount.com}}"

echo "Using service account: $SERVICE_ACCOUNT"
echo "Target API: $API_URL"

# zawsze jawna impersonacja (brak fallbacków na user token)
TOKEN="$(gcloud auth print-identity-token \
  --audiences="$API_URL" \
  --impersonate-service-account="$SERVICE_ACCOUNT")"

if [[ -z "$TOKEN" ]]; then
  echo "ERROR: Failed to generate identity token" >&2
  exit 1
fi

curl -sS -X POST "${API_URL%/}/contracts/publish" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@${CONTRACT_PATH};type=application/x-yaml"

echo