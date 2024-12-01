{{
  config(
    materialized='table',
    pre_hook="alter session set week_start = 1;"
  )
}}

with 

time_spine as (
    {{ dbt_utils.date_spine(
        datepart='day',
        start_date="cast('2020-01-01' as date)",  
        end_date="cast('2024-12-31' as date)"
    ) }}
),

renamed as (

    select
        date_day as date,              -- fecha
        year(date_day) as year,        -- año
        month(date_day) as month,      -- mes
        monthname(date_day) as month_name,      -- mes
        day(date_day) as day,          -- día
        quarter(date_day) as quarter,  -- trimestre
        dayofweek(date_day) as day_of_week,
        case
            when dayofweek(date_day) = 1 then 'sunday'
            when dayofweek(date_day) = 2 then 'monday'
            when dayofweek(date_day) = 3 then 'tuesday'
            when dayofweek(date_day) = 4 then 'wednesday'
            when dayofweek(date_day) = 5 then 'thursday'
            when dayofweek(date_day) = 6 then 'friday'
            when dayofweek(date_day) = 7 then 'saturday'
            end as day_of_week_name,                      -- día de la semana
        case
            when month(date_day) in (12, 1, 2) then 'q1'
            when month(date_day) in (3, 4, 5) then 'q2'
            when month(date_day) in (6, 7, 8) then 'q3'
            when month(date_day) in (9, 10, 11) then 'q4'
            end as fiscal_quarter,                   -- trimestre fiscal (puedes ajustarlo)
        week(date_day) as week,         -- semana del año
        dayofyear(date_day) as day_of_year  -- día del año
    from time_spine

)

select * from renamed