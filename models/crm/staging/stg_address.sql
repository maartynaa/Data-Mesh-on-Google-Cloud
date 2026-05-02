{{ config(materialized='view') }}

with source as (

    select
        address_id,
        address,
        postal_code,
        city_id,
        last_update
    from {{ source('wheelie', 'address') }}

),

cleaned as (

    select
        address_id,

        -- 🔹 clean address (basic normalization)
        trim(address) as address,

        -- 🔹 postal code cleanup (whitespace only)
        upper(trim(postal_code)) as postal_code,

        -- 🔹 FK
        city_id,

        -- 🔹 timestamp (for incremental logic downstream)
        cast(last_update as timestamp) as last_update

    from source

)

select *
from cleaned