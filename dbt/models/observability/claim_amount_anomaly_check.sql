{{ config(
    materialized='table',
    schema='observability'
) }}

WITH checks AS (

    SELECT
        COUNT(*) AS total_claims,
        SUM(CASE WHEN claim_amount IS NULL THEN 1 ELSE 0 END) AS null_amount_claims,
        SUM(CASE WHEN claim_amount < 0 THEN 1 ELSE 0 END) AS negative_amount_claims,
        SUM(CASE WHEN claim_amount = 0 THEN 1 ELSE 0 END) AS zero_amount_claims,
        SUM(CASE WHEN claim_amount > 100000 THEN 1 ELSE 0 END) AS unusually_high_amount_claims
    FROM {{ source('raw', 'FACT_CLAIMS') }}

)

SELECT
    total_claims,
    null_amount_claims,
    negative_amount_claims,
    zero_amount_claims,
    unusually_high_amount_claims,
    CASE
        WHEN null_amount_claims = 0
         AND negative_amount_claims = 0
         AND unusually_high_amount_claims = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status,
    CURRENT_TIMESTAMP() AS checked_at
FROM checks