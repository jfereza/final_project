{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('stg_sql_server_dbo__events') }}

),

renamed as (

    select
        product_id
    from source

)

select * from renamed