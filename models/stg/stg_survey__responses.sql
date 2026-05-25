{{ config(
    materialized='view',
    schema='crm'
) }}

select
    cast(response_id      as int64)    as response_id,
    cast(customer_id      as int64)    as customer_id,
    cast(rental_id        as int64)    as rental_id,
    cast(inventory_id     as int64)    as inventory_id,
    cast(staff_id         as int64)    as staff_id,
    cast(store_id         as int64)    as store_id,
    cast(survey_timestamp as timestamp) as survey_timestamp,
    cast(rating_overall   as int64)    as rating_overall,
    cast(rating_service   as int64)    as rating_service,
    cast(rating_price     as int64)    as rating_price,
    cast(rating_vehicle   as int64)    as rating_vehicle,
    cast(nps_score        as int64)    as nps_score,
    comment_text,
    location,
    device_type

from {{ source('crm_survey', 'survey_responses') }}