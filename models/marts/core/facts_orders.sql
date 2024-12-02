{{
  config(
    materialized='table'
  )
}}

with 

orders_s as (

    select * from {{ ref('stg_plant_shop__orders') }}

),

order_items_s as (

    select * from {{ ref('stg_plant_shop__order_items') }}

),

ship_info_s as (

    select * from {{ ref('stg_plant_shop__shipping_info') }}

),

iterm as (

    select
        A.order_id as order_id,
        product_id,
        B.quantity as quantity,
        status_id,
        created_at_utc as created_at_datetime,
        date(created_at_utc) as created_at_date, 
        time(created_at_utc) as created_at_time, 
        user_id,
        address_id,
        order_cost,
        promo_id, 
        C.shipping_cost as shipping_cost,
        order_total
    from orders_s A
    left join order_items_s B
        on A.order_id = B.order_id
    left join ship_info_s C
        on A.order_id = C.order_id

),

final as (

    select
        order_id,
        product_id,
        quantity,
        status_id,
        created_at_datetime,
        created_at_date, 
        created_at_time, 
        user_id,
        address_id,
        order_cost,
        promo_id, 
        shipping_cost,
        order_total
    from iterm

)

select * from final
