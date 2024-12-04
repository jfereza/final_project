{{
  config(
    materialized='table'
  )
}}

with 

ship_serv_s as (

    select * from {{ ref('stg_plant_shop__shipping_service') }}

),

final as (

    select
        shipping_service_id,
        shipping_service
    from ship_serv_s 

)

select * from final
