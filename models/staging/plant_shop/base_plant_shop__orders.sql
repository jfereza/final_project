{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ source('plant_shop', 'orders') }}

),

final as (
    
    select 
        order_id,
        user_id,
        address_id,
        convert_timezone('UTC', created_at) as created_at_utc, -- convierto la zona horaria
        order_cost::decimal(14,3) as order_cost,  -- dejo 3 decimales
        lower(status) as status, -- pongo los status en minusculas
        nullif(trim(shipping_service), '') as shipping_service, -- cambio los vacios o espacios por null
        shipping_cost::decimal(14,3) as shipping_cost,  -- dejo 3 decimales
        nullif(trim(tracking_id), '') as tracking_id, -- cambio los vacios o espacios por null
        convert_timezone('UTC', estimated_delivery_at) as estimated_delivery_at_utc, -- convierto la zona horaria. Los null los dejo así.
        convert_timezone('UTC', delivered_at) as delivered_at_utc, -- convierto la zona horaria. Los null los dejo así.
        case -- primero cambio las promos vacias, espacio o null por "no discount". Además, pongo todas en minúsculas
            when promo_id is null then 'no discount'
            when nullif(trim(promo_id), '') is null then 'no discount' 
            else lower(promo_id)
            end as promo_id, 
        order_total::decimal(14,3) as order_total,  -- dejo 3 decimales
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc, -- convierto la zona horaria
        _fivetran_deleted
    from source

)

select * from final