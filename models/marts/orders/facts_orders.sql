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

ship_info_s as (

    select * from {{ ref('stg_plant_shop__shipping_info') }}

),

orders_ship_item as ( -- cruzamos orders con shipping_info (para extraer el shipping_cost) y order_items (para product_id y quantity...)

    select
        A.order_id as order_id,
        status_id,
        product_id,
        quantity,
        created_at_utc_datetime,
        created_at_date, 
        created_at_utc_time, 
        user_id,
        address_id,
        promo_id, 
        shipping_cost as order_shipping_cost,
        order_cost as order_selling_price,
        order_total
    from orders_s A
    left join ship_info_s B
        on A.order_id = B.order_id
    left join order_items_s C
        on A.order_id = C.order_id

),

orders_ship_item_prod as ( -- cruzamos orders+shipping_info+order_items con products (para name, prod_price y selling price) 

    select
        order_id,
        status_id,
        A.product_id as product_id,
        product_name,
        quantity,
        production_price,
        selling_price,
        created_at_utc_datetime,
        created_at_date, 
        created_at_utc_time, 
        user_id,
        address_id,
        promo_id, 
        order_shipping_cost,
        order_selling_price,
        order_total
    from orders_ship_item A
    left join products_s B
        on ((A.product_id = B.product_id) 
            and (month(A.created_at_date) = month(B.updated_at_date)) 
            and (year(A.created_at_date) = year(B.updated_at_date)))
    order by created_at_utc_datetime DESC, order_id, product_name

),

stats as (

    select
        order_id,
        sum(quantity * production_price) as order_production_costs,
        max(order_total) - sum(quantity * production_price) as order_benefits,
    from orders_ship_item_prod
    group by order_id

),


interm as (

    select
        A.order_id as order_id,
        status_id,
        user_id,
        address_id,
        product_id,
        product_name,
        quantity,
        production_price,
        selling_price,
        promo_id, 
        order_shipping_cost,
        order_selling_price,
        order_total,
        order_production_costs,
        order_benefits,
        created_at_date, 
        created_at_utc_datetime,
        created_at_utc_time,
    from orders_ship_item_prod A
    left join stats B
        on A.order_id = B.order_id

),


final as (

    select
        order_id,
        user_id,
        address_id,
        status_id,
        product_id,
        product_name,
        quantity,
        production_price,
        selling_price, 
        promo_id, 
        order_shipping_cost,
        order_selling_price,
        order_total,
        order_production_costs,
        order_benefits,
        created_at_date, 
        created_at_utc_datetime,
        created_at_utc_time
    from interm

)

select * from final
