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
        distinct status as status -- selecciono los tipos de status distintos
    from source 

),

interm2 as (

    select
        {{ dbt_utils.generate_surrogate_key(['status']) }} as status_id, -- hasheo el status
        status as status
    from 
        iterm 

),

final as (

    select
        status_id, 
        status
    from 
        interm2 

)

select * from final
