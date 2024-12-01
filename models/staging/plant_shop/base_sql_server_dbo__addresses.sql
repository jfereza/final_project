{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ source('sql_server_dbo', 'addresses') }}

),

renamed as (

    select
        address_id,
        lower(country) as country, -- lo pongo todo en minusculas para evitar problemas con el hash
        lower(state) as state, -- lo pongo todo en minusculas para evitar problemas con el hash
        zipcode,
        address, 
       convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc  -- convierto la zona horaria
    from source

)

select * from renamed
