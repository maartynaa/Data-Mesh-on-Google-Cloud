# Publikowanie kontraktów Data Mesh — instrukcja dla domen

Kontrakty produktów danych publikujemy przez usługę **Contract Publisher**.

Kontrakt to plik YAML opisujący produkt danych: właściciela, adres tabeli, ziarnistość, klucz główny, kolumny, źródła i konsumentów.

## 1. Skonfiguruj dostęp

Do walidacji, publikacji i podglądu katalogu używamy **konta serwisowego domeny**.

Aktualnie skonfigurowane konta:

```text
sales: getter@data-mesh-pk.iam.gserviceaccount.com
crm:   crm-sa@bw-bigdata-2026-data-mesh.iam.gserviceaccount.com
fleet: fleet-domain@pr-bigdata-2026-data-mesh.iam.gserviceaccount.com
admin: mm-data-mesh-admin@mm-bigdata-2026-data-mesh.iam.gserviceaccount.com
```

Ustaw adres usługi i konto serwisowe swojej domeny:

```bash
export CONTRACT_API_URL="https://contract-publisher-owjo6liqja-lm.a.run.app"
export CONTRACT_AUTO_GCLOUD_TOKEN=1
export DOMAIN_SA="<TWOJE_KONTO_SERWISOWE>"
```

Przykład dla domeny sales:

```bash
export CONTRACT_API_URL="https://contract-publisher-owjo6liqja-lm.a.run.app"
export CONTRACT_AUTO_GCLOUD_TOKEN=1
export DOMAIN_SA="getter@data-mesh-pk.iam.gserviceaccount.com"
```

Jeżeli uruchamiasz komendy lokalnie, ustaw impersonację konta serwisowego domeny:

```bash
gcloud config set auth/impersonate_service_account "$DOMAIN_SA"
```

Sprawdź, czy token da się wygenerować:

```bash
gcloud auth print-identity-token \
  --audiences="$CONTRACT_API_URL" \
  >/dev/null && echo "OK: token generated"
```

Jeżeli pojawia się błąd uprawnień przy generowaniu tokenu, to użytkownik lub pipeline nie ma prawa impersonacji danego konta serwisowego. Wtedy właściciel projektu, w którym znajduje się to konto serwisowe, musi nadać użytkownikowi/pipeline'owi rolę:

```text
roles/iam.serviceAccountTokenCreator
```

na tym koncie serwisowym.

To jest niezależne od uprawnień do samej usługi Contract Publisher.

## 2. Zobacz katalog produktów

Na początku warto zobaczyć, jakie produkty są już opublikowane.

Ponieważ usługa jest prywatna, do podglądu katalogu używamy lokalnego proxy. Proxy musi dostać token wygenerowany dla konta serwisowego domeny.

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
http://localhost:8080/
```

Na stronie można przeglądać produkty, filtrować je po domenie/właścicielu i rozwijać szczegóły kontraktu.

Jeżeli po jakimś czasie proxy zacznie zwracać `403`, zatrzymaj je (`Ctrl+C`), wygeneruj token ponownie i uruchom proxy jeszcze raz. Token może wygasnąć.

## 3. Przygotuj kontrakt

Kontrakty najlepiej trzymać w repozytorium domeny w katalogu:

```text
contracts/
```

Na przykład:

```text
contracts/dp_customer_profile.yml
contracts/dp_car_catalog.yml
contracts/dp_sales_by_customer_vehicle_segment.yml
```

Jeżeli macie już kontrakt lub opis produktu w innym formacie, najprościej poprosić ChatGPT o przeformatowanie go do wymaganego wzoru. Warto dorzucić do kontekstu także właściwy model dbt, którego dotyczy kontrakt — np. plik `.sql` z definicją modelu oraz, jeśli istnieje, obecny opis produktu. Dzięki temu ChatGPT może lepiej zrozumieć, jakie kolumny faktycznie występują w produkcie, jaka jest logika transformacji oraz jaki jest sens biznesowy tabeli.

Przykładowy prompt:

```text
Przeformatuj poniższy kontrakt/opis produktu danych do formatu YAML zgodnego z dbt schema.yml.

Dodatkowo załączam model dbt SQL, którego dotyczy ten kontrakt.
Wykorzystaj go jako kontekst do zrozumienia struktury produktu, kolumn, źródeł danych i logiki biznesowej.

Wymagane pola:
- version: 2
- models
- name
- description
- config.materialized
- config.contract.enforced
- meta.contract.id
- meta.contract.version
- meta.contract.domain
- meta.contract.owner
- meta.contract.address
- meta.contract.grain
- meta.contract.primary_key
- meta.contract.refresh
- meta.contract.consumers
- meta.contract.sources
- meta.contract.sla.freshness
- columns
- dla każdej kolumny: name, data_type, description

Minimalny przykład kontraktu:

models:
  - name: dp_example_product
    description: Krótki opis biznesowy produktu danych.

    config:
      materialized: table
      contract:
        enforced: true

    meta:
      contract:
        id: dp_example_product
        version: 1.0.0
        domain: example_domain
        owner: example-domain
        address: data-mesh-pk.example_products.dp_example_product
        grain: one row per something
        primary_key:
          - example_id
        refresh: daily
        consumers:
          - central_analytics
        sources:
          - source_table_or_product
        sla:
          freshness: daily

    columns:
      - name: example_id
        data_type: string
        description: Unique identifier.
        tests:
          - not_null
          - unique

Zachowaj sens biznesowy pól i nie wymyślaj danych, których nie ma.
Jeśli czegoś brakuje albo nie da się tego jednoznacznie wywnioskować z opisu lub modelu dbt, oznacz to jako TODO.

