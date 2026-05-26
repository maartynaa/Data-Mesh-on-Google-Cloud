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
        cast(city_id as string) as city_id,

        initcap(trim(city.city)) as city,

        cast(country_id as string) as country_id

    from source

)

select * from cleaned