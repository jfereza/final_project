with 

source as (

    select * from {{ source('google_sheets', 'budget') }}

),

renamed as (

    select
        product_id,
        ifnull(quantity,0) as quantity, -- si es nulo, lo cambiamos a 0
        month(month)::number as month,
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc,
    from source
    order by
        3,1

)

select * from renamed
