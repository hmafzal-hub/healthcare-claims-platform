select

    provider_sk,
    provider_id,
    provider_name,
    updated_at

from {{ source('raw','DIM_PROVIDERS') }}