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

orders_s as (

    select * from {{ ref('stg_plant_shop__orders') }}

),

status_s as (

    select * from {{ ref('stg_plant_shop__status') }}

),

orders as ( -- seleccionamos solo los adresses_id de los orders que estan con status = shipped o delivered

    select
        address_id,
    from orders_s A
    left join status_s B
        on A.status_id = B.status_id
    where status != 'preparing' 

),

addresses as ( -- unimos la info de contry y state a los addresses

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

interm as ( -- cruzamos los adresses_id (de orders shipped o delivered) con las addresses completas

    select
        A.address_id as address_id,  
        country, 
        state,
        zipcode,
        address
    from orders A
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
