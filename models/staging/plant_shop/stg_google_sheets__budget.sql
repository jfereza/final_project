with 

source as (

    select * from {{ source('google_sheets', 'budget') }}

),

renamed as (

    select
        product_id,
        quantity,
        month(month)::number as month,
        convert_timezone('UTC', _fivetran_synced) as _fivetran_synced_utc,
    from source
    order by
        3,1

)

select * from renamed
