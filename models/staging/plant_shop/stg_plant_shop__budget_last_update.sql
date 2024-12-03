{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_plant_shop__budget') }}

),

interm as (

    select
        product_id,
        quantity,
        updated_at_date, 
        _snp_first_ingest_utc, 
        _snp_invalid_from_utc, 
        _fivetran_synced_utc
    from source
    where _snp_invalid_from_utc is null

),

final as (

    select
        product_id,
        quantity,
        updated_at_date, 
        _snp_first_ingest_utc, 
        _snp_invalid_from_utc, 
        _fivetran_synced_utc
    from interm

)

select * from final
