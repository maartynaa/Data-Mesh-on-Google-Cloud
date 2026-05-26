{{ config(materialized='view') }}

with customer as (
    select *
    from {{ ref('stg_customer') }}
),

address as (
    select *
    from {{ ref('stg_address') }}
),

city as (
    select *
    from {{ ref('stg_city') }}
),

country as (
    select *
    from {{ ref('stg_country') }}
),

enriched as (

    select
        cast(c.customer_id as string) as customer_id,

        -- customer base
        c.first_name,
        c.last_name,
        c.email,
        c.is_valid_email,
        c.birth_date,
        c.create_date,
        c.last_update as customer_last_update,

        cast(c.address_id as string) as address_id,

        -- address
        a.address,
        a.postal_code,

        cast(a.city_id as string) as city_id,

        -- geo
        ci.city,
        co.country,

        -- derived
        case
            when c.birth_date is null then null
            else date_diff(current_date(), c.birth_date, year)
        end as age

    from customer c

    left join address a
        on cast(c.address_id as string) = cast(a.address_id as string)

    left join city ci
        on cast(a.city_id as string) = cast(ci.city_id as string)

    left join country co
        on cast(ci.country_id as string) = cast(co.country_id as string)
)

select *
from enriched