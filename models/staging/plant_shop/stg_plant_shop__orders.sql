{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_plant_shop__orders') }}

),

interm as (

    select
        order_id,
        user_id,
        address_id,
        created_at_utc_datetime, 
        created_at_date, 
        created_at_utc_time,
        {{ dbt_utils.generate_surrogate_key(['status']) }} as status_id, -- hasheo el status del order
        {{ dbt_utils.generate_surrogate_key(['promo_id']) }} as promo_id, -- hasheo el promo_id 
        _fivetran_synced_utc, 
        _fivetran_deleted
    from source

),

final as (

    select
        order_id,
        user_id,
        address_id,
        created_at_utc_datetime, 
        created_at_date, 
        created_at_utc_time,
        status_id, 
        promo_id,
        _fivetran_synced_utc, 
        _fivetran_deleted
    from interm

)
select * from final
