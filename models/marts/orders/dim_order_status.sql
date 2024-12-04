{{
  config(
    materialized='table'
  )
}}

with 

status_s as (

    select * from {{ ref('stg_plant_shop__status') }}

),

final as (

    select
        status_id, 
        status
    from status_s 

)

select * from final
