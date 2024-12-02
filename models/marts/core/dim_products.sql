{{
  config(
    materialized='table'
  )
}}

with 

products_s as (

    select * from {{ ref('stg_plant_shop__products') }}

),

budget_s as (

    select * from {{ ref('stg_plant_shop__budget') }}

),

interm as (

    select
        A.product_id as product_id,
        product_name, 
        production_price, 
        selling_price, 
        inventory,
        B.quantity as budget,
        date(A.updated_at_utc) as A_updated_at_date, 
        date(B.updated_at) as B_updated_at_date
    from products_s A
    left join budget_s B
        on A.product_id = B.product_id

), 


final as (

    select
        product_id,
        product_name, 
        production_price, 
        selling_price, 
        inventory,
        budget,
        A_updated_at_date as updated_at_date
    from interm
    where A_updated_at_date = B_updated_at_date
    order by
        updated_at_date, product_name

)

select * from final
