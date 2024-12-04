{{
  config(
    materialized='table'
  )
}}

with source as (
    select * 
    from {{ ref('base_spotify__top10_genres') }}

),

interm as ( -- si una canción que se repite X veces tiene N,M... puntos, le damo X*(N+M) puntos en total
    select
        month_num as month,
        year,
        active_month,
        song,
        author,
        count(song) as times,
        count(song)*sum(puntuation) as total_puntuation
    from source
    group by 1,2,3,4,5
    order by active_month ASC, total_puntuation DESC, times DESC
),

final as ( 
    select
        month,
        year,
        active_month,
        song,
        author,
        times,
        total_puntuation
    from interm
)

select * from final

