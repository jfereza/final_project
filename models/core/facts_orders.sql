{{
  config(
    materialized='table'
  )
}}

with 

orders as (

    select * from {{ ref('stg_sql_server_dbo__orders') }}

),

order_items as (

    select * from {{ ref('stg_sql_server_dbo__order_items') }}

),

products as (

    select * from {{ ref('stg_sql_server_dbo__products') }}

),

interm as (

    select
        A.order_id,
        status_id,
        B.product_id as product_id,
        B.quantity as quantity,
        C.price as unit_price,
        user_id,
        address_id,
        shipping_id, 
        tracking_id,
        created_at_utc,
        estimated_delivery_at_utc,
        delivered_at_utc,
        promo_id,
        shipping_cost as order_shipping_cost
    from 
        orders A
    left join order_items B
        on A.order_id=B.order_id
    left join products C
        on B.product_id=C.product_id

),

renamed as (

    select
        order_id,
        status_id,
        product_id,
        quantity,
        unit_price,
        user_id,
        address_id,
        shipping_id, 
        tracking_id,
        created_at_utc,
        estimated_delivery_at_utc,
        delivered_at_utc,
        promo_id,
        (order_shipping_cost/quantity)::decimal(14,2) as product_unit_shipping_cost,
        order_shipping_cost
    from 
        interm
    order by
        order_id

)

select * from renamed