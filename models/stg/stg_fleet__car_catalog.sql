{{ config(
    materialized='view',
    schema='crm'
) }}

select
    producer,
    model,
    vehicle_age_group,
    fuel_type,
    rental_rate

from {{ source('fleet', 'dp_car_catalog') }}