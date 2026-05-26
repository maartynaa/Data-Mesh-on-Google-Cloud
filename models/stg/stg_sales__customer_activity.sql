{{ config(materialized='view') }}

select
    cast(customer_id as string) as customer_id,

    cast(rental_count as int64) as rental_count,

    cast(first_rental_date as date) as first_rental_date,
    cast(last_rental_date as date) as last_rental_date,

    cast(total_expected_rental_amount as numeric) as total_expected_rental_amount,
    cast(total_paid_amount as numeric) as total_paid_amount,

    cast(mean_rental_duration_days as float64) as mean_rental_duration_days,

    cast(unpaid_rentals_count as int64) as unpaid_rentals_count,
    cast(underpaid_rentals_count as int64) as underpaid_rentals_count,
    cast(overpaid_rentals_count as int64) as overpaid_rentals_count,
    cast(late_paid_rentals_count as int64) as late_paid_rentals_count,

    cast(last_payment_date as date) as last_payment_date

from {{ source('wheelie_sales_products', 'dp_customer_sales_activity') }}