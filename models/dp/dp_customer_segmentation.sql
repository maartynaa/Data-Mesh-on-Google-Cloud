{{ config(
    materialized='table',
    schema='crm_data_products',
    full_refresh=false
) }}

with sales as (
    select * 
    from {{ ref('stg_sales__customer_activity') }}
),

profile as (
    select * 
    from {{ ref('dp_customer_profile_secure') }}
)

select
    profile.customer_id,
    profile.age_segment,
    profile.city,
    profile.country,

    sales.rental_count,
    sales.total_paid_amount,
    sales.unpaid_rentals_count,

    case
        when sales.total_paid_amount > 1000 then 'high_value'
        when sales.unpaid_rentals_count > 2 then 'risky'
        else 'standard'
    end as segment

from profile
left join sales
    on profile.customer_id = sales.customer_id