{% snapshot snap_provider %}

{{
    config(
        target_schema='STRUCTURED',
        unique_key='provider_sk',
        strategy='check',
        check_cols=[
            'provider_name',
            'city',
            'state'
        ]
    )
}}

select

    provider_sk,
    provider_id,
    provider_name,
    city,
    state,
    updated_at

from {{ source('raw','DIM_PROVIDERS') }}

{% endsnapshot %}