{{ config(
    materialized='table',
    schema='crm_data_products'
) }}

with survey as (

    select *
    from {{ ref('stg_survey__responses') }}

),

customer as (

    select
        customer_id,
        age_segment
    from {{ ref('dp_customer_profile') }}

),

demographics as (

    select
        customer_id,
        age_segment
    from {{ ref('dp_customer_demographics') }}

)

select
    s.response_id,
    s.customer_id,
    s.rental_id,
    s.inventory_id,
    s.staff_id,
    s.store_id,
    s.survey_timestamp,

    s.rating_overall,
    s.rating_service,
    s.rating_price,
    s.rating_vehicle,

    s.nps_score,

    case
        when s.nps_score >= 9 then 'promoter'
        when s.nps_score >= 7 then 'passive'
        else 'detractor'
    end as nps_category,

    case
        when s.rating_overall >= 4 then 'positive'
        when s.rating_overall = 3 then 'neutral'
        else 'negative'
    end as rating_category,

    s.comment_text,
    s.location,
    s.device_type,

    d.age_segment

from survey s

left join demographics d
    on s.customer_id = d.customer_id