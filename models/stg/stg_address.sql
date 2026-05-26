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
        cast(address_id as string) as address_id,

        -- clean address (STRUCT → STRING)
        trim(address.address) as address,

        -- postal code cleanup
        upper(trim(postal_code)) as postal_code,

        -- FK (IMPORTANT: type consistency)
        cast(city_id as string) as city_id,

        -- timestamp
        cast(last_update as timestamp) as last_update

    from source

)

select *
from cleaned