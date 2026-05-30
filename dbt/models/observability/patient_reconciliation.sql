{{ config(
    materialized='table',
    schema='observability'
) }}

WITH raw_patients AS (

    SELECT COUNT(*) AS raw_patient_count
    FROM {{ source('raw', 'DIM_PATIENT') }}

),

stg_patients AS (

    SELECT COUNT(*) AS stg_patient_count
    FROM {{ ref('stg_dim_patient') }}

)

SELECT
    raw_patient_count,
    stg_patient_count,
    raw_patient_count - stg_patient_count AS difference,
    CASE
        WHEN raw_patient_count = stg_patient_count
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status,
    CURRENT_TIMESTAMP() AS checked_at
FROM raw_patients
CROSS JOIN stg_patients