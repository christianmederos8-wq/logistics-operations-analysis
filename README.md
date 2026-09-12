# Logistics Operations & Fleet Performance Analysis

## Project Overview

This project analyzes the operations of a logistics and transportation company using a multi-table relational dataset.

The analysis focuses on revenue performance, route efficiency, fuel consumption, fleet maintenance, delivery reliability, driver safety, and operational performance.

The project follows a complete analytics workflow:

**Raw Data → MySQL Database → Data Quality → Exploratory Analysis → KPIs → Business Questions → Power BI**

The objective is to transform operational logistics data into actionable business insights that can support decisions related to cost control, fleet efficiency, delivery performance, customer management, and operational risk.

---

## Business Problem

A logistics company manages thousands of loads, trips, fuel purchases, maintenance events, delivery operations, and safety incidents.

Management needs better visibility into several key areas:

- Which customers and routes generate the most revenue?
- Which routes generate the most revenue per mile?
- Are actual trip distances significantly different from expected route distances?
- Which routes operate with the lowest fuel efficiency?
- Which trucks generate the highest maintenance costs and downtime?
- Does truck age appear related to fuel efficiency or maintenance cost?
- Where are delivery delays and detention concentrated?
- Which routes have the weakest on-time delivery performance?
- Which drivers present the highest preventable incident rates?

---

## Project Objectives

The main objective is to identify opportunities to improve:

- Operational efficiency
- Revenue performance
- Fleet utilization
- Fuel efficiency
- Maintenance management
- Delivery reliability
- Customer and route performance
- Driver safety

---

## Tools & Technologies

- **MySQL** — Database creation, data validation, exploratory analysis, KPIs and business analysis
- **SQL** — Joins, aggregations, CTEs, subqueries, CASE statements and window functions
- **Power BI** — Data modeling, DAX measures and dashboard development
- **Git** — Version control
- **GitHub** — Project documentation and portfolio presentation

---

## Dataset

The dataset represents the operations of a logistics and transportation company.

The relational database contains the following tables:

- Customers
- Drivers
- Trucks
- Trailers
- Facilities
- Routes
- Loads
- Trips
- Fuel Purchases
- Maintenance Records
- Delivery Events
- Safety Incidents
- Driver Monthly Metrics
- Truck Utilization Metrics

### Main Dataset Volumes

| Table | Records |
|---|---:|
| Loads | 85,410 |
| Trips | 85,410 |
| Fuel Purchases | 196,442 |
| Delivery Events | 170,820 |
| Maintenance Records | 2,920 |
| Safety Incidents | 168 |
| Customers | 200 |
| Drivers | 150 |
| Trucks | 120 |
| Routes | 58 |
| Facilities | 50 |

The main operational period analyzed covers **2022–2024**.

---

## Database Relationships

The main relationships used in the analysis include:

```text
Customers
    |
    | customer_id
    v
Loads
    |
    | load_id
    v
Trips
    |
    ├── Drivers
    ├── Trucks
    ├── Trailers
    ├── Fuel Purchases
    ├── Delivery Events
    └── Safety Incidents

Loads
    |
    | route_id
    v
Routes

Delivery Events
    |
    | facility_id
    v
Facilities

```

One important consideration throughout the analysis was avoiding **row multiplication** when joining multiple one-to-many transactional tables.

For this reason, fuel purchases, delivery events, maintenance records and safety incidents were aggregated at the appropriate grain before being combined with other datasets.

---

## Data Quality

A dedicated data quality process was performed before analysis.

The validation included:

- Row-count verification
- Primary key checks
- Duplicate detection
- NULL analysis
- Referential integrity checks
- Numerical range validation
- Date consistency
- Category validation
- Maintenance cost consistency
- Delivery event validation

### Data Quality Decisions

Some trip records referenced driver, truck or trailer IDs that were not available in the corresponding master tables.

These records were preserved, while invalid foreign keys were converted to `NULL` to avoid losing valid operational trips.

Additional observations included:

- Some fuel purchase records contained missing driver or truck references.
- 168 safety incidents were retained for analysis.
- Some trips recorded idle time greater than trip duration, so idle-time metrics are interpreted cautiously.
- Geographic fields in some transactional tables contained inconsistencies and were not used as primary geographic dimensions.

---

## Exploratory Data Analysis

Exploratory analysis was performed to understand the structure and behavior of the business before answering specific business questions.