Poniżej wklejam:
1. obecny kontrakt/opis produktu danych,
2. model dbt SQL.
```

## 4. Minimalny przykład kontraktu

```yaml
version: 2

models:
  - name: dp_example_product
    description: Krótki opis biznesowy produktu danych.

    config:
      materialized: table
      contract:
        enforced: true

    meta:
      contract:
        id: dp_example_product
        version: 1.0.0
        domain: example_domain
        owner: example-domain
        address: data-mesh-pk.example_products.dp_example_product
        grain: one row per something
        primary_key:
          - example_id
        refresh: daily
        consumers:
          - central_analytics
        sources:
          - source_table_or_product
        sla:
          freshness: daily

    columns:
      - name: example_id
        data_type: string
        description: Unique identifier.
        tests:
          - not_null
          - unique
```

## 5. Co musi być w kontrakcie

Na poziomie produktu wymagane są:

```text
name
description
meta.contract.id
meta.contract.domain
meta.contract.owner
meta.contract.address
meta.contract.grain
meta.contract.primary_key
meta.contract.refresh
meta.contract.consumers
meta.contract.sources
meta.contract.sla.freshness
columns
```

Każda kolumna musi mieć:

```text
name
data_type
description
```

Zalecane nazewnictwo:

```text
produkty danych: dp_<nazwa_biznesowa>_<opcjonalny_kwalifikator>
kolumny: snake_case
```

Ważne: `primary_key` powinno być listą, nawet jeżeli klucz składa się tylko z jednej kolumny:

```yaml
primary_key:
  - customer_id
```

a nie:

```yaml
primary_key: customer_id
```

## 6. Zwaliduj kontrakt

Przed publikacją uruchom walidację:

```bash
./validate_contract.sh contracts/<plik_kontraktu>.yml
```

Przykład:

```bash
./validate_contract.sh contracts/dp_car_catalog.yml
```

Jeżeli kontrakt jest błędny, API zwróci listę problemów, np. brakujące `grain`, `address`, `primary_key` albo brak `data_type` przy kolumnie.

## 7. Opublikuj kontrakt

Po poprawnej walidacji opublikuj kontrakt:

```bash
./publish_contract.sh contracts/<plik_kontraktu>.yml
```

Przykład:

```bash
./publish_contract.sh contracts/dp_car_catalog.yml
```

Najwygodniej uruchomić walidację i publikację razem:

```bash
./validate_contract.sh contracts/my_product.yml && ./publish_contract.sh contracts/my_product.yml
```

Publikacja też uruchamia walidację. Jeśli kontrakt jest błędny, nie zostanie dodany do katalogu.

## 8. Pełna sekwencja testowa

Podmień tylko konto serwisowe i nazwę pliku kontraktu:

```bash
export CONTRACT_API_URL="https://contract-publisher-owjo6liqja-lm.a.run.app"
export CONTRACT_AUTO_GCLOUD_TOKEN=1
export DOMAIN_SA="<TWOJE_KONTO_SERWISOWE>"

gcloud config set auth/impersonate_service_account "$DOMAIN_SA"

./validate_contract.sh contracts/<plik_kontraktu>.yml
./publish_contract.sh contracts/<plik_kontraktu>.yml

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

Następnie otwórz:

```text
http://localhost:8080/
```

i sprawdź, czy produkt pojawił się w katalogu.

Po zakończeniu lokalnych testów można wyłączyć impersonację:

```bash
gcloud config unset auth/impersonate_service_account
```

## 9. Dostęp maszynowy do rejestru

Rejestr jest dostępny jako JSON:

```bash
curl -sS \
  -H "Authorization: Bearer $(gcloud auth print-identity-token --audiences=$CONTRACT_API_URL)" \
  "$CONTRACT_API_URL/registry/index.json"
```

Lista produktów przez API:

```bash
curl -sS \
  -H "Authorization: Bearer $(gcloud auth print-identity-token --audiences=$CONTRACT_API_URL)" \
  "$CONTRACT_API_URL/contracts"
```

Jeżeli nie używasz globalnej impersonacji przez `gcloud config set auth/impersonate_service_account`, możesz wygenerować token jawnie:

```bash
TOKEN="$(gcloud auth print-identity-token \
  --audiences="$CONTRACT_API_URL" \
  --impersonate-service-account="$DOMAIN_SA")"

curl -sS \
  -H "Authorization: Bearer $TOKEN" \
  "$CONTRACT_API_URL/contracts"
```

## 10. Co zrobić, jeśli coś nie działa

Jeżeli walidacja zwraca błędy, popraw kontrakt zgodnie z komunikatem.

Jeżeli pojawia się błąd przy generowaniu tokenu, prawdopodobnie nie masz prawa impersonacji konta serwisowego domeny. To jest kwestia uprawnień w projekcie, do którego należy dane konto serwisowe. Użytkownik lub pipeline musi mieć `roles/iam.serviceAccountTokenCreator` na tym koncie serwisowym.

Jeżeli token generuje się poprawnie, ale walidacja/publikacja zwraca `403`, konto serwisowe domeny prawdopodobnie nie ma `roles/run.invoker` na usłudze `contract-publisher` w projekcie `data-mesh-pk`.

Jeżeli `gcloud run services proxy` zwraca błąd przy uruchomieniu, konto serwisowe domeny prawdopodobnie nie ma `roles/run.viewer` w projekcie `data-mesh-pk`.

Jeżeli proxy uruchamia się, ale wejście na `http://localhost:8080/` zwraca `403`, upewnij się, że proxy zostało uruchomione z tokenem:

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

Jeżeli produkt się opublikował, ale nie widzisz go w katalogu, odśwież stronę:

```text
http://localhost:8080/
```
