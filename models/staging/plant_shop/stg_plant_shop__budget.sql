{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_plant_shop__budget') }}

),

final as (

    select
        product_id,
        quantity,
        updated_at_date, 
        _snp_first_ingest_utc, 
        _snp_invalid_from_utc, 
        _fivetran_synced_utc
    from source

)

select * from final
