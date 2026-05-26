{{ config(
    materialized='table',
    schema='crm_data_products'
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
        city,
        country
    from {{ ref('int_customer_enriched') }}

)

select
    customer_id,

    -- PII hashed (STRING, not BYTES)
    to_hex(sha256(first_name)) as first_name_hash,
    to_hex(sha256(last_name)) as last_name_hash,
    to_hex(sha256(email)) as email_hash,

    is_valid_email,
    birth_date,
    age,

    case
        when age is null then 'unknown'
        when age < 25 then 'young'
        when age between 25 and 50 then 'adult'
        when age > 50 then 'senior'
        else 'unknown'
    end as age_segment,

    date(create_date) as create_date,
    customer_last_update,

    city,
    country

from base