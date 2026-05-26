{{ config(
    materialized='table',
    schema='crm_secure'
) }}

with base as (

    select
        customer_id,
        first_name,
        last_name,
        email,
        is_valid_email,
        birth_date,
        age,
        create_date,
        customer_last_update,
        address,
        postal_code,
        city,
        country
    from {{ ref('int_customer_enriched') }}

)

select
    customer_id,

    -- identity (raw PII - restricted access layer)
    first_name,
    last_name,
    email,
    is_valid_email,
    birth_date,
    age,

    create_date,
    customer_last_update,

    -- geo
    address,
    postal_code,
    city,
    country

from base b