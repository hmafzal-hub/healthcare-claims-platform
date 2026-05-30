{{ config(
    materialized='table',
    schema='observability'
) }}

WITH raw_claims AS (

    SELECT
        COUNT(*) AS raw_count,
        SUM(claim_amount) AS raw_amount
    FROM {{ source('raw', 'FACT_CLAIMS') }}

),

stg_claims AS (

    SELECT
        COUNT(*) AS stg_count,
        SUM(claim_amount) AS stg_amount
    FROM {{ ref('stg_fact_claims') }}

)

SELECT

    raw_count,
    stg_count,

    raw_amount,
    stg_amount,

    raw_count - stg_count AS count_difference,

    raw_amount - stg_amount AS amount_difference,

    CASE
        WHEN raw_count = stg_count
         AND ABS(raw_amount - stg_amount) < 0.01
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status,

    CURRENT_TIMESTAMP() AS checked_at

FROM raw_claims
CROSS JOIN stg_claims