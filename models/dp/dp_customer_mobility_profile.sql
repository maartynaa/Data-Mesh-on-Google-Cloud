{{ config(
    materialized='table',
    schema='crm_data_products'
) }}

with customers as (

    select
        cast(customer_id as string) as customer_id,
        country,
        age_segment
    from {{ ref('dp_customer_profile') }}

),

sales as (

    select
        cast(customer_id as string) as customer_id,
        rental_count,
        last_rental_date,
        cast(total_expected_rental_amount as numeric) as total_expected_rental_amount,
        cast(total_paid_amount as numeric) as total_paid_amount,
        unpaid_rentals_count,
        late_paid_rentals_count
    from {{ ref('stg_sales__customer_activity') }}

),

fleet as (

    select *
    from {{ ref('stg_fleet__car_catalog') }}

),

customer_activity as (

    select
        c.customer_id,
        c.age_segment,
        c.country,

        s.rental_count,
        s.last_rental_date,
        s.total_expected_rental_amount,
        s.total_paid_amount,
        s.unpaid_rentals_count,
        s.late_paid_rentals_count,

        case
            when s.unpaid_rentals_count > 0 then 'has_unpaid'
            when s.late_paid_rentals_count > 0 then 'has_late'
            else 'good_standing'
        end as payment_status,

        case
            when s.rental_count >= 10 then 'power_user'
            when s.rental_count >= 5 then 'regular_user'
            else 'casual_user'
        end as mobility_segment

    from customers c
    left join sales s
        on c.customer_id = s.customer_id

),

vehicle_preferences as (

    select *
    from (

        select
            producer,
            model,
            fuel_type,
            rental_rate,

            case
                when rental_rate < 150 then 'budget'
                when rental_rate between 150 and 220 then 'standard'
                else 'premium'
            end as vehicle_segment,

            row_number() over (
                partition by
                    case
                        when rental_rate < 150 then 'budget'
                        when rental_rate between 150 and 220 then 'standard'
                        else 'premium'
                    end
                order by rental_rate asc
            ) as rn

        from fleet

    ) t
    where rn = 1

)

select
    a.customer_id,
    a.age_segment,
    a.country,

    a.rental_count,
    a.last_rental_date,
    a.total_expected_rental_amount,
    a.total_paid_amount,

    a.payment_status,
    a.mobility_segment,

    v.producer as recommended_brand,
    v.model as recommended_model,
    v.fuel_type,
    v.vehicle_segment

from customer_activity a

left join vehicle_preferences v
    on (a.mobility_segment = 'casual_user' and v.vehicle_segment = 'budget')
    or (a.mobility_segment = 'regular_user' and v.vehicle_segment = 'standard')
    or (a.mobility_segment = 'power_user' and v.vehicle_segment = 'premium')