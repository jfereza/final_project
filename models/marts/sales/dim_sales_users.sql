{{
  config(
    materialized='table'
  )
}}

with 

users_s as (

    select * from {{ ref('stg_plant_shop__users') }}

),

orders_s as (

    select * from {{ ref('stg_plant_shop__orders') }}

),

interm as ( -- cruzamos los orders con users, para quedarnos solo con los users que han pedido algo 

    select
        A.user_id as user_id,  
        first_name, 
        last_name, 
        birthday,
        age,
        email, 
        phone_number,
        B.address_id as address_id, 
        B.created_at_utc as created_at_datetime,
        date(B.created_at_utc) as created_at_date, 
        time(B.created_at_utc) as created_at_time, 
        B.updated_at_utc as updated_at_datetime,
        date(B.updated_at_utc) as updated_at_date, 
        time(B.updated_at_utc) as updated_at_time, 
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
        created_at_datetime,
        created_at_date, 
        created_at_time, 
        updated_at_datetime,
        updated_at_date, 
        updated_at_time, 
        _snp_first_ingest_utc,
        _snp_invalid_from_utc
    from interm 

)


select * from final
