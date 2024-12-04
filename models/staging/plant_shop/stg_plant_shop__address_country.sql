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
        distinct country as country -- selecciono los paises distintos
    from source

),

interm2 as (

    select
        country,
        {{ dbt_utils.generate_surrogate_key(['country']) }} as country_id
    from interm

),

final as (

    select
        country,
        country_id
    from interm2

)

select * from final
