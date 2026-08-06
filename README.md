# Meal-Kit dbt Pipeline

A dimensional data pipeline built on the same meal-kit subscription data as
`Project14_MealKit_Dashboard_Basic`, this time modeled the way a data
engineering team would: raw seeds → staging → dimensional marts, with tests
and CI enforcing correctness at every step.

Built for the Cheffelo Data Engineer application (Aug 2026). DuckDB stands in
for a warehouse like Databricks — the dbt code ports directly, only the
`profiles.yml` adapter changes.

## Setup (run these yourself — this is part of learning the tool)

```bash
cd Project15_MealKit_dbt_Pipeline
python3 -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install dbt-core dbt-duckdb
```

Create `profiles.yml` in this same folder (dbt looks for it via
`DBT_PROFILES_DIR` or `~/.dbt/`; keeping it local to the project is simplest
for a solo portfolio project):

```yaml
mealkit_pipeline:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: mealkit.duckdb
      threads: 4
```

Then, before running any dbt command, point dbt at this folder:

```bash
export DBT_PROFILES_DIR=.        # Windows (PowerShell): $env:DBT_PROFILES_DIR="."
```

## Commands, in the order you'll actually use them

```bash
dbt debug     # sanity-checks your connection/config — run this first, always
dbt seed      # loads seeds/customers.csv and seeds/orders.csv into DuckDB
dbt run       # builds the models (staging views, then mart tables)
dbt test      # runs every test in the *.yml files against the built models
dbt build     # does seed + run + test together, in dependency order — this
              # is the single command CI uses, and the one to reach for once
              # the project is past the exploratory stage
dbt docs generate && dbt docs serve   # generates a browsable dependency graph
                                       # of your whole pipeline — genuinely
                                       # worth screenshotting for your CV/portfolio
```

## Project status / your task list

- [x] Seeds copied from Project14 (`seeds/customers.csv`, `seeds/orders.csv`)
- [x] `stg_customers.sql` — worked example, read it closely
- [ ] `stg_orders.sql` — **your exercise**, same pattern as stg_customers
- [ ] `_staging_tests.yml` — one `relationships` test left as an exercise
- [ ] Mart layer: `dim_customer`, `dim_week`, `fact_orders` — see below
- [ ] `dbt build` passing locally
- [ ] Push to GitHub, confirm the Actions workflow goes green
- [ ] Write 3–4 sentences in this README on a modeling decision you made and why

## Mart layer — what to build next (Day 2–3)

This is the part that actually demonstrates "dimensional modeling," so think
before writing SQL. Sketch it on paper first:

**`fact_orders`** (grain: one row per order — state this explicitly in the
model's schema.yml description, because "grain" is the first question any
data engineer will ask about a fact table)
- Foreign keys: `customer_id` (→ dim_customer), `week` (→ dim_week)
- Measures: `n_meals`, `box_price_nok`, `delivered_on_time`

**`dim_customer`** (grain: one row per customer)
- `customer_id`, `brand`, `region`, `plan_meals`, `signup_week`,
  `in_experiment`, `got_discount`
- This is mostly a pass-through of `stg_customers` — dimensions are often
  simple. Resist the urge to over-engineer it.

**`dim_week`** (grain: one row per week number appearing in the data)
- Build this with a dbt `generate_series` macro or a simple `select distinct
  week from {{ ref('stg_orders') }}` — either is defensible; be ready to
  explain the trade-off (a generated calendar dimension covers weeks with
  zero orders, a distinct-based one doesn't).

Write each mart's grain as a one-line comment at the top of the SQL file,
the same way `stg_customers.sql` explains itself. If you can't state the
grain in one sentence, the model isn't finished being designed yet.

## Why DuckDB instead of Databricks

DuckDB is free, file-based, and needs no cloud account — perfect for a
portfolio project. The interview answer: "I used DuckDB locally because it's
zero-setup, but the dbt project itself is adapter-agnostic — pointing the
same models at Databricks or Snowflake is a `profiles.yml` change, not a
rewrite." This is true and is exactly the kind of platform-independence dbt
is designed to give you.
