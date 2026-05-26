{{ config(
    materialized='table',
    schema='crm_data_products'
) }}

with base as (

    select
        customer_id,
        age
    from {{ ref('dp_customer_profile') }}

)

select
    customer_id,
    age,

    case
        when age is null then 'unknown'
        when age < 25 then 'young'
        when age between 25 and 50 then 'adult'
        when age > 50 then 'senior'
        else 'unknown'
    end as age_segment

from base