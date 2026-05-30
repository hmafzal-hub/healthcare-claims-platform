{{
config(
    materialized='incremental',
    unique_key='patient_sk'
)
}}

with source_data as (

    select
        patient_sk,
        claim_amount,
        updated_at

    from {{ ref('stg_fact_claims') }}

    {% if is_incremental() %}

    where updated_at >

    (
        select coalesce(
            max(updated_at),
            '1900-01-01'
        )

        from {{ this }}
    )

    {% endif %}

)

select

    patient_sk,
    sum(claim_amount) as total_claims,
    max(updated_at) as updated_at

from source_data

group by patient_sk