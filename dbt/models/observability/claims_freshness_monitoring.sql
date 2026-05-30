{{ config(
    materialized='table',
    schema='observability'
) }}

WITH table_freshness AS (

    SELECT
        table_catalog,
        table_schema,
        table_name,
        last_altered AS latest_table_update,
        DATEDIFF('hour', last_altered, CURRENT_TIMESTAMP()) AS hours_since_table_update
    FROM HEALTHCARE_DEV.INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'RAW'
      AND table_name = 'FACT_CLAIMS'

)

SELECT
    table_catalog,
    table_schema,
    table_name,
    latest_table_update,
    hours_since_table_update,
    CASE
        WHEN hours_since_table_update <= 168
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status,
    CURRENT_TIMESTAMP() AS checked_at
FROM table_freshness