{{
  config(
    materialized='table'
  )
}}

with 

address_s as (

    select * from {{ ref('stg_plant_shop__addresses') }}

),

country_s as (

    select * from {{ ref('stg_plant_shop__address_country') }}

),

state_s as (

    select * from {{ ref('stg_plant_shop__address_state') }}

),

final as (

    select
        address_id,
        country, 
        state,
        zipcode,
        address
    from address_s A
    left join country_s B
        on A.country_id = B.country_id
    left join state_s C
        on A.state_id = C.state_id

)

select * from final
