{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('snp_plant_shop__users') }}

),

interm as (

    select
        user_id, 
        first_name, 
        last_name, 
        birthday,
        datediff(year, birthday, current_date()) as age,
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

),

interm2 as (

    select
        user_id, 
        first_name, 
        last_name, 
        birthday,
        age,
        email, 
        phone_number, 
        address_id, 
        created_at_utc as created_at_utc_datetime, 
        date(created_at_utc) as created_at_date, 
        time(created_at_utc) as created_at_utc_time,
        updated_at_utc as updated_at_utc_datetime, 
        date(updated_at_utc) as updated_at_date, 
        time(updated_at_utc) as updated_at_utc_time,
        _snp_first_ingest_utc, 
        _snp_invalid_from_utc, 
        _fivetran_synced_utc, 
        _fivetran_deleted
    from interm

),

final as (

    select
        user_id, 
        first_name, 
        last_name, 
        birthday,
        age,
        email, 
        phone_number, 
        address_id, 
        created_at_utc_datetime, 
        created_at_date, 
        created_at_utc_time,
        updated_at_utc_datetime, 
        updated_at_date, 
        updated_at_utc_time,
        _snp_first_ingest_utc, 
        _snp_invalid_from_utc, 
        _fivetran_synced_utc, 
        _fivetran_deleted
    from interm2

)

select * from final
