{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('snp_plant_shop__users') }}

),

final as (

    select
        user_id, 
        first_name, 
        last_name, 
        birthday,
        email, 
        translate(phone_number, '()-','')::number as phone_number, -- formateo los numeros de telefonos
        address_id, 
        convert_timezone('UTC', created_at) as created_at_utc,  -- convierto la zona horaria
        convert_timezone('UTC', updated_at) as updated_at_utc,  -- convierto la zona horaria
        convert_timezone('UTC', dbt_valid_from) as _snp_first_ingest_utc, -- renombro la columna y convierto la zona horaria
        convert_timezone('UTC', dbt_valid_to) as _snp_invalid_from_utc, -- renombro la columna y convierto la zona horaria
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc, -- convierto la zona horaria
        _fivetran_deleted
    from source

)

select * from final
