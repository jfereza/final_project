{{
  config(
    materialized='table'
  )
}}

with 

users_s as (

    select * from {{ ref('stg_plant_shop__users') }}

),

interm as ( 

    select
        user_id, 
        first_name, 
        last_name, 
        birthday,
        datediff(year, birthday, current_date()) as age,
        email, 
        phone_number,
        address_id, 
        created_at_utc as created_at_datetime,
        date(created_at_utc) as created_at_date, 
        time(created_at_utc) as created_at_time, 
        updated_at_utc as updated_at_datetime,
        date(updated_at_utc) as updated_at_date, 
        time(updated_at_utc) as updated_at_time, 
        _snp_first_ingest_utc,
        _snp_invalid_from_utc
    from users_s

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
        created_at_datetime,
        created_at_date, 
        created_at_time, 
        updated_at_datetime,
        updated_at_date, 
        updated_at_time, 
        _snp_first_ingest_utc,
        _snp_invalid_from_utc
    from users_s

)

select * from final
