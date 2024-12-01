{% snapshot snp_plant_shop__products %}

{{
    config(
      target_schema='snapshots',
      unique_key='product_id',
      strategy='timestamp',
      updated_at='updated_at',
    )
}}

select * from {{ source('plant_shop', 'products') }}

{% endsnapshot %}
