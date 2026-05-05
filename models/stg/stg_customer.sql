{{ config(materialized='view') }}

with source as (

    select
        customer_id,
        first_name,
        last_name,
        email,
        birth_date,
        create_date,
        last_update,
        address_id
    from {{ source('wheelie', 'customer') }}

),

cleaned as (

    select
        customer_id,

        -- 🔹 names cleaning
        initcap(trim(
            regexp_replace(first_name, r'(?i)\b(dr|prof|mgr|phd)\.?\s*', '')
        )) as first_name,

        initcap(trim(
            regexp_replace(last_name, r'(?i)\b(dr|prof|mgr|phd)\.?\s*', '')
        )) as last_name,

        -- 🔹 email cleaning (single source of truth)
        lower(trim(replace(email, ' ', ''))) as email,

        -- 🔹 validation
        case
            when regexp_contains(lower(trim(replace(email, ' ', ''))),
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
            then true
            else false
        end as is_valid_email,

        -- 🔹 dates
        case
            when birth_date in ('0000-00-00') then null
            else cast(birth_date as date)
        end as birth_date,

        cast(create_date as timestamp) as create_date,
        cast(last_update as timestamp) as last_update,

        address_id

    from source

)

select *
from cleaned