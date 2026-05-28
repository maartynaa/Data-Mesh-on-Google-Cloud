from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="dbt_daily_refresh",
    default_args=default_args,
    start_date=datetime(2025, 1, 1),
    schedule="0 2 * * *",
    catchup=False,
) as dag:

    dbt_run = BashOperator(
        task_id="dbt_run_full_refresh",
        bash_command="cd /opt/dbt && dbt run --full-refresh"
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command="cd /opt/dbt && dbt test"
    )

    dbt_run >> dbt_test