### Operational Volume

The company handled approximately:

- **28.6K loads in 2022**
- **28.2K loads in 2023**
- **28.7K loads in 2024**

Monthly activity remained relatively stable.

February showed lower monthly load counts, but average daily volume indicated that this was largely explained by the smaller number of calendar days rather than a major seasonal decline.

### Revenue Overview

Total company revenue during the analyzed period was:

**262.53M**

Average revenue per load was:

**3,073.71**

Annual revenue remained relatively stable between 2022 and 2024.

Dry Van and Refrigerated freight also showed very similar average revenue per load.

---

## Core KPIs

Twelve core KPIs were defined in SQL.

| KPI | Result |
|---|---:|
| Total Loads | 85,410 |
| Total Revenue | 262.53M |
| Average Revenue per Load | 3,073.71 |
| Total Miles | 122.16M |
| Average MPG | 6.45 |
| Average Idle Hours | 7.01 |
| On-Time Delivery Rate | 44.61% |
| Average Delivery Detention | 106.60 min |
| Total Fuel Cost | 95.59M |
| Fuel Cost per Mile | 0.87 |
| Total Maintenance Cost | 5.73M |
| Total Maintenance Downtime | 72,230.50 hours |

These KPIs provide a high-level view of financial, operational and fleet performance.

---

# Business Questions & Key Findings

## 1. Which customers generate the most revenue?

**XYZ Foods** generated the highest revenue at approximately **1.54M**.

However, the largest customer represented only **0.59%** of total revenue.

The top 10 customers combined accounted for approximately **5.7% of total company revenue**.

### Insight

Revenue is broadly distributed across the customer base, suggesting relatively low customer concentration risk.

---

## 2. Which routes generate the most revenue?

The highest-revenue route was:

**Philadelphia, PA → Seattle, WA**

Revenue:

**10.07M**

Revenue share:

**3.84%**

The top 10 routes generated approximately **34.4% of total company revenue**.

### Insight

Revenue is significantly more concentrated by route than by customer.

---

## 3. Which routes generate the highest and lowest revenue per mile?

The route with the highest revenue per mile was:

**Philadelphia, PA → New York, NY**

Revenue per mile:

**2.72**

One of the lowest-performing routes was:

**Las Vegas, NV → New York, NY**

Revenue per mile:

**1.48**

### Insight

High total revenue does not necessarily mean high revenue efficiency.

Long-distance routes can generate large total revenue while producing lower revenue per mile.

Revenue per mile should not be interpreted as profitability because operating costs are not deducted.

---

## 4. How does actual distance compare with typical route distance?

Actual trip distances were consistently higher than typical route distances.

Most routes showed approximately:

**2.4%–3.1% additional distance**

The largest absolute difference appeared on:

**Miami, FL → Seattle, WA**

with approximately:

**88.72 additional miles per trip**

### Insight

The percentage deviation was relatively consistent across routes, suggesting a systematic difference between planned and actual distance rather than isolated route inefficiency.

---

## 5. Which routes have the lowest fuel efficiency?

Fuel efficiency was calculated using:

```text
Total Actual Miles / Total Fuel Gallons Used
```

The lowest-performing routes were around:

**6.42–6.44 MPG**

### Insight

Fuel efficiency was very consistent across routes, with no single route showing unusually poor fuel performance.

---

## 6. Which trucks generate the highest maintenance cost and downtime?

The most critical truck was:

**TRK00003 — Peterbilt, 2018**

Maintenance cost:

**90.16K**

Downtime:

**1,133.10 hours**

It ranked first in both maintenance cost and downtime.

### Insight

Maintenance cost and downtime do not always move together.

Some trucks generated high maintenance costs without similarly high downtime, while others experienced significant downtime with comparatively lower costs.

Both metrics should therefore be evaluated together.

---

## 7. Does truck age appear related to MPG or maintenance cost?

Fuel efficiency remained extremely stable across model years:

**6.42–6.46 MPG**

Maintenance costs also showed no consistent relationship with model year.

The 2021 model showed a high average maintenance cost, but only one truck belonged to that group.

### Insight

Truck age does not appear to be a strong standalone predictor of fuel efficiency or maintenance cost in this dataset.

---

## 8. Where are delivery delays and detention concentrated?

The highest delay rate was recorded at:

**Indianapolis Warehouse — 58.08%**

