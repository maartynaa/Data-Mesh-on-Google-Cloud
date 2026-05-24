select
    customer_id,
    rental_count,
    first_rental_date,
    last_rental_date,
    total_expected_rental_amount,
    total_paid_amount,
    mean_rental_duration_days,
    unpaid_rentals_count,
    underpaid_rentals_count,
    overpaid_rentals_count,
    late_paid_rentals_count,
    last_payment_date
from {{ source('wheelie_sales_products', 'dp_customer_sales_activity') }}