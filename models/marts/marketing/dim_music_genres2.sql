{{
  config(
    materialized='table'
  )
}}

with source as (
    select * 
    from {{ ref('stg_spotify__genres_puntuation_v2') }}

)

select * from source

