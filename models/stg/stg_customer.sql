{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('wheelie', 'customer') }}

),

cleaned as (

    select
        cast(customer_id as string) as customer_id,

        first_name,
        last_name,
        email,

        case
            when regexp_contains(
                lower(trim(replace(email, ' ', ''))),
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$'
            )
            then true
            else false
        end as is_valid_email,

        case
            when birth_date in ('0000-00-00', '') then null
            else safe_cast(birth_date as date)
        end as birth_date,

        safe_cast(create_date as timestamp) as create_date,
        safe_cast(last_update as timestamp) as last_update,

        cast(address_id as string) as address_id

    from source

)

select * from cleaned