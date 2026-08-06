
-- Grain: one row per customer_id

with source as (

    select * from {{ ref('stg_customers') }}

),

renamed as (
    select
        customer_id,
        brand,
        region,
        plan_meals,
        signup_week,
        in_experiment,
        got_discount

    from source
)

select * from renamed


