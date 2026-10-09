# 🏦 PaySim Data Warehouse Project (Kimball Modeling)

---

## 📌 Project Overview

- Designed and implemented a **transaction-level data warehouse** using the PaySim dataset  
- Transformed raw financial transaction data into a **Kimball-based star schema**  
- Built a scalable data model to support **analytical queries and business insights**  
- Developed a **data mart layer for fraud analysis and KPI reporting**  
- Built an **end-to-end pipeline from raw data to Power BI dashboard**  
- Focused on **data modeling, ETL design, and performance optimization**

---

## 🧱 Data Warehouse Architecture

The project follows a layered architecture:

- **Data Preparation Layer (Jupyter)** → data cleaning and transformation into analysis-ready format  
- **Data Warehouse Layer** → fact and dimension modeling (Kimball)  
- **Data Mart Layer** → business-ready aggregated datasets for analytics  

---

## 📊 Dimensional Modeling (Kimball)

- **Fact Table**
  - `fact_transactions` → transaction-level grain  

- **Dimension Tables**
  - `dim_account` → customer & merchant entities  
  - `dim_transaction_type` → transaction categories  
  - `dim_time` → date and time attributes    

- Implemented **surrogate keys and normalized dimensions**  
- Optimized model for **analytical performance and scalability**

---

## 🔄 Data Pipeline

- Data ingestion via **Kaggle API**  
- Data preparation in **Jupyter Notebook (cleaning & transformation)**  
- Data storage and querying in **PostgreSQL**  
- SQL-based transformations for **warehouse and data mart layers**  
- ETL designed using **set-based transformations (JOIN-driven loading)**  

---

## 📊 Data Mart Layer

A dedicated data mart was designed to transform transaction data into **business-ready insights**.

### 🔹 Key Table

- `financial_summary` → P&L-like aggregated KPI table  

### 🔹 Example KPIs

- `total_transactions`  
- `total_amount`  
- `avg_amount`  
- `fraud_transactions`  
- `fraud_rate`  
- `cash_in / cash_out / transfer breakdown`  

### 🔹 Purpose

- Enable **fraud trend analysis over time**  
- Identify **high-risk transaction types**  
- Support **Power BI dashboard with optimized dataset**

---

## 📊 Power BI Dashboard

- Built an interactive **Fraud Detection & Risk Analysis Dashboard**  
- Includes:
  - KPI cards (Total Amount, Fraud Rate, High Value Transactions)  
  - Transaction type breakdown  
  - Time-based trend analysis  
  - Hourly activity heatmaps  
- Designed to highlight **fraud patterns and behavioral insights**

---

## ⚡ Performance Optimization

- Indexes created on frequently filtered columns:
  - `transaction_date`
  - `transaction_type`
- Improved query performance for analytical workloads  

---

## 🛠️ Tech Stack

- PostgreSQL  
- SQL  
- Python (data ingestion & preprocessing)  
- Power BI  

---

## 📁 Project Structure

fintech-paysim-project/

├── legacy-analysis/  
├── sql/  
│   ├── staging/  
│   ├── dwh/  
│   └── marts/  
│  
├── docs/  
├── powerbi/  
└── README.md  

---

## 📌 Notes

- The main implementation is under the **sql/** directory  
- Includes fully reproducible scripts for DWH and data marts  
- Dashboard is available in the **powerbi/** folder  
- Designed with **performance, data quality, and scalability** in mind  

---

## 📈 What I Learned

- Designing **star schema data warehouses (Kimball methodology)**  
- Building **fact & dimension tables from raw event data**  
- Creating **data marts for business-driven analytics**  
- Translating data into **business insights via Power BI**  
- Optimizing ETL pipelines and query performance  

---

## 🚀 Next Steps

- Implement **partitioning for large-scale performance**  
- Add **SCD Type 2 for historical tracking**  
- Extend analysis with **advanced fraud detection patterns**
