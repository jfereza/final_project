{{
  config(
    materialized='table'
  )
}}

with source as (
    select * 
    from {{ ref('stg_spotify__genres_puntuation_v1') }}

)

select * from source

