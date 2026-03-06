
# SQL Data Warehouse Project

## Overview

This project implements a **SQL-based Data Warehouse using PostgreSQL** designed to integrate, clean, and analyze organizational data collected from multiple CSV files.

The goal of this project is to demonstrate **core data engineering and data warehousing concepts using SQL**, including:

* Data ingestion from CSV files
* Data cleaning and transformation
* Layered data architecture (Bronze → Silver → Gold)
* Star schema data modeling
* Data quality validation

The data warehouse provides a structured foundation for **analytics, reporting, and business intelligence**.

---

# Architecture
 <img width="2888" height="3608" alt="image" src="https://github.com/user-attachments/assets/681275a0-9133-437a-853f-5aa49e4b89b8" />


The project follows a **modern layered data warehouse architecture**.

```
CSV Files
   ↓
Bronze Layer (Raw Data)
   ↓
Silver Layer (Cleaned & Standardized Data)
   ↓
Gold Layer (Analytics / Star Schema)
```

### Bronze Layer

* Stores **raw data loaded directly from CSV files**
* No transformations applied
* Acts as the **source of truth**

### Silver Layer

* Performs **data cleaning and validation**
* Standardizes formats
* Handles missing or incorrect values
* Applies business rules
  <img width="3524" height="2044" alt="image" src="https://github.com/user-attachments/assets/c181408a-87ed-4776-8986-418761a68c06" />


### Gold Layer

* Implements **analytics-ready data models**
* Uses **Star Schema**
* Designed for reporting and analysis
<img width="3524" height="2104" alt="image" src="https://github.com/user-attachments/assets/0422810a-4437-4311-985d-49e5401418a9" />

---

# Data Pipeline

The project implements a **SQL-based ETL pipeline**.

### 1. Extract

Raw data is collected from:

* CSV files exported from source systems.

### 2. Transform

Data is cleaned and standardized using SQL transformations.

Examples:

* Fixing invalid date formats
* Removing unwanted characters
* Handling NULL values
* Correcting negative values
* Standardizing categorical values

### 3. Load

Cleaned data is inserted into **Silver tables**, which are then used to build the **Gold analytical schema**.

---
<img width="2284" height="1608" alt="image" src="https://github.com/user-attachments/assets/826aa217-a256-42ae-8b40-53dff86ab09b" />


# Data Model

The Gold layer uses a **Star Schema** design.

```
                dim_date
                   |
dim_customer ---- fact_sales ---- dim_product
                   |
                dim_region
```
<img width="3352" height="2092" alt="image" src="https://github.com/user-attachments/assets/5e9a3661-9481-48d5-a13d-4d5552b8fd59" />


### Fact Table

Fact tables store **business metrics** used for analysis.


### Dimension Tables

Dimension tables store **descriptive attributes** that provide context.

Example:

**dim_customer**


**dim_product**


These allow analysis such as:

* Sales by region
* Sales by product category
* Sales trends over time

---

# Data Quality Checks

The project includes several **data validation checks** to ensure data reliability.

Examples of implemented checks:

* Detecting NULL or missing values
* Identifying invalid date formats
* Removing unwanted characters
* Handling negative numeric values
* Checking data consistency between fields

Example validation query:

```sql
SELECT *
FROM silver.crm_sales_details
WHERE sls_quantity < 0
   OR sls_price < 0;
```

These checks help maintain **clean and reliable analytical data**.

---

# Technologies Used

| Technology | Purpose                          |
| ---------- | -------------------------------- |
| PostgreSQL | Data warehouse database          |
| SQL        | Data transformation and modeling |
| Git        | Version control                  |
| Markdown   | Documentation                    |

---

# Data Sources

The warehouse integrates data from:

* Flat files (CSV)

Example datasets:

* Customer data
* Product data
* Sales transactions

---

# Setup Instructions

## 1. Prerequisites

Install:

* PostgreSQL
* Git

---

## 2. Clone the Repository

```bash
git clone https://github.com/Yaswanth332/Sql-DataWareHouse-Project-.git
cd Sql-DataWareHouse-Project-
```

---

## 3. Database Setup

1. Create a new PostgreSQL database
2. Run the DDL scripts to create schemas and tables
3. Load CSV files into Bronze tables

---

## 4. Run Data Transformation Scripts

Execute the SQL scripts that transform data from:

```
Bronze → Silver → Gold
call bronze.load_bronze()
call silver.load_silve()
```

---

# Example Analytical Query

Example: **Total sales by region**

```sql
SELECT
    d.region_name,
    SUM(f.sales_amount) AS total_sales
FROM fact_sales f
JOIN dim_region d
ON f.region_key = d.region_key
GROUP BY d.region_name
ORDER BY total_sales DESC;
```

---

# Project Structure

```
Sql-DataWareHouse-Project
│
├── database
├── docs
├── draw_io
├── scripts
│   ├── bronze
│   ├── silver
│   ├── gold
│   ├── init_database.sql
│
├── test
├── LICENSE
└── README.md
```

---

# Future Improvements

Possible improvements for this project include:

* Adding workflow orchestration (Airflow)
* Implementing incremental data loading
* Integrating BI tools such as Power BI or Tableau
* Adding automated data quality monitoring

---

# License

This project is licensed under the **MIT License**.

---

# Contact

**Yaswanth Krishna Jonnalagadda**

Email:
[yaswanthkrishnajonnalagadda@gmail.com](mailto:yaswanthkrishnajonnalagadda@gmail.com)


