{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ source('plant_shop', 'promos') }}

),

interm as (

    select
        lower(promo_id) as promo_id, -- Pongo todas las promos en minusculas
        discount::number as discount,
        lower(status) as status, -- Pongo todos los estados en minusculas
        convert_timezone('UTC',_fivetran_synced) as _fivetran_synced_utc,  -- convierto la zona horaria
        _fivetran_deleted
    from source

    union -- añado una fila que sea "no discount" para las orders con promos vacías, espacios o nulas

    select 
        'no discount' as promo_id,
        0 as discount,
        'active' as status,
        convert_timezone('UTC', current_date) as _fivetran_synced_utc,  -- convierto la zona horaria
        null as _fivetran_deleted

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['promo_id']) }} as promo_id, -- hasheo el promo_id
        promo_id as promo_name, -- renombro la columna
        discount,
        status,
        _fivetran_deleted,
        _fivetran_synced_utc
    from interm
    order by discount ASC

)

select * from final