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
        address_id,
        {{ dbt_utils.generate_surrogate_key(['country']) }} as country_id, -- hasheo el country
        {{ dbt_utils.generate_surrogate_key(['state']) }} as state_id, -- hasheo el state
        zipcode,
        address, 
        _fivetran_synced_utc, 
        _fivetran_deleted
    from source

),

final as (

    select
        address_id,
        country_id, 
        state_id, 
        zipcode,
        address, 
        _fivetran_synced_utc, 
        _fivetran_deleted
    from interm

)
select * from final
