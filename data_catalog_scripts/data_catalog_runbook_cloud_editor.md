# Data Catalog Runbook (Google Cloud Editor)

## 1. Wejście do repozytorium
```bash
cd ~/Data-Mesh-on-Google-Cloud/data_catalog_scripts
```

---

## 2. Zmienne środowiskowe
Ustaw w KAŻDEJ nowej sesji terminala (chyba że dodasz do `.bashrc`).

```bash
export CONTRACT_API_URL="https://contract-publisher-owjo6liqja-lm.a.run.app"
export CONTRACT_AUTO_GCLOUD_TOKEN=1
export DOMAIN_SA="crm-sa@bw-bigdata-2026-data-mesh.iam.gserviceaccount.com"
```

---

## 3. Impersonacja service account
Wymagana do publikacji kontraktów.

```bash
gcloud config set auth/impersonate_service_account "$DOMAIN_SA"
```

---

## 4. Test tokenu (opcjonalnie)
Sprawdza czy impersonacja działa.

```bash
gcloud auth print-identity-token --audiences="$CONTRACT_API_URL"
```

Jeśli zwraca token JWT → OK.

---

## 5. Walidacja kontraktu
```bash
./validate_contract.sh contracts/<plik>.yml
```

---

## 6. Publikacja kontraktu
```bash
./publish_contract.sh contracts/<plik>.yml
```

---

## 7. Podgląd katalogu (Cloud Run)
```bash
gcloud run services proxy contract-publisher \
  --project=data-mesh-pk \
  --region=europe-central2 \
  --port=8080
```

Następnie:

http://localhost:8080/

---

## 8. Czy trzeba zawsze ustawiać zmienne?

### TAK, jeśli:
- otwierasz nowy terminal
- restartujesz Cloud Editor

### NIE, jeśli:
- pracujesz w tej samej sesji terminala

---

## 9. (Opcjonalnie) automatyzacja
Dodaj do `~/.bashrc`:

```bash
export CONTRACT_API_URL="https://contract-publisher-owjo6liqja-lm.a.run.app"
export CONTRACT_AUTO_GCLOUD_TOKEN=1
export DOMAIN_SA="crm-sa@bw-bigdata-2026-data-mesh.iam.gserviceaccount.com"
gcloud config set auth/impersonate_service_account "$DOMAIN_SA"
```

Aktywacja:

```bash
source ~/.bashrc
```

---

## 10. Minimalny daily flow
```bash
source ~/.bashrc

./validate_contract.sh contracts/<plik>.yml && ./publish_contract.sh contracts/<plik>.yml

gcloud run services proxy contract-publisher --project=data-mesh-pk --region=europe-central2 --port=8080
```

