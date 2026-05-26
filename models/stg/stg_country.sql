{{ config(materialized='view') }}

with source as (

    select
        country_id,
        country
    from {{ source('wheelie', 'country') }}

),

cleaned as (

    select
        cast(country_id as string) as country_id,

        initcap(trim(country.country)) as country

    from source

)

select * from cleaned