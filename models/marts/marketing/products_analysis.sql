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

budget_s as (

    select * from {{ ref('stg_plant_shop__budget') }}

),

orders_item as ( -- cruzamos orders con order_items (para product_id y quantity...)

    select
        A.order_id as order_id,
        product_id,
        quantity,
        created_at_date, 
    from orders_s A
    left join order_items_s B
        on A.order_id = B.order_id

),

order_stats as ( -- sacamos el numero de productos vendidos totales por mes

    select
        product_id,
        to_date(concat(year(created_at_date), '-', month(created_at_date), '-01'), 'YYYY-MM-DD') as active_date,
        sum(quantity) as tot_sold
    from orders_item
    group by product_id, active_date

),

interm as ( 

    select
        A.product_id as product_id,
        product_name, 
        production_price, 
        selling_price, 
        inventory,
        tot_sold,
        C.quantity as budget,
        A.updated_at_utc_datetime, 
        A.updated_at_date, 
        A.updated_at_utc_time,
        A._snp_first_ingest_utc, 
        A._snp_invalid_from_utc
    from products_s A
    left join order_stats B
        on ((A.product_id = B.product_id) 
            and (month(A.updated_at_date) = month(B.active_date)) 
            and (year(A.updated_at_date) = year(B.active_date)))
    left join budget_s C
        on ((A.product_id = C.product_id) 
            and (month(A.updated_at_date) = month(C.updated_at_date)) 
            and (year(A.updated_at_date) = year(C.updated_at_date)))

),

final as (

    select
        product_id,
        product_name, 
        production_price, 
        selling_price, 
        inventory,
        tot_sold,
        budget,
        updated_at_utc_datetime, 
        updated_at_date, 
        updated_at_utc_time,
        _snp_first_ingest_utc, 
        _snp_invalid_from_utc
    from interm

)

select * from final
