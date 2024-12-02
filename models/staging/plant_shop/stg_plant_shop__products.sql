{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('snp_plant_shop__products') }}

),

final as (

    select
        product_id,
        name as product_name, -- renombro la columna
        production_price::decimal(14,3) as production_price, -- dejo 3 decimales
        price::decimal(14,3) as selling_price, -- dejo 3 decimales
        inventory::number as inventory,
        convert_timezone('UTC', dbt_valid_from) as _snp_first_ingest_utc, -- renombro la columna y convierto la zona horaria
        convert_timezone('UTC', dbt_valid_to) as _snp_invalid_from_utc, -- renombro la columna y convierto la zona horaria
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc, -- convierto la zona horaria
        _fivetran_deleted
    from source

)

select * from final
