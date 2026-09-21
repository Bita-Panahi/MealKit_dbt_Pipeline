
with source as (
    select * from {{ ref('orders') }}

),

renamed as (

    select 
        order_id,
        customer_id,
        week,
        n_meals,
        box_price_nok,
        cast(delivered_on_time as boolean) as delivered_on_time

    from source

)

select * from renamed