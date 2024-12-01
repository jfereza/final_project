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
        nullif(trim(tracking_id), '') as tracking_id, -- cambio los vacios o espacios por null
        nullif(trim(shipping_service), '') as shipping_service, -- cambio los vacios o espacios por null
        lower(status) as status, -- pongo los status en minusculas
        convert_timezone('UTC', created_at) as created_at_utc, -- convierto la zona horaria
        convert_timezone('UTC', estimated_delivery_at) as estimated_delivery_at_utc, -- convierto la zona horaria
        convert_timezone('UTC', delivered_at) as delivered_at_utc, -- convierto la zona horaria
        order_cost,
        shipping_cost,
        case -- cambio las promos vacias, espacio o null por "no discount". Pongo todas en minúsculas
            when promo_id is null then 'no discount'
            when nullif(trim(promo_id), '') is null then 'no discount' 
            else lower(promo_id)
            end as promo_id, 
        order_total,
        _fivetran_deleted,
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc  -- convierto la zona horaria
        
    from source

)

select * from renamed