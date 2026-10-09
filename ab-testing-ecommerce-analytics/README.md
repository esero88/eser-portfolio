# A/B Testing Analysis - E-commerce Dataset

This project analyzes an A/B testing experiment using e-commerce data to evaluate the impact of different variants on user conversion.

---

## 📊 Project Overview

The analysis compares Control, Variant_A, and Variant_B groups to determine whether new changes improve conversion rates.

---

## 🧠 Key Steps

- Data ingestion using Kaggle API  
- Data cleaning and transformation  
- User-level dataset creation  
- Conversion rate calculation  
- Lift analysis  
- Statistical testing (Z-test)  
- Business interpretation  

---

## ⚙️ Data Processing Approach

Event-level data was aggregated to user level to ensure:

- Each user belongs to a single experiment group  
- Conversion reflects user-level behavior  

The most frequent experiment group per user was selected to avoid duplication and contamination.

---

## 📈 Key Findings

- Control group achieved the highest conversion rate (~64.1%)  
- Variant_A and Variant_B performed worse than Control  
- Negative lift observed for both variants (~ -3%)  

---

## 🧪 Statistical Results

- Variant_A vs Control → p ≈ 0.073  
- Variant_B vs Control → p ≈ 0.064  

Results are **not statistically significant (p > 0.05)**

---

## 🚨 Conclusion

- No strong evidence that variants improve performance  
- Observed differences may be due to random variation  

➡ **Recommendation:** Do not roll out the variants  

---

## 💡 Next Steps

- Test stronger variations  
- Increase sample size  
- Run additional experiments  

---

## ⚙️ Tech Stack

- Python (Pandas, NumPy)  
- Statsmodels  
- Jupyter Notebook  
- Power BI  

---

## 📂 Project Structure

- `01_data_ingestion_kaggle.ipynb`  
- `02_ecommerce_ab_testing_analysis.ipynb`  
- `03_ab_testing_user_level_fix.ipynb`  

---

## 📥 Data Source

Dataset is not included due to size limitations.  
It can be downloaded via Kaggle API using the ingestion notebook.
