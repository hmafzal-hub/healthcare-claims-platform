from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.empty import EmptyOperator

from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, ExecutionConfig, RenderConfig
from cosmos.constants import InvocationMode
from cosmos.config import TestBehavior
# from airflow.operators.python import PythonOperator

# def force_failure():
#     raise Exception("Testing Airflow email alert")


DBT_PROJECT_PATH = "/opt/airflow/dbt"
DBT_EXECUTABLE_PATH = "/home/airflow/dbt_venv/bin/dbt"
DBT_PROFILES_DIR = "/opt/airflow/dbt"

default_args = {
    "owner": "data_engineering",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "email": ["092afzal@gmail.com"],
    "email_on_failure": True,
    "email_on_retry": False,
}

with DAG(
    dag_id="healthcare_dbt_cosmos_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule="0 6 * * *",
    catchup=False,
    default_args=default_args,
    max_active_runs=1,
    tags=["healthcare", "dbt", "snowflake", "cosmos", "production"],
) as dag:

    start = EmptyOperator(task_id="start")

    dbt_project = DbtTaskGroup(
        group_id="dbt_healthcare_models",

        project_config=ProjectConfig(
            dbt_project_path=DBT_PROJECT_PATH,
        ),

        profile_config=ProfileConfig(
            profile_name="healthcare_claims",
            target_name="dev",
            profiles_yml_filepath=f"{DBT_PROFILES_DIR}/profiles.yml",
        ),

        execution_config=ExecutionConfig(
            dbt_executable_path=DBT_EXECUTABLE_PATH,
            invocation_mode=InvocationMode.SUBPROCESS,
        ),

        render_config=RenderConfig(
            test_behavior=TestBehavior.AFTER_EACH,
        ),

        operator_args={
            "install_deps": True,
        },
    )

    # email_test = PythonOperator(
    #     task_id="email_failure_test",
    #     python_callable=force_failure,
    # )

    end = EmptyOperator(task_id="end")

    start >> dbt_project >> end