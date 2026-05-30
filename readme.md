# Healthcare Claims Analytics Platform

## Overview

The Healthcare Claims Analytics Platform is an end-to-end modern data engineering project that demonstrates how healthcare claims data can be ingested, transformed, validated, monitored, and orchestrated using industry-standard technologies.

The project implements a Medallion Architecture using Databricks and Delta Lake, loads curated data into Snowflake, transforms data using dbt, orchestrates workflows using Apache Airflow and Astronomer Cosmos, and validates data quality through automated observability checks.

This project simulates a production-grade healthcare analytics environment using Synthea synthetic healthcare data.

---

## Architecture Diagram

![Architecture Diagram](databricks\architecture-diagram.png)

---

## Business Problem

Healthcare organizations generate large volumes of claims, encounter, patient, provider, and observation data.

Common challenges include:

* Duplicate records
* Late-arriving data
* Inconsistent data quality
* Missing reconciliation controls
* Lack of observability
* Limited historical tracking

This platform solves these challenges through automated ingestion, transformation, validation, and orchestration.

---

## Technology Stack

| Layer             | Technology                   |
| ----------------- | ---------------------------- |
| Data Source       | Synthea Healthcare Data      |
| Processing        | Databricks                   |
| Storage           | Delta Lake                   |
| Warehouse         | Snowflake                    |
| Transformation    | dbt                          |
| Orchestration     | Apache Airflow               |
| dbt Orchestration | Astronomer Cosmos            |
| Data Quality      | dbt Tests + dbt Expectations |
| CI/CD             | GitHub Actions               |
| Language          | SQL + Python                 |
| Version Control   | GitHub                       |

---

# Solution Architecture

## Databricks Bronze Layer

Purpose:

* Raw ingestion of healthcare datasets
* Metadata enrichment
* Immutable storage

Features:

* Batch ingestion from Parquet files
* Metadata columns

Examples:

* ingestion_timestamp
* batch_id
* source_system

Tables:

* claims
* patients
* providers
* encounters
* conditions
* observations

---

## Databricks Silver Layer

Purpose:

* Data cleansing
* Standardization
* Deduplication

Features:

* Row-number deduplication
* Merge/Upsert strategy
* Quarantine handling
* Late-arriving data support

Tables:

* claims
* claims_quarantine
* patients
* providers
* encounters
* conditions
* observations

---

## Databricks Gold Layer

Purpose:

Business-ready analytical models.

Fact Tables:

* fact_claims
* fact_encounters
* fact_observations

Dimension Tables:

* dim_patient
* dim_providers
* dim_date
* dim_condition
* dim_encounters

Features:

* Star schema design
* Optimized analytical reporting

---

## Snowflake Data Warehouse

Database:

```text
HEALTHCARE_DEV
```

Schemas:

```text
RAW
STRUCTURED
ANALYTICS
OBSERVABILITY
```

RAW Tables:

* DIM_PATIENT
* DIM_PROVIDERS
* DIM_ENCOUNTERS
* DIM_DATE
* FACT_CLAIMS
* FACT_ENCOUNTERS
* FACT_OBSERVATIONS

---

## dbt Transformation Layer

Implemented Features:

### Sources

* source()

### Model Dependencies

* ref()

### Staging Models

* stg_dim_patient
* stg_dim_provider
* stg_dim_date
* stg_fact_claims
* stg_fact_encounters
* stg_fact_observations

### Intermediate Models

* int_claim_summary

### Snapshots

* snap_provider_snapshot

Features:

* Incremental Models
* Merge Strategy
* Sliding Lookback Logic
* Source Freshness
* SCD Type 2 Tracking
* Documentation

---

## Data Quality Framework

Implemented Tests:

### Generic Tests

* not_null
* unique
* relationships
* accepted_values

### Advanced Tests

* dbt_expectations

### Freshness Tests

* source freshness

---

## Observability Framework

Implemented Models:

### Reconciliation

* claim_count_reconciliation
* claim_amount_reconciliation
* patient_reconciliation
* provider_reconciliation

### Monitoring

* claims_freshness_monitoring

### Anomaly Detection

* claim_amount_anomaly_check

Features:

* Row-count validation
* Amount validation
* Freshness monitoring
* Data anomaly detection

---

## Airflow Orchestration

Implemented Using:

* Apache Airflow
* Astronomer Cosmos

DAGs:

### healthcare_dbt_cosmos_pipeline

Runs:

* dbt run
* dbt test
* dbt snapshot

### healthcare_source_freshness

Runs:

* dbt source freshness

### healthcare_dbt_docs

Runs:

* dbt docs generate

Features:

* Task dependencies
* Retries
* Email alerts
* Failure notifications

---

## CI/CD Pipeline

GitHub Actions Workflow:

### dbt CI

Runs:

```bash
dbt deps
dbt debug
dbt parse
dbt build
```

Features:

* Automated validation
* Pull request checks
* Build verification

---

## Project Structure

```text
healthcare-claims-platform
│
├── databricks/
│
├── dbt/
│   ├── models/
│   ├── snapshots/
│   ├── tests/
│   └── macros/
│
├── airflow/
│   ├── dags/
│
├── github/
│
├── docs/
│
└── README.md
```

---

## Key Achievements

✔ Implemented Medallion Architecture

✔ Built Delta Lake Bronze, Silver, Gold layers

✔ Implemented Merge/Upsert Pipelines

✔ Built Snowflake Analytics Layer

✔ Implemented dbt Incremental Models

✔ Implemented dbt Snapshots (SCD Type 2)

✔ Implemented Source Freshness Monitoring

✔ Built Data Quality Framework

✔ Built Observability Framework

✔ Orchestrated with Airflow + Cosmos

✔ Automated CI/CD with GitHub Actions

---

# Interview Story

### Problem

Healthcare claims data required reliable ingestion, transformation, historical tracking, and monitoring.

### Challenge

The platform needed to handle:

* Duplicate records
* Late-arriving data
* Historical tracking
* Automated validation
* Operational monitoring

### Solution

Implemented:

* Databricks Medallion Architecture
* Snowflake Data Warehouse
* dbt Transformations
* dbt Snapshots
* Airflow Orchestration
* Observability Framework
* GitHub CI/CD

### Impact

Delivered a production-style healthcare analytics platform with:

* Automated testing
* Historical tracking
* Reconciliation checks
* Monitoring and alerting
* End-to-end orchestration

---

## Author

Muhammad Afzal

Senior Data Engineer

Technologies:

Databricks | Delta Lake | Snowflake | dbt | Airflow | Python | SQL | GitHub Actions
