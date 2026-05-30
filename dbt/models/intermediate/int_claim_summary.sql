{{ config(
    materialized = 'incremental',
    unique_key = 'patient_sk',
    incremental_strategy = 'merge'
) }}

with source_claims as (

    select
        claim_id,
        patient_sk,
        claim_amount,
        claim_status,
        claim_type,
        updated_at
    from {{ ref('stg_fact_claims') }}

    {% if is_incremental() %}
        where updated_at >= (
            select dateadd(day, -7, max(updated_at))
            from {{ this }}
        )
    {% endif %}

),

dedup_claims as (

    select *
    from source_claims
    qualify row_number() over (
        partition by claim_id
        order by updated_at desc
    ) = 1

),

claim_summary as (

    select
        patient_sk,
        count(distinct claim_id) as total_claims,
        sum(claim_amount) as total_claim_amount,
        count_if(claim_status = 'APPROVED') as approved_claims,
        count_if(claim_status = 'DENIED') as denied_claims,
        max(updated_at) as updated_at
    from dedup_claims
    group by patient_sk

)

select *
from claim_summary