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
        distinct lower(status) as status -- selecciono los tipos de status distintos y los pongo en minus
    from source 

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['status']) }} as status_id, -- hasheo el status
        status as status
    from 
        iterm 

)

select * from renamed
