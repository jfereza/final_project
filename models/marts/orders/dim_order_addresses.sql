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

order_s as (

    select * from {{ ref('stg_plant_shop__orders') }}

),

addresses as ( -- unimos la info de country y state a los addresses

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

),

interm as ( -- cruzamos la info de los addresses con los orders, ya que solo queremos direcciones puestas en los pedidos

    select
        distinct A.address_id as address_id,  
        country, 
        state,
        zipcode,
        address
    from order_s A
    left join  addresses B
        on A.address_id = B.address_id

),

final as (

    select
        address_id,
        country, 
        state,
        zipcode,
        address
    from interm

)

select * from final
