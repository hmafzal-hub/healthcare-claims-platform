from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator


default_args = {
    "owner": "data_engineering",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
    "email": ["092afzal@gmail.com"],
    "email_on_failure": True,
    "email_on_retry": False,
}


with DAG(
    dag_id="healthcare_dbt_docs",
    start_date=datetime(2026, 1, 1),
    schedule="0 7 * * *",
    catchup=False,
    default_args=default_args,
    max_active_runs=1,
    tags=["healthcare", "dbt", "docs", "metadata"],
) as dag:

    dbt_docs_generate = BashOperator(
        task_id="dbt_docs_generate",
        bash_command="""
        cd /opt/airflow/dbt &&
        /home/airflow/dbt_venv/bin/dbt docs generate --profiles-dir /opt/airflow/dbt
        """,
    )