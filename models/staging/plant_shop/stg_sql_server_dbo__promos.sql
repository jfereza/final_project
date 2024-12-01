{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ source('sql_server_dbo', 'promos') }}

),

interm as (

    select
        lower(promo_id) as promo_id, -- lo pongo todo en minusculas
        discount,
        status,
        _fivetran_deleted,
        convert_timezone('UTC',_fivetran_synced) as _fivetran_synced_UTC  -- convierto la zona horaria
    from source

    union -- añado una fila que sea "no discount"

    select 
        'no discount' as promo_id,
        0 as discount,
        'active' as status,
        null as _fivetran_deleted,
        convert_timezone('UTC', current_date) as _fivetran_synced_utc  -- convierto la zona horaria

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['promo_id']) }} as promo_id, -- hasheo el promo_id
        promo_id as promo_desc,
        discount,
        status,
        _fivetran_deleted,
        _fivetran_synced_utc
    from interm
    order by discount ASC

)

select * from renamed