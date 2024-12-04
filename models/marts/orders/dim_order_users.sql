{{
  config(
    materialized='table'
  )
}}

with 

users_s as (

    select * from {{ ref('stg_plant_shop__users_last_update') }} -- el ultimo estado de los users

),

orders_s as (

    select * from {{ ref('stg_plant_shop__orders') }}

),

interm as ( -- cruzamos los orders con users para quedarnos solo con los users que han pedido algo 

    select
        distinct A.user_id as user_id,  
        first_name, 
        last_name, 
        birthday,
        age,
        email, 
        phone_number,
        B.address_id as address_id, -- nos interesa la address del user, no del order
        B.created_at_utc_datetime as created_at_utc_datetime, -- nos interesa esta info del user, no del order
        B.created_at_date as created_at_date, 
        B.created_at_utc_time as created_at_utc_time, 
        updated_at_utc_datetime,
        updated_at_date, 
        updated_at_utc_time, 
        _snp_first_ingest_utc,
        _snp_invalid_from_utc
    from orders_s A
    left join users_s B
        on A.user_id = B.user_id

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
        _snp_invalid_from_utc
    from interm 

)

select * from final
