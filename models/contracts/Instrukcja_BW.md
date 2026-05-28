# Publikowanie kontraktów Data Mesh — instrukcja dla domen

Kontrakty produktów danych publikujemy przez usługę **Contract Publisher**.

Kontrakt to plik YAML opisujący produkt danych: właściciela, adres tabeli, ziarnistość, klucz główny, kolumny, źródła i konsumentów.

---

# 1. Popraw skrypty `validate_contract.sh` i `publish_contract.sh`

W Cloud Shell samo:

```bash
gcloud config set auth/impersonate_service_account
```

nie gwarantuje, że token będzie generowany jako service account domeny. W praktyce `gcloud auth print-identity-token` potrafi zwracać token użytkownika (`gmail.com`), co powoduje:

```text
403 Forbidden
```

na prywatnym Cloud Run `contract-publisher`.

Dlatego oba skrypty muszą jawnie używać:

```bash
--impersonate-service-account
```

oraz mieć wpisany service account domeny.

## Finalna wersja `validate_contract.sh`

```bash
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

SERVICE_ACCOUNT="${CONTRACT_IMPERSONATE_SERVICE_ACCOUNT:-<TWOJ_SERVICE_ACCOUNT>}"

echo "Using SA: $SERVICE_ACCOUNT"

TOKEN="$(gcloud auth print-identity-token \
  --audiences="$API_URL" \
  --impersonate-service-account="$SERVICE_ACCOUNT")"

curl -sS -X POST "${API_URL%/}/contracts/validate" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@${CONTRACT_PATH};type=application/x-yaml"

echo
```

## Finalna wersja `publish_contract.sh`

```bash
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

SERVICE_ACCOUNT="${CONTRACT_IMPERSONATE_SERVICE_ACCOUNT:-<TWOJ_SERVICE_ACCOUNT>}"

echo "Using service account: $SERVICE_ACCOUNT"
echo "Target API: $API_URL"

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
```

## Przykładowe service accounty

```text
sales: getter@data-mesh-pk.iam.gserviceaccount.com
crm:   crm-sa@bw-bigdata-2026-data-mesh.iam.gserviceaccount.com
fleet: fleet-domain@pr-bigdata-2026-data-mesh.iam.gserviceaccount.com
admin: mm-data-mesh-admin@mm-bigdata-2026-data-mesh.iam.gserviceaccount.com
```

Każda domena musi wpisać swój service account w obu plikach.

---

# 2. Ustaw zmienne środowiskowe

```bash
export CONTRACT_API_URL="https://contract-publisher-owjo6liqja-lm.a.run.app"

export DOMAIN_SA="<TWOJ_SERVICE_ACCOUNT>"
```

Przykład dla CRM:

```bash
export CONTRACT_API_URL="https://contract-publisher-owjo6liqja-lm.a.run.app"

export DOMAIN_SA="crm-sa@bw-bigdata-2026-data-mesh.iam.gserviceaccount.com"
```

---

# 3. Nadaj prawa wykonywania skryptom

Jednorazowo:

```bash
chmod +x validate_contract.sh
chmod +x publish_contract.sh
```

---

# 4. Zweryfikuj możliwość generowania tokenu

```bash
gcloud auth print-identity-token \
  --audiences="$CONTRACT_API_URL" \
  --impersonate-service-account="$DOMAIN_SA"
```

Jeżeli pojawia się błąd uprawnień, użytkownik nie ma:

```text
roles/iam.serviceAccountTokenCreator
```

na danym service account.

---

# 5. Zwaliduj kontrakt

Przejdź do katalogu z kontraktami i uruchom:

```bash
./validate_contract.sh dp_customer_demographics.yaml
```

Poprawny wynik:

```json
"status":"valid"
"valid":true
```

---

# 6. Opublikuj kontrakt

Po poprawnej walidacji:

```bash
./publish_contract.sh dp_customer_demographics.yaml
```

Poprawny wynik:

```json
"status":"published"
```

---

# 7. Sprawdź listę opublikowanych produktów

```bash
curl -sS \
  -H "Authorization: Bearer $(gcloud auth print-identity-token --audiences=$CONTRACT_API_URL --impersonate-service-account=$DOMAIN_SA)" \
  "$CONTRACT_API_URL/contracts"
```

---

# 8. Podgląd katalogu produktów (UI)

Uruchom lokalne proxy:

```bash
TOKEN="$(gcloud auth print-identity-token \
  --audiences="$CONTRACT_API_URL" \
  --impersonate-service-account="$DOMAIN_SA")"

gcloud run services proxy contract-publisher \
  --project=data-mesh-pk \
  --region=europe-central2 \
  --port=8080 \
  --token="$TOKEN" \
  --impersonate-service-account="$DOMAIN_SA"
```

Następnie otwórz w przeglądarce:

```text
http://localhost:8080
```

Jeżeli po czasie pojawi się `403`, wygeneruj nowy token i uruchom proxy ponownie.

---

# 9. Najczęstsze problemy

## `403 Forbidden`

Najczęściej:

* token został wygenerowany jako użytkownik zamiast service account,
* albo service account nie ma:

  ```text
  roles/run.invoker
  ```

  na usłudze `contract-publisher`.

## `Permission denied`

Skrypt nie ma praw wykonywania:

```bash
chmod +x validate_contract.sh
chmod +x publish_contract.sh
```

## `curl: (26) Failed to open/read local data`

Błędna ścieżka albo nazwa pliku YAML.
