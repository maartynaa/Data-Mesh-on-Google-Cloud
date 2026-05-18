from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
    dag_id="crm_test_dag",
    start_date=datetime(2025, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["crm", "test"],
) as dag:

    start = BashOperator(
        task_id="start",
        bash_command="echo 'Start CRM pipeline'"
    )

    check_storage = BashOperator(
        task_id="check_storage",
        bash_command="echo 'Ready for GCS / Storage Transfer integration'"
    )

    start >> check_storage