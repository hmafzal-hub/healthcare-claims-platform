{{ config(
    materialized='table',
    schema='observability'
) }}

WITH raw_claims AS (

    SELECT
        COUNT(*) AS raw_claim_count
    FROM {{ source('raw', 'FACT_CLAIMS') }}

),

summary_claims AS (

    SELECT
        SUM(total_claims) AS summary_claim_count
    FROM {{ ref('int_claim_summary') }}

)

SELECT
    raw_claim_count,
    summary_claim_count,
    raw_claim_count - summary_claim_count AS difference,
    CASE
        WHEN raw_claim_count = summary_claim_count
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status,
    CURRENT_TIMESTAMP() AS checked_at
FROM raw_claims
CROSS JOIN summary_claims