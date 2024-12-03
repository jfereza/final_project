{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_plant_shop__users') }}

),

interm as (

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
    from source
    where _snp_invalid_from_utc is null

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
    from interm

)

select * from final
