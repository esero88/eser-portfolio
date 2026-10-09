# eser-portfolio

Data analytics portfolio projects by Eser Karaceper. Each project lives in its own folder with its data, notebook and dashboard files.

## Projects

### 1. Ad Campaign Performance & ROAS Dashboard
**Question:** Which ad platform and campaign type returns the most per ad dollar, and where should budget shift?
**Tools:** Python (data prep), Tableau Public
**Result:** Interactive dashboard comparing Google, Meta and TikTok ads by ROAS, cost and funnel efficiency, with a budget shift hypothesis.
**Folder:** [ad-campaign-roas](ad-campaign-roas/)
**Live dashboard:** [Tableau Public](https://public.tableau.com/app/profile/eser.karaceper/viz/ad-campaign-roas-dashboard/AdCampaignPerformance)

### 2. PaySim Data Warehouse and Fraud Analysis
**Question:** How can raw payment transactions be modeled for fast fraud analysis and KPI reporting?
**Tools:** Python, PostgreSQL, SQL, Power BI
**Result:** Kimball star schema (fact and dimension tables), a fraud analysis data mart and a Power BI dashboard, built end to end from the PaySim dataset.
**Folder:** [fintech-paysim-analysis](fintech-paysim-analysis/)

### 3. A/B Testing Analysis on E-commerce Data
**Question:** Do the two new variants convert better than the control?
**Tools:** Python, statistical testing (Z-test)
**Result:** Both variants converted worse than the control (about -3% lift) and the difference is not statistically significant (p > 0.05). Recommendation: do not roll out the variants.
**Folder:** [ab-testing-ecommerce-analytics](ab-testing-ecommerce-analytics/)

### 4. Bank Customer Segmentation and Data Warehouse
**Question:** How can banking transaction data be cleaned, modeled and enriched for customer segmentation and BI?
**Tools:** Python, PostgreSQL, SQL, Power BI
**Result:** Kimball data warehouse with a staging layer, enrichment rules for customers and transactions, and analytical data marts for segmentation.
**Folder:** [bank-customer-segmentation](bank-customer-segmentation/)

