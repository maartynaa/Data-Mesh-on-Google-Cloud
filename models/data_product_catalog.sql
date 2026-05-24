{{ config(materialized='view') }}

select
    table_catalog as project,
    table_schema as dataset,
    table_name as data_product,
    table_type,
    creation_time
from `bw-bigdata-2026-data-mesh.crm_data_products.INFORMATION_SCHEMA.TABLES`
where table_name like 'dp_%'