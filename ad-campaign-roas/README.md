# Ad Campaign Performance & ROAS Dashboard

Which ad platform and campaign type returns the most per ad dollar, and where should budget shift?

![Dashboard](tableau/dashboard.png)

**Live dashboard:** https://public.tableau.com/app/profile/eser.karaceper/viz/ad-campaign-roas-dashboard/AdCampaignPerformance

## Question and audience
A marketing manager preparing the monthly budget meeting. The dashboard compares Google, Meta and TikTok ads by ROAS, cost and funnel efficiency.

## Data
Kaggle "Global Ads Performance (Google, Meta, TikTok)". It is a synthetic dataset, so the findings are hypotheses, not real campaign results. Some platform and campaign type combinations may not exist in real life.
Cleaning steps are in `notebooks/global_ads_data_prep.ipynb`. Cleaned data: `data/cleaned/global_ads_clean.csv`.

## Method
- KPIs are calculated from sums, never by averaging row-level ratios: ROAS = revenue / spend, CTR = clicks / impressions, CPC = spend / clicks, Conv Rate = conversions / clicks, CPA = CPC / Conv Rate.
- One KPI parameter drives the heatmap, trend and spend charts.
- Tableau features used: parameters, calculated fields, LOD expressions, table calculations, dual axis, reference line, dynamic titles, highlight action, funnel.

## Key findings (full period)
- TikTok returns $7.62 per $1 spent, Meta $5.66, Google $3.47.
- Google takes 57% of ad spend but returns 41% of revenue. TikTok takes 24% of spend and returns 37%.
- Hypothesis: moving part of the Google budget to TikTok may lift total ROAS. This assumes TikTok keeps its average return as spend grows, so a small test shift comes first.
- Monthly spend and ROAS show a weak negative link (r = -0.34, 12 months), not conclusive.

## Files
- `data/raw/`: original Kaggle file
- `data/cleaned/global_ads_clean.csv`: cleaned dataset used in Tableau
- `notebooks/global_ads_data_prep.ipynb`: data preparation notebook
- `tableau/`: Tableau workbook and dashboard screenshot
