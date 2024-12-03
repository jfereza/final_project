{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ source('plant_shop', 'order_items') }}

),

interm as (

    select
        order_id, 
        product_id, 
        quantity::number as quantity,
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc,  -- convierto la zona horaria
        _fivetran_deleted
    from source

),

final as (

    select
        order_id, 
        product_id, 
        quantity,
        _fivetran_synced_utc, 
        _fivetran_deleted
    from interm

)

select * from final
