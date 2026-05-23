select 
    customer_id,
    first_name,
    last_name,
    email,
    address_id,
    safe_cast(birth_date as date) as birth_date,
    safe_cast(create_date as timestamp) as create_date,
    safe_cast(last_update as timestamp) as last_update
from {{ source('wheelie_raw', 'customer') }}