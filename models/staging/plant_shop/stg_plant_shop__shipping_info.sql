{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_plant_shop__orders') }}

),

final as (

    select
        order_id,
        case -- hasheo el shipping service. Si es nulo lo dejo nulo.
            when shipping_service is null then shipping_service
            else {{ dbt_utils.generate_surrogate_key(['shipping_service']) }} 
            end as shipping_service_id, 
        shipping_cost,
        tracking_id,
        estimated_delivery_at_utc,
        delivered_at_utc
    from 
        source

)

select * from final
