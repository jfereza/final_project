{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('base_sql_server_dbo__orders') }}

),

iterm as (

    select
        distinct shipping_service as shipping_service 
    from 
        source 

),

renamed as (

    select
        shipping_service,
        case -- cambio el nombre del shipping service por un hash. Si es nulo lo dejo nulo    
            when shipping_service is null then shipping_service
            else {{ dbt_utils.generate_surrogate_key(['shipping_service']) }}
            end as shipping_service_id
    from 
        iterm 

)

select * from renamed
