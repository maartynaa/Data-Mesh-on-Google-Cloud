select *
from {{ source('wheelie_sales_products', 'dp_customer_sales_activity') }}
limit 10