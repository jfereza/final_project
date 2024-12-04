{{
  config(
    materialized='table'
  )
}}

with source as (
    select * 
    from {{ ref('stg_spotify__song_puntuation') }}

)

select * from source

