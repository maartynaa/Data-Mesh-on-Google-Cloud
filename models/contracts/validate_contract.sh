#!/usr/bin/env bash
set -euo pipefail

CONTRACT_PATH="$1"

API_URL="${CONTRACT_API_URL:-https://contract-publisher-owjo6liqja-lm.a.run.app}"
SA="${CONTRACT_IMPERSONATE_SERVICE_ACCOUNT:-crm-sa@bw-bigdata-2026-data-mesh.iam.gserviceaccount.com}"

echo "Using SA: $SA"

TOKEN="$(gcloud auth print-identity-token \
  --audiences="$API_URL" \
  --impersonate-service-account="$SA")"

curl -sS -X POST "${API_URL}/contracts/validate" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@${CONTRACT_PATH};type=application/x-yaml"

echo