select

    patient_sk,
    patient_id,
    gender,
    birth_date,
    city,
    state

from {{ source('raw','DIM_PATIENT') }}