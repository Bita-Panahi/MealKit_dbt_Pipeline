
-- Grain: one row per order_id

with source as (
    select * from {{ ref('stg_orders')}}

),

renamed as (
    select
        order_id,
        customer_id,
        week,
        n_meals,
        box_price_nok,
        box_price_nok / nullif(n_meals, 0) as price_per_meal_nok,
        delivered_on_time

    from source
)

select * from renamed