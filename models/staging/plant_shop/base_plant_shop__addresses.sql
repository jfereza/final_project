{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ source('plant_shop', 'addresses') }}

),

final as (

    select
        address_id,
        country, 
        state, 
        zipcode,
        address, 
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc,  -- convierto la zona horaria
        _fivetran_deleted
    from source

)

select * from final
