{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_plant_shop__addresses') }}

),

interm as (

    select
        distinct country as country
    from source

),

renamed as (

    select
        country,
        {{ dbt_utils.generate_surrogate_key(['country']) }} as country_id
    from interm

)

select * from renamed
