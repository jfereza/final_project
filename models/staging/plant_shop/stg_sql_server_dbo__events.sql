{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ source('sql_server_dbo', 'events') }}

),

interm as (

    select
        event_id,
        session_id,
        user_id,
        lower(event_type) as event_type, -- pongo todos los tipos de evento en minusculas
        page_url,
        convert_timezone('UTC', created_at) as created_at_utc, -- convierto la zona horaria
        nullif(trim(product_id), '') as product_id, -- cambio los vacios o espacios por null
        nullif(trim(order_id), '') as order_id, -- cambio los vacios o espacios por null
        _fivetran_deleted,
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc  -- convierto la zona horaria

    from source

),

renamed as (

    select
        event_id,
        session_id,
        user_id,
        {{ dbt_utils.generate_surrogate_key(['event_type']) }} as event_type_id, -- hasheo el tipo de evento
        page_url,
        created_at_utc,
        product_id,
        order_id,
        _fivetran_deleted,
        _fivetran_synced_utc

    from interm

)

select * from renamed
