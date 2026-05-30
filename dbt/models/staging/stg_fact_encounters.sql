select

    encounter_id,
    patient_sk,
    date_sk

from {{ source('raw','FACT_ENCOUNTERS') }}