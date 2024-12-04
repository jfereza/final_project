
{% set genres_col_names = ["blues","country","easy listening","electronic","folk","hip hop",
                           "jazz","pop","rb","soul","rock","metal","punk","reggaeton","trap",
                           "rap","rage"] %}


{{
  config(
    materialized='table'
  )
}}

with source as (
    select * 
    from {{ ref('base_spotify__top10_genres') }}

),

interm as ( -- si una canción tiene 1 en X genero, le da los puntos de su puntuación a ese genero
    select
        month_num,
        year,
        active_month,
        {% for genres_col in genres_col_names %} 
            sum({{genres_col | replace(" ", "_")}} * puntuation) as {{genres_col | replace(" ", "_")}} {% if not loop.last %},{% endif -%}
        {% endfor %}
    from source
    group by 1,2,3
),

interm2 as ( 
    select
        month_num as month,
        year,
        active_month,
        genre,
        puntuation
    from interm
    unpivot (
        puntuation for genre in (
            {% for genres_col in genres_col_names %}
                {{ genres_col | replace(" ", "_") }} 
                {% if not loop.last %},{% endif %}
            {% endfor %}
        )
    ) as unpvt
),

final as ( 
    select
        month,
        year,
        active_month,
        genre,
        puntuation
    from interm2
)

select * from final

