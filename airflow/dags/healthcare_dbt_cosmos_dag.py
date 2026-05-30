from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

DBT_PROJECT_DIR = "/opt/airflow/dbt"
DBT_PROFILES_DIR = "/opt/airflow/dbt"
DBT_BIN = "/home/airflow/dbt_venv/bin/dbt"

default_args = {
    "owner": "data_engineering",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="healthcare_dbt_snowflake_pipeline",
    description="Orchestrates healthcare dbt models on Snowflake",
    default_args=default_args,
    start_date=datetime(2026, 5, 29),
    schedule_interval=None,
    catchup=False,
    tags=["healthcare", "dbt", "snowflake", "cosmos"],
) as dag:

    dbt_debug = BashOperator(
        task_id="dbt_debug",
        bash_command=f"""
        cd {DBT_PROJECT_DIR} &&
        {DBT_BIN} debug --profiles-dir {DBT_PROFILES_DIR}
        """,
    )

    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f"""
        cd {DBT_PROJECT_DIR} &&
        {DBT_BIN} deps --profiles-dir {DBT_PROFILES_DIR}
        """,
    )

    dbt_source_freshness = BashOperator(
        task_id="dbt_source_freshness",
        bash_command=f"""
        cd {DBT_PROJECT_DIR} &&
        {DBT_BIN} source freshness --profiles-dir {DBT_PROFILES_DIR}
        """,
    )

    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command=f"""
        cd {DBT_PROJECT_DIR} &&
        {DBT_BIN} build --profiles-dir {DBT_PROFILES_DIR}
        """,
    )

    dbt_snapshot = BashOperator(
        task_id="dbt_snapshot",
        bash_command=f"""
        cd {DBT_PROJECT_DIR} &&
        {DBT_BIN} snapshot --profiles-dir {DBT_PROFILES_DIR}
        """,
    )

    dbt_debug >> dbt_deps >> dbt_source_freshness >> dbt_build >> dbt_snapshot