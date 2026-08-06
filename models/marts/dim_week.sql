
-- Grain: one row per week
-- I chose "distinct week" over a generated calendar, this is simpler and not hardcoded, but it skips weeks with no orders.
select distinct week from {{ref('stg_orders')}}