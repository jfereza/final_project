{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ source('sql_server_dbo', 'orders') }}

),

renamed as (
    
    select 
        order_id,
        user_id,
        address_id,
        nullif(trim(tracking_id), '') as tracking_id, -- primero cambio los vacios o espacios por null
        nullif(trim(shipping_service), '') as shipping_service, -- primero cambio los vacios o espacios por null
        status,
        convert_timezone('UTC', created_at) as created_at_utc,
        convert_timezone('UTC', estimated_delivery_at) as estimated_delivery_at_utc,
        convert_timezone('UTC', delivered_at) as delivered_at_utc,
        order_cost,
        shipping_cost,
        case -- cambio las promos vacias, espacio o null por "no discount". Pongo todo en minúsculas
            when promo_id is null then 'no discount'
            when nullif(trim(promo_id), '') is null then 'no discount' 
            else lower(promo_id)
            end as promo_id, 
        order_total,
        _fivetran_deleted,
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc
        
    from source

)

select * from renamed