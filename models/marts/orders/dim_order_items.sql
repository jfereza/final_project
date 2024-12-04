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

products_s as (

    select * from {{ ref('stg_plant_shop__products') }}

),

orders_item_prod as ( -- cruzamos orders con shipping_info, order_items y products 

    select
        A.order_id as order_id,
        B.product_id as product_id,
        product_name,
        quantity,
        production_price,
        selling_price,
        created_at_utc_datetime,
        created_at_date, 
        created_at_utc_time,
        C.updated_at_date as updated_at_date
    from orders_s A
    left join order_items_s B
        on A.order_id = B.order_id
    left join products_s C
        on ((B.product_id = C.product_id) 
        and (month(A.created_at_date) = month(C.updated_at_date))
        and (year(A.created_at_date) = year(C.updated_at_date)))
    order by created_at_utc_datetime DESC, order_id, product_name

),

final as (

    select
        order_id,
        product_id,
        product_name,
        quantity,
        production_price,
        selling_price,
        created_at_utc_datetime,
        created_at_date, 
        created_at_utc_time,
        updated_at_date
    from orders_item_prod

)

select * from final
