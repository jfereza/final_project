{{
  config(
    materialized='table',
    pre_hook=[
      "UPDATE {{ env_var('DBT_ENVIRONMENTS') }}_SILVER.SNAPSHOTS.SNP_PLANT_SHOP__PRODUCTS 
      SET updated_at = '2022-08-01T10:52:49.903000+02:00' 
      WHERE updated_at = '2022-08-01T00:52:49.903000+02:00';"
    ]
  )
}}

with 

source as (

    select * from {{ ref('snp_plant_shop__products') }}

),

interm as (

    select
        product_id,
        name as product_name, -- renombro la columna
        production_price::decimal(14,3) as production_price, -- dejo 3 decimales
        price::decimal(14,3) as selling_price, -- dejo 3 decimales
        inventory::number as inventory,
        convert_timezone('UTC', updated_at) as updated_at_utc,  -- convierto la zona horaria
        convert_timezone('UTC', dbt_valid_from) as _snp_first_ingest_utc, -- renombro la columna y convierto la zona horaria
        convert_timezone('UTC', dbt_valid_to) as _snp_invalid_from_utc, -- renombro la columna y convierto la zona horaria
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc, -- convierto la zona horaria
        _fivetran_deleted
    from source

),

interm2 as (

    select
        product_id,
        product_name, 
        production_price, 
        selling_price, 
        inventory,
        updated_at_utc as updated_at_utc_datetime, 
        date(updated_at_utc) as updated_at_date, 
        time(updated_at_utc) as updated_at_utc_time,
        _snp_first_ingest_utc, 
        _snp_invalid_from_utc, 
        _fivetran_synced_utc, 
        _fivetran_deleted
    from interm

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
    from interm2

)

select * from final
