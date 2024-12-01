{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ source('sql_server_dbo', 'order_items') }}

),

source2 as (

    select * from {{ ref('base_sql_server_dbo__orders') }}

),

interm as (

    select
        A.product_id,
        month(B.created_at_utc)::number as month, -- las fechas solo cambian a nivel de mes
        A.quantity
    from source A
    left join source2 B
        on A.order_id=B.order_id

),

renamed as (

    select
        product_id,
        month,
        sum(quantity) as quantity
    from interm
    group by 
        1,2
    order by 
        2,1

)

select * from renamed