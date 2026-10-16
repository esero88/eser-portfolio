# Pension Retention Analytics (BES)

How long do Turkish private pension contracts survive, why do they end, and where does each company stand?

> Work in progress. Findings will be added once the analysis is done.

Written up as a full case study following the Ask / Prepare / Process / Analyze / Share / Act structure: [English](docs/case-study-en.md) · [Türkçe](docs/case-study-tr.md).

## Question and audience
A marketing or CRM decision-maker at a pension company, deciding whether to shift budget from acquiring new contracts to keeping existing ones. Acquisition is easy to measure and shows up fast; persistency shows up late and its measurement is contested, so budget flows to acquisition by default.

The contested metric is "active participant". Turkish regulation lets a participant pause contributions without leaving the system, so a paused contract stays in force and still counts as a participant. A company can report hundreds of thousands of participants while a large share of them pay nothing in. Contracts in force and contracts receiving contributions are two different numbers, and which one you use changes the budget decision.

## Data
Emeklilik Gözetim Merkezi (EGM) publishes statistics on the Turkish private pension system. Reports collected:

| Code | Report |
|---|---|
| `GR-01-015` | Termination rate of contracts by entry month |
| `GR-01-010` | Terminated contracts by reason |
| `GR-01-019` | Withdrawal (cayma) rate |
| `GR-01-018` | Transfers between companies, by time spent at previous company |
| `GR-01-116` | Termination and collection rates by entry year (sector) |
| `EGM-05-006` | Fund size by pension company |
| `EGM-05-001` | Fund management fee rates |
| `EGM-05-012` | List of pension investment funds |

EGM reports are aggregate, not participant level. The dashboard is built on these published figures only. A separate simulated participant-level table, calibrated to the same aggregates, is used to test the NL-to-SQL agent. No dashboard figure comes from simulated data.

## Method
1. Collect each report across its date range with `scripts/egm_collector.py`.
2. Flatten multi-row headers and reshape to long format.
3. Load the clean tables into a PostgreSQL star schema.
4. Build the Tableau dashboard on the cleaned extracts.
5. Write a metric dictionary (persistency, withdrawal rate, net flow) and a RAG agent that translates plain-language questions into SQL against it.
6. Score the agent on a 30-question test set and report accuracy and error types.

## Setup

```bash
pip install playwright pandas openpyxl
playwright install chromium

python scripts/egm_collector.py --url "<report url>" --code GR-01-015 --probe
python scripts/egm_collector.py --url "<report url>" --code GR-01-015 --out data/raw
```

## Files
- `docs/`: the case study, in English and Turkish
- `notebooks/01_egm_veri_toplama.ipynb`: data collection notebook (Colab)
- `scripts/egm_collector.py`: Playwright collector that walks a report's date list and exports each snapshot
- `tableau/`: Tableau workbook
- `data/`: raw and cleaned data, not committed

## Source
All statistics belong to Emeklilik Gözetim Merkezi A.Ş. (EGM): https://www.egm.org.tr/
