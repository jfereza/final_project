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

users_s as (

    select * from {{ ref('stg_plant_shop__users') }}

),

orders_quantity as( -- unimos orders con quantities de cada producto

    select 
        user_id,
        A.order_id as order_id,
        B.quantity as quantity
    from orders_s A
    left join order_items_s B
        on A.order_id = B.order_id

),

quantity_by_user as ( -- calculamos total unidades por usuario

    select 
        user_id,
        sum(quantity) as tot_quantity
    from orders_quantity
    group by user_id

),

orders_by_user as ( -- calculamos total pedidos por usuario

    select 
        user_id,
        count(order_id) as tot_orders
    from orders_quantity
    group by user_id

),

interm as ( -- unimos users (hayan comprado o no) con las dos variables anteriores

    select 
        A.user_id as user_id,
        case
            when tot_quantity is not null then tot_quantity
            else 0
            end as tot_quantity,
        case
            when tot_orders is not null then tot_orders
            else 0
            end as tot_orders,
        first_name, 
        last_name, 
        birthday,
        datediff(year, birthday, current_date()) as age,
        email, 
        phone_number,
        address_id, 
        created_at_utc as created_at_datetime,
        date(created_at_utc) as created_at_date, 
        time(created_at_utc) as created_at_time, 
        updated_at_utc as updated_at_datetime,
        date(updated_at_utc) as updated_at_date, 
        time(updated_at_utc) as updated_at_time, 
        _snp_first_ingest_utc,
        _snp_invalid_from_utc
    from users_s A
    left join orders_by_user B
        on A.user_id = B.user_id
    left join quantity_by_user C
        on A.user_id = C.user_id
    
),

final as ( 

    select
        user_id, 
        tot_quantity
        tot_orders,
        first_name, 
        last_name, 
        birthday,
        age,
        email, 
        phone_number,
        address_id, 
        created_at_datetime,
        created_at_date, 
        created_at_time, 
        updated_at_datetime,
        updated_at_date, 
        updated_at_time, 
        _snp_first_ingest_utc,
        _snp_invalid_from_utc
    from interm

)

select * from final
