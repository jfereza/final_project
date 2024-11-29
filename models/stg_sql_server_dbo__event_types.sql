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
        distinct lower(event_type) as event_type
    from source

),

renamed as (

    select 
        event_type as event_type,
        {{ dbt_utils.generate_surrogate_key(['event_type']) }} as event_type_id
    from interm
)

select * from renamed
