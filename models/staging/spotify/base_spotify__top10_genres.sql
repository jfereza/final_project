
{% set genres_names = ["blues","country","easy listening","electronic","folk","hip hop",
                       "jazz","pop","r&b","soul","rock","metal","punk","reggaeton","trap",
                       "rap","rage"] %}
{% set genres_col_names = ["blues","country","easy listening","electronic","folk","hip hop",
                           "jazz","pop","rb","soul","rock","metal","punk","reggaeton","trap",
                           "rap","rage"] %}
{% set month_list = ["january","february","march", "april","may","june","july","august",
                     "september","october","november","december"] %}


{{
  config(
    materialized='table'
  )
}}

with source as (
    select * 
    from {{ source('spotify', 'top10_genres') }}

),

month_punt_column as (
    select
        top,
        (11 - top) as puntuation, -- esta columna da puntuacion 10 al top 1 y puntuación 1 al top 10.
        song,
        author,
        genre as all_genres,
        month as month_name,
        case -- añadimos los numeros de los meses
            {% for month_num in range(1, 13) %}
                when month = '{{ month_list[month_num - 1] }}' then {{ month_num }}
            {% endfor %}
        end as month_num,
        year
    from source
),

date_column as (
    select
        top,
        puntuation,
        song,
        author,
        all_genres,
        month_name,
        month_num,
        year,
        to_date(concat(year, '-', month_num, '-01'), 'YYYY-MM-DD') as active_month -- añadimos una fecha
    from month_punt_column
),

genres_column as ( -- añadimos, para cada genero, una columna.
    select
        top,
        puntuation, 
        song,
        author,
        all_genres,
        month_name,
        month_num,
        year,
        active_month,
        {% for genres_col, genre in zip(genres_col_names, genres_names) %} -- para cada genero de la lista, una columna
            case 
                when all_genres like concat('%', '{{genre}}', '%') then 1 -- buscamos cualquier coincidencia
                else 0
                end as {{genres_col | replace(" ", "_")}}{% if not loop.last %},{% endif -%} -- los nombres de columna no tienen espacios
        {% endfor %}
    from date_column
),

final as ( 
    select
        top,
        puntuation, 
        song,
        author,
        all_genres,
        month_name,
        month_num,
        year,
        active_month,
        {% for genres_col in genres_col_names %} 
            {{genres_col | replace(" ", "_")}}{% if not loop.last %},{% endif -%}
        {% endfor %}
    from genres_column
)


select * from final

