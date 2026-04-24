with customer as (
    select *
    from {{ source('wheelie', 'customer') }}
),

address as (
    select *
    from {{ source('wheelie', 'address') }}
),

city as (
    select *
    from {{ source('wheelie', 'city') }}
),

country as (
    select *
    from {{ source('wheelie', 'country') }}
),

enriched as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.birth_date,
        c.create_date,
        c.last_update as customer_last_update,

        a.address,
        a.postal_code,

        ci.city,
        co.country

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