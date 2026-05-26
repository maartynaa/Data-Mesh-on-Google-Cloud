# Publikowanie kontraktów Data Mesh — instrukcja dla domen

Kontrakty produktów danych publikujemy przez usługę **Contract Publisher**.

Kontrakt to plik YAML opisujący produkt danych: właściciela, adres tabeli, ziarnistość, klucz główny, kolumny, źródła i konsumentów.

## 1. Zobacz katalog produktów

Na początku warto zobaczyć, jakie produkty są już opublikowane.

Ponieważ usługa jest prywatna, uruchom lokalne proxy do Cloud Run:

```bash
gcloud run services proxy contract-publisher \
  --project=data-mesh-pk \
  --region=europe-central2 \
  --port=8080
```

Następnie otwórz w przeglądarce:

```text
http://localhost:8080/
```

Na stronie można przeglądać produkty, filtrować je po domenie/właścicielu i rozwijać szczegóły kontraktu.

## 2. Ustaw adres usługi

W terminalu ustaw adres API:

```bash
export CONTRACT_API_URL="https://contract-publisher-owjo6liqja-lm.a.run.app"
export CONTRACT_AUTO_GCLOUD_TOKEN=1
```


Adres powinien pozostać stały, o ile usługa `contract-publisher` nie zostanie usunięta albo przeniesiona do innego projektu/regionu.

## 3. Ustaw konto serwisowe domeny

Każda domena powinna publikować kontrakty ze swojego konta serwisowego.

Aktualnie skonfigurowane konta:

```text
sales: getter@data-mesh-pk.iam.gserviceaccount.com
crm:   crm-sa@bw-bigdata-2026-data-mesh.iam.gserviceaccount.com
fleet: fleet-domain@pr-bigdata-2026-data-mesh.iam.gserviceaccount.com
admin: mm-data-mesh-admin@mm-bigdata-2026-data-mesh.iam.gserviceaccount.com
```

Ustaw swoje konto, np.:

```bash
export DOMAIN_SA="<TWOJE_KONTO_SERWISOWE>"
```

Przykład dla sales:

```bash
export DOMAIN_SA="getter@data-mesh-pk.iam.gserviceaccount.com"
```

Jeżeli uruchamiasz komendy lokalnie, ustaw impersonację:

```bash
gcloud config set auth/impersonate_service_account "$DOMAIN_SA"
```

Sprawdź, czy token da się wygenerować:

```bash
gcloud auth print-identity-token \
  --audiences="$CONTRACT_API_URL" \
  >/dev/null && echo "OK: token generated"
```

Jeżeli pojawia się błąd uprawnień, prawdopodobnie Twoje konto użytkownika nie ma prawa impersonacji danego service accounta. Wtedy trzeba poprosić właściciela projektu (siebie xd) o nadanie `roles/iam.serviceAccountTokenCreator` na tym koncie serwisowym.

Po zakończeniu lokalnych testów można wyłączyć impersonację:

```bash
gcloud config unset auth/impersonate_service_account
```

## 4. Przygotuj kontrakt

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

Jeżeli macie już kontrakt lub opis produktu w innym formacie, najprościej poprosić ChatGPT o przeformatowanie go do wymaganego wzoru. Warto jednak dorzucić do kontekstu także właściwy model dbt, którego dotyczy kontrakt — np. plik .sql z definicją modelu oraz, jeśli istnieje, obecny opis produktu. Dzięki temu ChatGPT może lepiej zrozumieć, jakie kolumny faktycznie występują w produkcie, jaka jest logika transformacji oraz jaki jest sens biznesowy tabeli.

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

## 5. Minimalny przykład kontraktu

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

## 6. Co musi być w kontrakcie

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

## 7. Zwaliduj kontrakt

Przed publikacją uruchom walidację:

```bash
./validate_contract.sh contracts/<plik_kontraktu>.yml
```

Przykład:

```bash
./validate_contract.sh contracts/dp_car_catalog.yml
```

Jeżeli kontrakt jest błędny, API zwróci listę problemów, np. brakujące `grain`, `address`, `primary_key` albo brak `data_type` przy kolumnie.

## 8. Opublikuj kontrakt

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

## 9. Pełna sekwencja testowa

Podmień tylko wartości w nawiasach ostrych:

```bash
export CONTRACT_API_URL="<CLOUD_RUN_URL>"
export CONTRACT_AUTO_GCLOUD_TOKEN=1
export DOMAIN_SA="<TWOJE_KONTO_SERWISOWE>"

gcloud config set auth/impersonate_service_account "$DOMAIN_SA"

./validate_contract.sh contracts/<plik_kontraktu>.yml
./publish_contract.sh contracts/<plik_kontraktu>.yml

gcloud run services proxy contract-publisher \
  --project=data-mesh-pk \
  --region=europe-central2 \
  --port=8080
```

Następnie otwórz:

```text
http://localhost:8080/
```

i sprawdź, czy produkt pojawił się w katalogu.

Po zakończeniu lokalnych testów:

```bash
gcloud config unset auth/impersonate_service_account
```

## 10. Dostęp maszynowy do rejestru

Rejestr jest dostępny też jako JSON:

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

## 11. Co zrobić, jeśli coś nie działa

Jeżeli walidacja zwraca błędy, popraw kontrakt zgodnie z komunikatem.

Jeżeli pojawia się błąd uprawnień przy generowaniu tokenu, prawdopodobnie nie masz prawa impersonacji konta serwisowego domeny.

Jeżeli pojawia się błąd `403` przy wywołaniu API, konto serwisowe domeny prawdopodobnie nie ma uprawnienia `Cloud Run Invoker` do usługi `contract-publisher`.

Jeżeli produkt się opublikował, ale nie widzisz go w katalogu, odśwież stronę:

```text
http://localhost:8080/
```
