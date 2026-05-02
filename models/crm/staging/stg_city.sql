{{ config(materialized='view') }}

with source as (

    select
        city_id,
        city,
        country_id
    from {{ source('wheelie', 'city') }}

),

cleaned as (

    select
        city_id,

        -- 🔹 normalization only
        initcap(trim(city)) as city,

        -- 🔹 FK
        country_id

    from source

)

select *
from cleaned