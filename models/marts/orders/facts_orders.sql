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

promos_s as (

    select * from {{ ref('stg_plant_shop__promos') }}

),

orders_all as ( -- cruzamos orders con shipping_info (para extraer el shipping_cost) y order_items (para product_id y quantity...)

    select
        A.order_id as order_id,
        B.product_id as product_id,
        product_name,
        quantity,
        production_price,
        selling_price,
        discount,
        shipping_cost,
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
    left join promos_s D
        on A.promo_id = D.promo_id
    left join ship_info_s E
        on A.order_id = E.order_id

),

stats as (

    select
        order_id,
        sum(quantity * production_price) as order_production_costs,
        sum(quantity * selling_price) as order_selling_price,
        sum(quantity * selling_price) - max(shipping_cost) - max(discount)  as order_gross_benefits,
        sum(quantity * selling_price) - max(shipping_cost) - max(discount) -sum(quantity * production_price) as order_neat_benefits
    from orders_all 
    group by order_id

),

interm as ( -- cruzamos orders+shipping_info+order_items con products (para name, prod_price y selling price) 

    select
        A.order_id as order_id,
        user_id,
        address_id,
        created_at_utc_datetime, 
        created_at_date, 
        created_at_utc_time,
        status_id, 
        promo_id,
        shipping_cost as order_shipping_cost,
        order_production_costs,
        order_selling_price,
        order_gross_benefits,
        order_neat_benefits
    from orders_s A
    left join ship_info_s B
        on A.order_id = B.order_id
    left join stats C
        on A.order_id = C.order_id
),

final as (

    select
        order_id,
        user_id,
        address_id,
        status_id, 
        promo_id,
        order_shipping_cost,
        order_production_costs,
        order_selling_price,
        order_gross_benefits,
        order_neat_benefits,
        created_at_utc_datetime, 
        created_at_date, 
        created_at_utc_time
    from interm

)

select * from final
