from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from google.cloud import storage
from google.cloud import bigquery
from datetime import datetime
import pymysql
import pandas as pd
import os

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
        for table in get_tables():
            query = f"SELECT * FROM {table}"
            df = pd.read_sql(query, conn)
            df.to_csv(f"/tmp/{table}.csv", index=False)
            print(f"Extracted {table}")
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

    transform_sales = BigQueryInsertJobOperator(
        task_id="transform_sales",
        configuration={
            "query": {
                "query": """
                CREATE OR REPLACE VIEW `mm-bigdata-2026-data-mesh.sales_ds.clean_payments` AS
                SELECT
                    p.payment_id,
                    p.customer_id,
                    p.staff_id,
                    p.amount,
                    r.inventory_id,
                    r.rental_rate,
                    r.rental_date,
                    r.return_date,
                    p.payment_date,
                    CASE 
                        WHEN p.payment_date > r.return_date THEN TRUE
                        ELSE FALSE
                    END AS is_delayed
                FROM `mm-bigdata-2026-data-mesh.wheelie_data.payment` p
                JOIN `mm-bigdata-2026-data-mesh.wheelie_data.rental` r
                ON p.rental_id = r.rental_id;
                """,
                "useLegacySql": False,
            }
        },
    )

    t1 >> t2 >> t3 >> transform_sales