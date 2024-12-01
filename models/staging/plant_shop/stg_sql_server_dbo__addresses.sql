{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_sql_server_dbo__addresses') }}

),

renamed as (

    select
        address_id,
        {{ dbt_utils.generate_surrogate_key(['country']) }} as country_id, -- hasheo el country
        {{ dbt_utils.generate_surrogate_key(['state']) }} as state_id, -- hasheo el state
        zipcode,
        address, 
        _fivetran_synced_utc 
    from source

)

select * from renamed
