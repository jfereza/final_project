{% snapshot budget_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='product_id',
      strategy='timestamp',
      updated_at='month',
    )
}}

select * from {{ source('plant_shop', 'budget') }}

{% endsnapshot %}
