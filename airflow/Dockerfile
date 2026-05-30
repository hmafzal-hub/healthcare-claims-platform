# FROM apache/airflow:2.9.3

# USER airflow

# RUN pip install --no-cache-dir \
#     astronomer-cosmos==1.10.2

# RUN python -m virtualenv /home/airflow/dbt_venv && \
#     /home/airflow/dbt_venv/bin/pip install --no-cache-dir \
#     dbt-core==1.8.9 \
#     dbt-snowflake==1.8.4

FROM apache/airflow:2.9.3

USER root

RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean

USER airflow

RUN pip install --no-cache-dir \
    astronomer-cosmos==1.10.2

RUN python -m virtualenv /home/airflow/dbt_venv && \
    /home/airflow/dbt_venv/bin/pip install --no-cache-dir \
    dbt-core==1.8.9 \
    dbt-snowflake==1.8.4