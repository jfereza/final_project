{{
  config(
    materialized='table'
  )
}}

with 

promos_s as (

    select * from {{ ref('stg_plant_shop__promos') }}

),

final as (

    select
        promo_id, 
        promo_name, 
        discount,
        status
    from promos_s

)

select * from final