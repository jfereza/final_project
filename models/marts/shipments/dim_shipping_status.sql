{{
  config(
    materialized='table'
  )
}}

with 

status_s as (

    select * from {{ ref('stg_plant_shop__status') }}

),

interm as ( -- en este departamento solo nos interesan los pedidos delivered o shipped

    select
        status_id, 
        status
    from 
        status_s 
    where status != 'preparing'

),

final as (

    select
        status_id, 
        status
    from 
        interm 

)

select * from final
