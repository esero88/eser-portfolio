# WHO Global Health Indicators Analysis

Comparison of countries on global health indicators from the WHO Global Health Observatory (GHO) API: medical doctors, nursing and midwifery personnel density, and DTP3 immunization coverage.

## Folders
- `SOW/`: statement of work for the analysis (in Turkish)
- `data_prep/clean_who_data.ipynb`: data preparation notebook (WHO GHO API to clean long-format table)
- `data_prep/clean/clean_uzun_format_api.csv`: cleaned dataset used in Tableau
- `viz/who_health_indicators_dashboard.twb`: Tableau workbook

## Note on the Tableau workbook
The `.twb` file points to a CSV path on the author's computer. To open it, connect the data source to `data_prep/clean/clean_uzun_format_api.csv`.
