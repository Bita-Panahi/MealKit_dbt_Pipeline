
with source as (

    select * from {{ ref('customers') }}

),

renamed as (

    select
        customer_id,
        brand,
        region,
        plan_meals,
        signup_week,
        cast(in_experiment as boolean) as in_experiment,
        cast(got_discount as boolean)  as got_discount

    from source

)

select * from renamed
