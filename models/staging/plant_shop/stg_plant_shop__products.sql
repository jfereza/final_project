{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_plant_shop__products') }}

),

final as (

    select
        product_id,
        product_name, 
        production_price, 
        selling_price, 
        inventory,
        updated_at_utc_datetime, 
        updated_at_date, 
        updated_at_utc_time,
        _snp_first_ingest_utc, 
        _snp_invalid_from_utc, 
        _fivetran_synced_utc, 
        _fivetran_deleted
    from source

)

select * from final
