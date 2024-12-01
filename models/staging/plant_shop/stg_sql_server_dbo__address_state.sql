{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_sql_server_dbo__addresses') }}

),

interm as (

    select
        distinct state as state
    from source

),

renamed as (

    select
        state,
        {{ dbt_utils.generate_surrogate_key(['state']) }} as state_id
    from interm

)

select * from renamed
