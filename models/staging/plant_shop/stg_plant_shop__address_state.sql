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

    select distinct state as state -- selecciono los estados distintos
    from source

),

final as (

    select
        state,
        {{ dbt_utils.generate_surrogate_key(['state']) }} as state_id
    from interm

)

select * from final
