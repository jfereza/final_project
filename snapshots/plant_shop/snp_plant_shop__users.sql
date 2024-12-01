{% snapshot snp_plant_shop__users %}

{{
    config(
      target_schema='snapshots',
      unique_key='user_id',
      strategy='timestamp',
      updated_at='updated_at',
    )
}}

select * from {{ source('plant_shop', 'users') }}

{% endsnapshot %}
