select

claim_id,
patient_sk,
provider_sk,
date_sk,
claim_amount,
claim_status,
claim_type,
updated_at

from {{ source(
'raw',
'FACT_CLAIMS'
) }}