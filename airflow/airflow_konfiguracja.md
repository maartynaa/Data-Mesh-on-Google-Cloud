# Konfiguracja Apache Airflow — podsumowanie

## Architektura

```
Google Cloud Platform
│
├── Cloud Shell
│   └── ~/Data-Mesh-on-Google-Cloud/airflow/dags/
│       └── crm_test_dag.py        ← tu piszesz i edytujesz DAGi
│
└── VM: airflow-dbt-vm (europe-central2-a, e2-standard-2)
    ├── ~/airflow/
    │   └── docker-compose.yml     ← konfiguracja Dockera
    └── ~/Data-Mesh-on-Google-Cloud/airflow/dags/
        └── crm_test_dag.py        ← stąd Airflow czyta DAGi
```

**Airflow działa w kontenerze Docker** na maszynie wirtualnej `airflow-dbt-vm` w Google Cloud.
Kontener montuje folder z DAGami z VM i udostępnia interfejs webowy na porcie 8080.
Autoryzacja do GCP odbywa się automatycznie przez Service Account `crm-sa`.

---

## DAG: dbt_daily_refresh

| Parametr | Wartość |
|---|---|
| ID | `dbt_daily_refresh` |
| Harmonogram | codziennie o 02:00 UTC |
| Executor | SequentialExecutor |

DAG wykonuje dwa zadania po kolei:

1. **dbt_run_full_refresh** — uruchamia `dbt run --full-refresh` w katalogu `/opt/dbt`
2. **dbt_test** — uruchamia `dbt test` żeby zweryfikować jakość danych

---

## Dostęp do Airflow UI

Adres: **http://34.116.205.225:8080**

Login i hasło znajdziesz komendą (na VM):
```bash
docker-compose logs | grep -i password
```

---

## Codzienne użytkowanie

### Uruchomienie Airflow (po restarcie VM)
```bash
cd ~/airflow
docker-compose up -d
```

### Zatrzymanie Airflow
```bash
cd ~/airflow
docker-compose down
```

### Sprawdzenie statusu
```bash
docker-compose ps
```

### Podgląd logów
```bash
docker-compose logs -f
```

### Ręczne uruchomienie DAGa (trigger)
```bash
docker exec airflow_airflow_1 airflow dags trigger dbt_daily_refresh
```

---

## Aktualizacja DAGów

Pliki DAGów edytujesz na **Cloud Shell**, a następnie kopiujesz na VM:

```bash
# Uruchom z Cloud Shell
gcloud compute scp /home/u4074520956/Data-Mesh-on-Google-Cloud/airflow/dags/crm_test_dag.py \
  airflow-dbt-vm:/home/u4074520956/Data-Mesh-on-Google-Cloud/airflow/dags/ \
  --zone=europe-central2-a
```

Airflow automatycznie wykryje zmiany w ciągu ~30 sekund.

---

## Przydatne informacje

| Element | Wartość |
|---|---|
| VM | airflow-dbt-vm |
| Zona | europe-central2-a |
| Projekt | bw-bigdata-2026-data-mesh |
| Service Account | crm-sa@bw-bigdata-2026-data-mesh.iam.gserviceaccount.com |
| Obraz Dockera | apache/airflow:2.8.1 |
| Port | 8080 |
