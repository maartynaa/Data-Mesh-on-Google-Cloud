{{ config(materialized='view') }}
with source as (

    select
        country_id,
        country
    from {{ source('wheelie', 'country') }}

),

cleaned as (

    select
        country_id,

        -- normalization only
        initcap(trim(country.country)) as country

    from source

)

select *
from cleaned