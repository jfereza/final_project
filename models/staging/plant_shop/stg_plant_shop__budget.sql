{{
  config(
    materialized='table'
  )
}}

with 

source as (

    select * from {{ ref('snp_plant_shop__budget') }}

),

final as (

    select
        product_id,
        quantity::number as quantity,
        month as updated_at, -- renombro la columna
        convert_timezone('UTC', dbt_valid_from) as _snp_first_ingest_utc, -- renombro la columna y convierto la zona horaria
        convert_timezone('UTC', dbt_valid_to) as _snp_invalid_from_utc, -- renombro la columna y convierto la zona horaria
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc, -- convierto la zona horaria
    from source
    order by  3,1 -- lo ordeno por meses y por productos

)

select * from final
