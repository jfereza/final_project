{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_plant_shop__orders') }}

),

iterm as (

    select
        distinct shipping_service as shipping_service -- me quedo solo con los shipping service distintos 
    from 
        source 
    where
        shipping_service is not null -- quito los nulos, no los quiero en esta tabla

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['shipping_service']) }} as shipping_service_id,
        shipping_service
    from 
        iterm 

)

select * from final
