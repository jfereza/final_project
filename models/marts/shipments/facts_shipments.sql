{{
  config(
    materialized='table'
  )
}}

with 

orders_s as (

    select * from {{ ref('stg_plant_shop__orders') }}

),

status_s as (

    select * from {{ ref('stg_plant_shop__status') }}

),

shipp_info_s as (

    select * from {{ ref('stg_plant_shop__shipping_info') }}

),

interm as (  -- cruzamos orders, status y shipping_info

    select
        tracking_id,
        A.order_id as order_id,
        B.status_id as status_id,
        C.status as status_desc,
        B.address_id as address_id,
        shipping_service_id, 
        shipping_cost,
        estimated_delivery_at_utc as estimated_delivery_at_datetime,
        date(estimated_delivery_at_utc) as estimated_delivery_at_date, 
        time(estimated_delivery_at_utc) as estimated_delivery_at_time, 
        delivered_at_utc as delivered_at_datetime,
        date(delivered_at_utc) as delivered_at_date, 
        time(delivered_at_utc) as delivered_at_time
    from shipp_info_s A
    left join orders_s B
        on A.order_id = B.order_id
    left join status_s C
        on B.status_id = C.status_id

),

interm2 as ( -- nos quedamos solo con los pedidos delivered o shipped

    select
        tracking_id,
        order_id,
        status_id,
        address_id,
        shipping_service_id, 
        shipping_cost,
        estimated_delivery_at_datetime,
        estimated_delivery_at_date, 
        estimated_delivery_at_time, 
        delivered_at_datetime,
        delivered_at_date, 
        delivered_at_time
    from interm
    where status_desc != 'preparing'

),

final as (

    select
        tracking_id,
        order_id,
        status_id,
        address_id,
        shipping_service_id, 
        shipping_cost,
        estimated_delivery_at_datetime,
        estimated_delivery_at_date, 
        estimated_delivery_at_time, 
        delivered_at_datetime,
        delivered_at_date, 
        delivered_at_time
    from interm2

)

select * from final
