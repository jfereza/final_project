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
        lower(event_type) as event_type,
        page_url,
        convert_timezone('UTC', created_at) as created_at_utc,
        nullif(trim(product_id), '') as product_id, -- primero cambio los vacios o espacios por null
        nullif(trim(order_id), '') as order_id, -- primero cambio los vacios o espacios por null
        _fivetran_deleted,
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc

    from source

),

renamed as (

    select
        event_id,
        session_id,
        user_id,
        {{ dbt_utils.generate_surrogate_key(['event_type']) }} as event_type_id,
        page_url,
        created_at_utc,
        product_id,
        order_id,
        _fivetran_deleted,
        _fivetran_synced_utc

    from interm

)

select * from renamed