However, most facilities showed delay rates between approximately:

**52%–58%**

Average detention was generally around:

**102–110 minutes**

### Insight

Delivery delays and detention are broadly distributed across facilities rather than concentrated in a small number of locations.

This suggests a broader operational issue.

---

## 9. Which routes have the weakest on-time delivery performance?

The lowest on-time delivery rate was recorded on:

**Seattle, WA → Charlotte, NC**

On-time rate:

**42.40%**

The lowest-performing routes were generally between:

**42%–43% on-time delivery**

### Insight

The similarity between routes suggests that low delivery reliability is a systemic operational issue rather than a problem isolated to specific routes.

---

## 10. Which drivers have the highest preventable incident rate?

The highest preventable incident rates were recorded by:

- Richard Hernandez
- David Miller

Both recorded:

**0.32 preventable incidents per 100,000 miles**

### Insight

Exposure-adjusted incident rates provide a more meaningful comparison than raw incident counts.

The absolute number of incidents remained low, so small differences should be interpreted cautiously.

---

## Data Prepared for Power BI

SQL analysis outputs were exported into two data layers.

### Processed Data

Detailed datasets used for the Power BI data model:

```text
fact_operations.csv
customers.csv
routes.csv
drivers.csv
trucks.csv
facilities.csv
delivery_events.csv
fuel_purchases.csv
maintenance_records.csv
safety_incidents.csv
```

`fact_operations.csv` combines the `loads` and `trips` tables at a one-load / one-trip grain.

### Analytical Datasets

Five additional analytical datasets were created from the SQL business analysis:

```text
customer_performance.csv
route_performance.csv
truck_maintenance_performance.csv
facility_delivery_performance.csv
driver_safety_performance.csv
```

These datasets contain aggregated metrics derived from the business questions and are designed to support Power BI visualizations and further analysis.

---

## SQL Project Structure

```text
sql/
├── 00_database_setup.sql
├── 01_create_tables.sql
├── 02_load_data.sql
├── 03_data_quality.sql
├── 04_data_exploration.sql
├── 05_kpis.sql
└── 06_business_questions.sql
```

### `00_database_setup.sql`

Creates and selects the project database.

### `01_create_tables.sql`

Creates the relational database structure and table definitions.

### `02_load_data.sql`

Loads the raw CSV files into MySQL.

### `03_data_quality.sql`

Validates data quality, duplicates, missing values, relationships and numerical consistency.

### `04_data_exploration.sql`

Explores operational volume, revenue, customers, routes, fuel, maintenance, delivery performance, safety, drivers and fleet composition.

### `05_kpis.sql`

Defines the twelve main business and operational KPIs.

### `06_business_questions.sql`

Answers the ten main business questions using SQL analysis.

---

## Repository Structure

```text
logistics-operations-analysis/
│
├── README.md
├── .gitignore
│
├── data/
│   ├── raw/
│   ├── processed/
│   └── analysis/
│
├── docs/
│   └── DATABASE_SCHEMA.txt
│
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_load_data.sql
│   ├── 03_data_quality.sql
│   ├── 04_data_exploration.sql
│   ├── 05_kpis.sql
│   └── 06_business_questions.sql
│
├── powerbi/
│
└── images/
```

Raw and processed datasets are excluded from version control.

---

## Power BI Dashboard

The next stage of the project is the development of an interactive Power BI dashboard.

The dashboard will be organized into four analytical areas:

### Executive Overview

High-level financial and operational KPIs.

### Customers & Routes

Revenue performance, route efficiency and customer contribution.

### Fleet & Costs

Fuel efficiency, maintenance costs, downtime and fleet performance.

### Delivery & Safety

On-time delivery, detention, facility performance and safety indicators.

Dashboard screenshots and DAX measures will be added once development is complete.

---

## Project Status

- [x] Database creation
- [x] Data loading
- [x] Data quality validation
- [x] Exploratory data analysis
- [x] KPI development
- [x] Business question analysis
- [x] Power BI data preparation
- [ ] Power BI data model
- [ ] DAX measures
- [ ] Dashboard development
- [ ] Final business recommendations
- [ ] Final project documentation

---

## Author

**Christian Mederos**

Industrial Engineer | Data Analyst

Skills demonstrated in this project:

**SQL · MySQL · Data Analysis · Data Quality · Business Intelligence · Power BI · Git · GitHub**