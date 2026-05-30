I couldn't extract notebook cells reliably from the uploaded `.ipynb`, but based on the code we built and the issues we already fixed, here is the **clean production Databricks notebook** with unnecessary/debug cells removed and proper ordering.

Notebook name:

```text
claims_silver_production
```

# Cell 1 — Imports

```python
from pyspark.sql.functions import *
from pyspark.sql.window import Window
from delta.tables import DeltaTable
```

Why:

```text
Single import location
```

---

# Cell 2 — Read Bronze Claims

```python
claims = spark.table(
    "healthcare_dev.bronze.claims"
)
```

Why:

```text
Read source once
```

---

# Cell 3 — Deduplicate Source

```python
window_spec = (
    Window
    .partitionBy("claim_id")
    .orderBy(
        col("event_time").desc()
    )
)

claims_clean = (

    claims

    .withColumn(
        "rn",
        row_number().over(window_spec)
    )

    .filter(
        col("rn")==1
    )

    .drop("rn")
)
```

Why:

```text
Keep latest version per claim
```

Benefit:

```text
Avoid duplicate KPIs
```

---

# Cell 4 — Quarantine Late Records

```python
claims_late = (

    claims_clean

    .filter(
        col("is_late_simulated")==True
    )

)

claims_valid=(

    claims_clean

    .filter(
        col("is_late_simulated")==False
    )

    .drop(
        "is_late_simulated"
    )

)
```

Why:

```text
Remove delayed records from analytics
```

Benefit:

```text
Stable downstream reporting
```

---

# Cell 5 — Add Incremental Metadata

```python
claims_valid=(

claims_valid

.withColumn(
    "updated_at",
    col("ingestion_timestamp")
)

)
```

Why:

```text
MERGE requires latest-version timestamp
```

Benefit:

```text
Incremental processing
```

---

# Cell 6 — Write Silver Tables

```python
(
claims_valid.write

.format("delta")

.mode("overwrite")

.option(
    "overwriteSchema",
    "true"
)

.saveAsTable(
"healthcare_dev.silver.claims"
)
)

(
claims_late.write

.format("delta")

.mode("overwrite")

.saveAsTable(
"healthcare_dev.silver.claims_quarantine"
)
)
```

Why:

```text
Persist clean and quarantine datasets
```

---

# Cell 7 — Simulate Incoming CDC Batch

```python
incoming_claims=(

spark.table(
"healthcare_dev.bronze.claims"
)

.withColumn(
"updated_at",
current_timestamp()
)

)
```

Why:

```text
Simulate new API data arriving
```

---

# Cell 8 — Simulate Corrections

Replace IDs with real ones:

```python
incoming_claims=(

incoming_claims

.withColumn(

"claim_amount",

when(

col("claim_id").isin(

"00001843-fe30-4a9f-9b9e-e3002013554f",
"0001abba-75b2-4ee7-9087-fd1db77da3f9",
"00021f77-1dfe-44f4-a161-bbfe8f0d9d13"

),

col("claim_amount")+200

)

.otherwise(
col("claim_amount")
)

)

)
```

Why:

```text
Simulate claim correction scenario
```

---

# Cell 9 — Deduplicate Incoming Source

```python
window_spec=(

Window

.partitionBy(
"claim_id"
)

.orderBy(
col("updated_at").desc()
)

)

incoming_claims_dedup=(

incoming_claims

.withColumn(
"rn",
row_number().over(
window_spec
)
)

.filter(
col("rn")==1
)

.drop("rn")

)
```

Why:

```text
Required before MERGE
```

Benefit:

```text
Avoid DELTA_MULTIPLE_SOURCE_ROW_MATCHING
```

---

# Cell 10 — MERGE

```python
silver=DeltaTable.forName(
spark,
"healthcare_dev.silver.claims"
)

(
silver.alias("target")

.merge(

incoming_claims_dedup.alias("source"),

"""
target.claim_id =
source.claim_id
"""

)

.whenMatchedUpdate(

condition=
"""
source.updated_at >
target.updated_at
""",

set={

"claim_amount":
"source.claim_amount",

"updated_at":
"source.updated_at"

}

)

.whenNotMatchedInsertAll()

.execute()
)
```

---

# Cell 11 — Validation

```sql
SELECT
claim_id,
COUNT(*) cnt

FROM healthcare_dev.silver.claims

GROUP BY claim_id

HAVING COUNT(*)>1
```

Expected:

```text
0 rows
```

---

Delete these notebook cells:

```text
claims.count()

claims.columns

claims_clean.count()

claims_valid.columns

show()

display()

LIMIT checks

max(event_time)

temporary inspection cells

late_claim_ids cells
```

Those were useful while debugging but should not remain in production notebooks.

Final flow:

```text
Bronze
 ↓
Deduplicate
 ↓
Quarantine
 ↓
Silver
 ↓
CDC batch
 ↓
Source dedup
 ↓
MERGE
 ↓
Validation
```

This is the notebook version I'd actually keep in a production-style repository.
