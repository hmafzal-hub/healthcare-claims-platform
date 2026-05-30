{{ config(
    materialized='table',
    schema='observability'
) }}

WITH raw_providers AS (

    SELECT COUNT(*) AS raw_provider_count
    FROM {{ source('raw', 'DIM_PROVIDERS') }}

),

stg_providers AS (

    SELECT COUNT(*) AS stg_provider_count
    FROM {{ ref('stg_dim_provider') }}

)

SELECT
    raw_provider_count,
    stg_provider_count,
    raw_provider_count - stg_provider_count AS difference,
    CASE
        WHEN raw_provider_count = stg_provider_count
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status,
    CURRENT_TIMESTAMP() AS checked_at
FROM raw_providers
CROSS JOIN stg_providers