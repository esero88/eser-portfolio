# 🏦 Bank Customer Segmentation & Data Warehouse Project

---

## 📌 Project Overview

This project builds an end-to-end **banking analytics platform** using transactional banking data.

Raw transactional data is transformed into a **Kimball-based dimensional data warehouse**, enriched with business-driven logic, and prepared for **customer analytics, behavioral segmentation, and BI reporting**.

The project simulates real-world banking analytics workflows including:

- Data Cleaning
- Feature Engineering
- Dimensional Modeling
- Data Enrichment
- Analytical Data Mart Design
- Customer Segmentation

---

## 🎯 Objectives

- Clean and standardize raw banking transaction data  
- Design and implement a **Star Schema Data Warehouse**
- Build analytical **Data Mart layers**
- Enrich data with business-driven features
- Perform behavioral transaction classification
- Create customer segmentation logic
- Enable analytics-ready datasets for BI tools
- Build a scalable foundation for advanced banking analytics

---

## 🔄 Data Pipeline

Raw Data  
→ Data Cleaning  
→ Feature Engineering  
→ Staging Layer  
→ Data Warehouse (Kimball)  
→ Data Enrichment  
→ Analytical Data Marts  
→ BI & Analytics Ready

---

## 🧹 Data Cleaning & Preparation

Key transformations performed:

- Standardized schema and naming conventions for SQL compatibility
- Corrected invalid and inconsistent date-of-birth values
- Derived customer age
- Handled missing values:
  - Gender → `"Unknown"`
  - Location → standardized
  - Balance → median imputation
- Removed unrealistic values using domain-driven validation rules
- Ensured primary key integrity

---

## 🧱 Data Warehouse Design (Kimball)

### Fact Table

- `fact_transactions`
  - Transaction-level grain
  - Stores transaction metrics and dimensional foreign keys

### Dimension Tables

- `dim_customer`
  - Demographic and customer-related attributes

- `dim_date`
  - Calendar hierarchy and temporal analysis support

- `dim_location`
  - Geographical and regional attributes

### Data Warehouse Features

✔ Fully implemented with PK/FK constraints  
✔ Kimball-based dimensional modeling  
✔ Optimized for analytical querying

---

## ⚡ Data Enrichment

### 👥 Customer Enrichment

Business-driven customer attributes were derived to simulate real-world banking analytics scenarios:

- Household simulation
- Marital status derivation
- Account activity classification:
  - Active
  - Suspended
  - Closed

---

### 💳 Transaction Enrichment

Transactions were classified into behavioral categories using a hybrid approach combining recurrence analysis and statistical distribution logic.

#### 🔹 Recurrence Detection

- Repeated transactions identified per customer
- Highest recurring amounts → `Loan Payment`
- Smaller recurring amounts → `Bill Payment`

#### 🔹 Distribution-Based Classification

- `< 1500` → `Purchase`
- `>= 1500` → `Transfer`

✔ Combines behavioral pattern detection and statistical segmentation logic

---

# 📊 Analytical Data Marts

The project includes analytical Data Mart layers designed for BI consumption, customer analytics, and segmentation workflows.

---

## 1️⃣ mart_customer_summary

Customer-level analytical aggregation table.

### Features

- Total transaction volume
- Average transaction amount
- Customer activity duration
- Transaction behavior distributions
- Average account balance
- Customer demographic attributes

### Business Value

- Customer 360 analytics
- KPI reporting
- Customer profiling
- Foundation for RFM and segmentation analysis

---

## 2️⃣ mart_financial_summary

Time-based financial aggregation layer.

### Features

- Daily transaction volume
- Active customer counts
- Financial trend analysis
- Transaction type distributions
- Daily KPI generation

### Business Value

- Executive dashboard reporting
- Financial monitoring
- Operational banking analytics
- Time-series analysis

---

## 3️⃣ mart_customer_behavior

Behavioral customer segmentation layer.

### Features

- Dominant transaction behavior
- Activity segmentation
- Customer value segmentation
- Behavioral customer classification

### Generated Segments

- Purchase Focused
- Transfer Focused
- Bill Payment Focused
- Loan Payment Focused

### Business Value

- Customer targeting
- Behavioral analytics
- Customer engagement analysis
- Banking CRM segmentation

---

## 4️⃣ mart_rfm_segmentation

RFM-based customer intelligence layer.

### RFM Metrics

- Recency
- Frequency
- Monetary

### Generated Segments

- Champions
- Loyal Customers
- Potential Loyalists
- At Risk
- Dormant

### Business Value

- Retention analysis
- Churn monitoring
- High-value customer detection
- CRM and campaign optimization

---

## 📊 Key Outcomes

- Built a fully functional PostgreSQL-ready Data Warehouse
- Designed analytical Data Mart architecture
- Created behavioral transaction segmentation logic
- Implemented customer intelligence and RFM segmentation
- Prepared analytics-ready datasets for BI tools
- Enabled:
  - Customer analytics
  - Financial trend analysis
  - Behavioral segmentation
  - Banking-style analytical reporting

---

## ⚙️ Technologies Used

- Python (Pandas, NumPy)
- SQL (PostgreSQL)
- Jupyter Notebook
- Git & GitHub

---

## 🚀 Next Steps

- Develop interactive Power BI dashboards
- Build a semantic KPI layer
- Implement clustering-based segmentation
- Create customer lifetime value analysis
- Introduce anomaly detection models
- Develop predictive analytics workflows

---

## 💡 Future Vision

- Customer Lifetime Value (CLV)
- Fraud & anomaly detection
- Predictive customer segmentation
- Banking profitability analytics
- Risk-oriented analytical modeling

---

## 👤 Author

**Eser Karaceper**  
Senior BI & Data Analyst  
Power BI | SQL | Data Modeling
