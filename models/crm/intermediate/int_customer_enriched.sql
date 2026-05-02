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
        c.customer_id,

        -- 🔹 customer base
        c.first_name,
        c.last_name,
        c.email,
        c.is_valid_email,
        c.birth_date,
        c.create_date,
        c.last_update as customer_last_update,
        c.address_id,

        -- 🔹 address
        a.address,
        a.postal_code,

        -- 🔹 geo
        ci.city,
        co.country,

        -- 🔥 business-neutral derived field (OK w intermediate)
        case
            when c.birth_date is null then null
            else date_diff(current_date(), c.birth_date, year)
        end as age

    from customer c
    left join address a
        on c.address_id = a.address_id
    left join city ci
        on a.city_id = ci.city_id
    left join country co
        on ci.country_id = co.country_id
)

select *
from enriched