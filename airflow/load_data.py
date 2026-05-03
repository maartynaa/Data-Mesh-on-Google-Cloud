from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from google.cloud import storage
from google.cloud import bigquery
from datetime import datetime
import pymysql
import pandas as pd
import os
import csv

GCP_PROJECT = os.getenv("GCP_PROJECT_ID")

def get_tables():
    return [
        'address',
        'customer',
        'car',
        'city',
        'country',
        'equipment',
        'inventory_equipment',
        'inventory',
        'payment',
        'rental',
        'service',
        'staff',
        'store',
    ]

def extract():
    conn = pymysql.connect(
        host="80.211.209.74",
        port=3306,
        user="bigdata",
        password="kimball99",
        database="wheelie",
        cursorclass=pymysql.cursors.DictCursor
    )

    try:
        cursor = conn.cursor()

        for table in get_tables():
            cursor.execute(f"SELECT * FROM {table}")
            rows = cursor.fetchall()

            print(f"{table}: {len(rows)} rows")

            if not rows:
                continue

            # nagłówki z kluczy słownika
            headers = rows[0].keys()

            with open(f"/tmp/{table}.csv", "w", newline="", encoding="utf-8") as f:
                writer = csv.DictWriter(f, fieldnames=headers)
                writer.writeheader()
                writer.writerows(rows)

    finally:
        conn.close()

def load_to_gcs():
    client = storage.Client()
    bucket = client.bucket(f"{GCP_PROJECT}-wheelie")

    for table in get_tables():
        blob = bucket.blob(f'raw/{table}.csv')
        blob.upload_from_filename(f'/tmp/{table}.csv')

def load_to_bq():
    client = bigquery.Client()
    dataset_id = f"{GCP_PROJECT}.wheelie_data"

    for table in get_tables():
        table_id = f"{dataset_id}.{table}"

        uri = f"gs://{GCP_PROJECT}-wheelie/raw/{table}.csv"

        job_config = bigquery.LoadJobConfig(
            source_format=bigquery.SourceFormat.CSV,
            skip_leading_rows=1,
            autodetect=True,
            write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE
        )

        load_job = client.load_table_from_uri(
            uri,
            table_id,
            job_config=job_config,
        )

        load_job.result()

        print(f"Loaded {table} into BigQuery")
    

with DAG(
    dag_id="data_mesh_pipeline",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False
) as dag:

    t1 = PythonOperator(
        task_id="extract",
        python_callable=extract
    )

    t2 = PythonOperator(
        task_id="load_to_gcs",
        python_callable=load_to_gcs
    )

    t3 = PythonOperator(
        task_id="load_to_bq",
        python_callable=load_to_bq
    )

    t1 >> t2 >> t3