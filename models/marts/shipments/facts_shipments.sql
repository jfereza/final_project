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

orders as ( -- seleccionamos solo los orders que estan con status = shipped o delivered

    select
        order_id,
        address_id,
        created_at_utc_datetime, 
        created_at_date, 
        created_at_utc_time
    from orders_s A
    left join status_s B
        on A.status_id = B.status_id
    where status != 'preparing' 

),

interm as ( -- cruzamos los orders_id (de orders shipped o deliveredorders) con el shipping_info

    select
        A.order_id as order_id,
        address_id,
        tracking_id,
        shipping_service_id, 
        shipping_cost,
        created_at_utc_datetime, 
        created_at_date, 
        created_at_utc_time,
        estimated_delivery_at_utc_datetime,
        estimated_delivery_at_date, 
        estimated_delivery_at_utc_time, 
        delivered_at_utc_datetime,
        delivered_at_date, 
        delivered_at_utc_time
    from  orders A
    left join shipp_info_s B
        on A.order_id = B.order_id

),

interm2 as ( -- añadimos algunas columnas 

    select
        order_id,
        address_id,
        tracking_id,
        shipping_service_id, 
        shipping_cost,
        datediff(day, created_at_date, estimated_delivery_at_date) as estimated_delivery_days,
        datediff(day, created_at_date, delivered_at_date) as real_delivery_days,
        datediff(day, delivered_at_date, estimated_delivery_at_date) as dif_estimated_real_delivery_days,
        created_at_utc_datetime,
        created_at_date, 
        created_at_utc_time, 
        estimated_delivery_at_utc_datetime,
        estimated_delivery_at_date, 
        estimated_delivery_at_utc_time, 
        delivered_at_utc_datetime,
        delivered_at_date, 
        delivered_at_utc_time
    from  interm

),

final as (

    select
        order_id,
        address_id,
        tracking_id,
        shipping_service_id, 
        shipping_cost,
        estimated_delivery_days,
        real_delivery_days,
        dif_estimated_real_delivery_days,
        created_at_utc_datetime,
        created_at_date, 
        created_at_utc_time, 
        estimated_delivery_at_utc_datetime,
        estimated_delivery_at_date, 
        estimated_delivery_at_utc_time, 
        delivered_at_utc_datetime,
        delivered_at_date, 
        delivered_at_utc_time
    from interm2

)

select * from final
