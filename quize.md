DBT INTERVIEW + LEARNING SESSION
Question 1
Q1 — source() vs ref()

You already used both.

Now answer this like a real interview.

QUESTION

In dbt:

What is the difference between:
{{ source('raw', 'FACT_CLAIMS') }}

and

{{ ref('stg_fact_claims') }}
Also explain:
Why both are needed
What dbt does internally with each
Which layer usually uses source()
Which layer usually uses ref()
What breaks if you hardcode table names instead
Production Scenario

Suppose a developer writes:

select * from HEALTHCARE_DEV.RAW.FACT_CLAIMS

instead of:

{{ source('raw','FACT_CLAIMS') }}
What production problems can this create?

Answer as if you're in a Senior Data Engineer interview.

Correct ✅

Why B is correct

Just setting:

{{ config(materialized='incremental') }}

does NOT automatically tell dbt:

Which rows are new?
Which rows changed?

dbt needs incremental logic.

What Happens Here?

Model:

{{ config(materialized='incremental') }}

select *
from {{ ref('stg_fact_claims') }}

No filter.

No watermark.

No merge condition.

No business key.

Result

Every run reads:

Entire stg_fact_claims

Again and again.

On small datasets:

Looks fine

On production datasets:

Millions/Billions of rows
Slow runtime
High Snowflake cost
Warehouse pressure
Production Mindset

An incremental model needs TWO things:

1. Incremental Materialization
{{ config(materialized='incremental') }}
2. Incremental Logic

Example:

{% if is_incremental() %}

where updated_at >
(
    select max(updated_at)
    from {{ this }}
)

{% endif %}

Without #2, you don't get the real benefit.

Interview Tip

If an interviewer asks:

"Does materialized='incremental' automatically know which rows are new?"

Answer:

No.

The model must provide incremental logic using
is_incremental(), merge conditions, watermarks,
or another strategy.

That is a strong senior-level answer.

Why others are wrong
A) ❌

dbt cannot magically determine new rows.

C) ❌

dbt does not create watermarks automatically.

You must define them.

D) ❌

Incremental models and snapshots are completely different concepts.

Question 20 — MCQ
Which dbt artifact is MOST useful for visualizing model lineage and dependencies?
A)

manifest.json

B)

packages.yml

C)

profiles.yml

D)

schema.yml

Reply with:

A
B
C
D
D

Not quite ❌

The correct answer is:

A) manifest.json ✅
Why A is correct

manifest.json is the most important dbt artifact.

It contains:

Models
Sources
Tests
Macros
Dependencies
Lineage
Refs
Metadata

dbt uses it to understand the entire project graph.

When you run:

dbt docs generate

dbt creates:

manifest.json
catalog.json

and the lineage graph is built primarily from:

manifest.json
Production Usage

Many enterprise tools read:

manifest.json

Examples:

dbt Docs
CI/CD validation
DataHub
OpenMetadata
Monte Carlo
Atlan

because it contains the DAG information.

Why D is wrong
schema.yml

Very important, but it mainly stores:

models:
  - name: stg_fact_claims
    tests:
      - unique
      - not_null

Things like:

tests
descriptions
documentation

It does not contain the complete dependency graph.

Why others are wrong
B) packages.yml ❌

Only manages package dependencies.

Example:

dbt_utils
dbt_expectations
dbt_date
C) profiles.yml ❌

Stores connection configuration.

Example:

account:
database:
warehouse:
schema:
Interview Tip

If asked:

"What file contains the compiled dependency graph?"

Strong answer:

manifest.json

because dbt records all refs, sources, tests, models, and lineage there.