{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_plant_shop__orders') }}

),

final as (

    select
        order_id,
        user_id,
        address_id,
        {{ dbt_utils.generate_surrogate_key(['status']) }} as status_id, -- hasheo el status del order
        created_at_utc,
        order_cost,
        {{ dbt_utils.generate_surrogate_key(['promo_id']) }} as promo_id, -- hasheo el promo_id 
        order_total,
        _fivetran_synced_utc,
        _fivetran_deleted

    from 
        source

)

select * from final
