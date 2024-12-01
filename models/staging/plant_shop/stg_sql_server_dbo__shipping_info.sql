{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_sql_server_dbo__orders') }}

),

renamed as (

    select
        order_id,
        tracking_id,
        case -- hasheo el shipping service. Si es nulo lo dejo nulo. Ya habia cambiado vacios y espacios por nulos en "base-orders"
            when shipping_service is null then shipping_service
            else {{ dbt_utils.generate_surrogate_key(['shipping_service']) }} 
            end as shipping_service_id, 
        estimated_delivery_at_utc,
        delivered_at_utc,
        shipping_cost
    from 
        source

)

select * from renamed
