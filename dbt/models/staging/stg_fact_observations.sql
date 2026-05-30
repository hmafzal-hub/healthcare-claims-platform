select

    observation_id,
    patient_sk,
    date_sk

from {{ source('raw','FACT_OBSERVATIONS') }}