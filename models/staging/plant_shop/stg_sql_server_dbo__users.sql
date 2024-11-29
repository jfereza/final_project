{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ source('sql_server_dbo', 'users') }}

),

renamed as (

    select
        user_id, 
        address_id, 
        first_name, 
        last_name, 
        email, 
        replace(phone_number, '-','')::number as phone_number, 
        convert_timezone('UTC', created_at) as created_at_utc, 
        convert_timezone('UTC', updated_at) as updated_at_utc, 
        _fivetran_deleted, 
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc
    from source

)

select * from renamed
