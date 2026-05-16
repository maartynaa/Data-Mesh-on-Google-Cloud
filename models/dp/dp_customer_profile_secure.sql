{{ config(materialized='view') }}

with base as (

    select *
    from {{ ref('int_customer_enriched') }}

)

select
    customer_id,

    -- identity (pseudonimizacja)
    sha256(first_name) as first_name_hash,
    sha256(last_name) as last_name_hash,
    sha256(email) as email_hash,

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

    create_date,
    customer_last_update,

    -- geo (zostawione, ale można ograniczyć dalej jeśli potrzeba)
    city,
    country

from base