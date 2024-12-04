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

users_s as (

    select * from {{ ref('stg_plant_shop__users') }}

),

users_lu_s as (

    select * from {{ ref('stg_plant_shop__users_last_update') }}

),

orders_item as ( -- cruzamos orders con order_items (para product_id y quantity...)

    select
        A.order_id as order_id,
        user_id,
        status_id,
        B.product_id as product_id,
        B.quantity as quantity,
        created_at_utc_datetime,
        created_at_date, 
        created_at_utc_time, 
        address_id,
        promo_id, 
        order_total
    from orders_s A
    left join order_items_s B
        on A.order_id = B.order_id

),

orders_quantit_price as ( -- cruzamos ordero+order_items con products (para name, prod_price y selling price) 

    select
        order_id,
        user_id,
        status_id,
        A.product_id as product_id,
        B.product_name as product_name,
        quantity,
        B.production_price as production_price,
        B.selling_price as selling_price,
        created_at_utc_datetime,
        created_at_date, 
        created_at_utc_time, 
        address_id,
        promo_id, 
        order_total
    from orders_item A
    left join products_s B
        on ((A.product_id = B.product_id) 
            and (month(A.created_at_date) = month(B.updated_at_date)) 
            and (year(A.created_at_date) = year(B.updated_at_date)))

),

stats1 as ( -- calculamos algunas estadisticas

    select 
        user_id,
        order_id,
        sum(quantity*selling_price) as spent_each_order
    from orders_quantit_price
    group by user_id, order_id

),

stats2 as ( -- calculamos algunas estadisticas

    select 
        user_id,
        max(spent_each_order) as max_spent_order,
        min(spent_each_order) as min_spent_order,        
        avg(spent_each_order) as mean_spent_each_order,
        median(spent_each_order) as median_spent_each_order
    from stats1
    group by user_id

),

stats3 as ( -- calculamos algunas estadisticas

    select 
        user_id,
        sum(quantity) as tot_num_plants,
        count(distinct product_name) as num_diff_plants,
        count(order_id) as tot_num_orders,
        sum(quantity*selling_price) as tot_spent,
    from orders_quantit_price 
    group by user_id

),

stats4 as ( -- calculamos algunas estadisticas

    select 
        user_id, 
        count(_snp_invalid_from_utc) as num_profile_edits
    from users_s
    where _snp_invalid_from_utc is not null
    group by user_id

),

stats5 as ( -- calculamos algunas estadisticas

    select 
        user_id, 
        datediff(day, created_at_date, current_date()) as user_seniority_days,
        datediff(month, created_at_date, current_date()) as user_seniority_months,
        datediff(year, created_at_date, current_date()) as user_seniority_years
    from users_lu_s

),

interm as ( 

    select 
        A.user_id as user_id,
        first_name, 
        last_name, 
        birthday,
        age,
        email, 
        phone_number,
        address_id, 
        created_at_utc_datetime,
        created_at_date, 
        created_at_utc_time, 
        coalesce(B.max_spent_order, 0)::decimal(14,3) as max_spent_order,
        coalesce(B.min_spent_order, 0)::decimal(14,3) as min_spent_order,
        coalesce(B.mean_spent_each_order, 0)::decimal(14,3) as mean_spent_each_order,
        coalesce(B.median_spent_each_order, 0)::decimal(14,3) as median_spent_each_order,
        coalesce(C.tot_num_plants, 0)::int as tot_num_plants,
        coalesce(C.num_diff_plants, 0)::int as num_diff_plants,
        coalesce(C.tot_num_orders, 0)::int as tot_num_orders,
        coalesce(C.tot_spent, 0)::decimal(14,3) as tot_spent,
        coalesce(D.num_profile_edits, 0)::int as num_profile_edits,
        coalesce(E.user_seniority_days, 0)::int as user_seniority_days,
        coalesce(E.user_seniority_months, 0)::int as user_seniority_months,
        coalesce(E.user_seniority_years, 0)::int as user_seniority_years
    from users_lu_s A
    left join stats2 B
        on A.user_id = B.user_id
    left join stats3 C
        on A.user_id = C.user_id
    left join stats4 D
        on A.user_id = D.user_id
    left join stats5 E
        on A.user_id = E.user_id

),

final as ( 

    select
        user_id,
        first_name, 
        last_name, 
        birthday,
        age,
        email, 
        phone_number,
        address_id, 
        created_at_utc_datetime,
        created_at_date, 
        created_at_utc_time, 
        max_spent_order,
        min_spent_order,
        mean_spent_each_order,
        median_spent_each_order,
        tot_num_plants,
        num_diff_plants,
        tot_num_orders,
        tot_spent,
        num_profile_edits,
        user_seniority_days,
        user_seniority_months,
        user_seniority_years
    from interm

)

select * from final
