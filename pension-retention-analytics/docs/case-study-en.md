# Case study: Why don't pension contracts survive?

## Introduction

In this case study you work on the analytics team of a pension company and answer one question: why don't private pension contracts survive, and where does the company stand?

To answer the business questions you follow the six steps of the data analysis process: **Ask, Prepare, Process, Analyze, Share, Act**. Each step ends with a Case Study Roadmap table — guiding questions, key tasks, and that step's deliverable. When you lose the thread, go back to those tables.

Two things set it apart from Google's Cyclistic and Bellabeat case studies:

1. **The data is real.** Cyclistic and Bellabeat are fictional companies working with proxy data. Here the company is fictional but the data is real: the public private pension statistics published by Emeklilik Gözetim Merkezi (EGM), Türkiye's pension monitoring centre. The findings describe an actual market.
2. **There is a further layer.** Once the classic analysis is done, you build an agent that turns a business user's plain-language question into SQL, and you measure it against a 30-question test set. That part is what separates this from an ordinary dashboard project in a portfolio.

When you finish you will have a portfolio-ready case study, a Tableau dashboard, and an AI agent whose accuracy you can state as a number.

## Scenario

You are a data analyst on the analytics team at Anka Emeklilik ve Hayat A.Ş. Anka is a mid-sized company: roughly 750,000 participants, but about 1.5% market share by fund size. Many people, little money.

Ahead of the annual strategy meeting, Deniz Arslan — Deputy General Manager for Marketing and Customer, and your manager — makes an observation: the company wins new contracts every year, yet the total portfolio is not growing at the expected rate. Some of what is won leaves through the back door. Nobody knows precisely which door, when, or why.

Deniz asks you to answer this using the sector's public data. Anka's own customer data is out of scope for this analysis — the aim is to understand how the sector behaves first, then see where the company sits. The findings go to the executive committee, so they must be both visual and defensible.

> **Note:** Anka Emeklilik is a fictional company, invented to give the case study a business context and stakeholders. All data used is real and public; the company names appearing in the analysis (AgeSA, Anadolu Hayat, Garanti, Allianz and others) are real companies as published in EGM reports.

## Characters and teams

| Person / team | Role | What they need from you |
| --- | --- | --- |
| **Deniz Arslan** | Deputy General Manager, Marketing and Customer — your manager | A clear answer on why contracts end, and visuals that can go to the executive committee |
| **Analytics team** | Data collection, modelling and reporting. You joined six months ago | A repeatable data pipeline — the analysis must be refreshable each quarter, not a one-off |
| **Actuarial team** | Owns fund and reserve calculations | Metric definitions that do not contradict their own figures |
| **Executive committee** | Approves the marketing budget | Recommendations backed by numbers |

Metric definitions are the quiet difficulty of this case study. "Active participant", "persistency", "loss" — none of these is written in a data column; each is a business decision. The most contested is "active participant", unpacked in the next section. If you do not use the same definition as the actuarial team, the same data yields two different numbers.

## About the sector

You cannot read the data without understanding the system behind it. These are the mechanisms that shape the analysis.

**There are two separate systems.** In voluntary BES a person joins by choice and sets their own contribution. In Automatic Enrolment (OKS) an employee is enrolled automatically through their employer; the contribution is 3% of earnings subject to premium, and they can exercise a right of withdrawal within a limited window. The two behave very differently — keep them apart in the analysis.

**The state contribution is the system's glue, and it changed in 2026.** For every 100 lira a participant pays in, the state adds a contribution. That rate was 30% for years; a Presidential decision published in the Official Gazette on 7 January 2026 **cut it to 20%** ([source](https://medyascope.tv/2026/01/07/beste-devlet-katkisi-yuzde-30dan-yuzde-20ye-indi/)). Existing balances were preserved; new contributions accrue at the new rate. If your data covers that date, look for a break in the persistency curve.

**The state contribution is not yours immediately — it vests with seniority.** By time spent in the system ([source](https://www.agesa.com.tr/bes/sss)):

| Time in system | State contribution vested |
| --- | --- |
| 3+ years | 15% |
| 6+ years | 35% |
| 10+ years | 60% |
| 10+ years and age 56 | Full |

This table is the heart of the analysis. A participant who leaves early walks away from most of the state contribution — so leaving is a loss for both the participant and the company. There is an incentive that should, in theory, keep people in. If they leave anyway, finding out why is the real question.

**A contract can end in seven different ways.** EGM reports each separately: exit from the system, withdrawal (cayma), transfer to another company, retirement, account consolidation, death/disability, and rejection/termination. All of them sit under the heading "termination", but their business meanings are opposites: retirement is success, transfer to another company is a competitive loss, exit from the system is a genuine loss. Collapse them into a single churn number and the analysis loses its meaning.

Getting that distinction right is the measure of success for this case study.

## 1. Ask

Three questions guide the analysis:

1. How long do contracts survive — how does the termination rate vary by entry cohort?
2. How much of termination is genuine loss, how much is success or competitive loss?
3. Where does Anka stand on fund size and cost competitiveness?

Deniz marked the first as the primary question: **how long do contracts survive and why do they end?** The other two put that answer in context.

You will produce six deliverables:

1. A clear statement of the business task
2. A description of all data sources used
3. Documentation of any cleaning or manipulation of data
4. A summary of your analysis
5. Supporting visualizations and key findings
6. Your top three recommendations based on your analysis

### Which decision are we changing?

At pension companies most of the annual marketing budget goes to **acquiring new contracts**: branch targets in bancassurance, campaigns, gift vouchers. Acquisition is measurable and fast — at month end you know how many new contracts were written. Persistency shows up late and its measurement is contested. That asymmetry is why budget flows to acquisition.

The decision Deniz wants answered: **should part of the budget shift from acquisition to retention?** That is the one decision this analysis can actually change.

### The contested metric: "active participant"

This is the most argued-over definition in the sector, and the reason sits in the regulation.

BES contributions can be paused. If a due payment is not made within three months of its due date, the contract is treated as paused — but it is **not treated as having left the system** ([source](https://www.turkiyegazetesi.com.tr/tasarruf-ortagim/bes-odemelerine-ara-verilebilir-mi-beste-5-yil-siniri-1822478)). The contract stays in force, the balance keeps working in the funds, and the participant is still a participant.

So a company can say "we have 750,000 participants" while a significant share of them have paid nothing in for years. Two definitions collide:

| Definition | What it counts | Who it serves |
| --- | --- | --- |
| **A — In force** | Everyone whose contract has not terminated | Acquisition targets, press releases, market share |
| **B — Paying** | Contracts with a contribution in the last 12 months | Fund growth, real portfolio value |

For the same company these two numbers differ widely. Which one you use changes the budget decision directly: under definition A the company looks like it is growing; under definition B you see how much of the portfolio is dormant.

A second definition problem follows from it: EGM counts retirement, withdrawal and transfer to another company all under "termination". Reducing them to one "loss" figure makes the analysis meaningless.

**Who decides:** the executive committee approves the budget, but the actuarial team owns the metric definition. If you do not agree the definition with actuarial before the presentation, the meeting is spent arguing about the definition rather than the analysis — the most realistic trap in this case study.

**Scope warning:** EGM's public reports cover contract terminations. Check what is published on paused contributions under the "Katkı Payı" folder (20 reports). If nothing is there, you cannot compute definition B from sector data — write that down as a constraint and raise it in Act as a next step using the company's own data.

| Roadmap — Ask | |
| --- | --- |
| **Guiding questions** | What problem are you trying to solve? Which business decision will your findings change? Which metric's definition is contested, and who decides it? |
| **Key tasks** | Identify the business task. Identify stakeholders and the decision each one makes. Clarify the difference between "termination" and "loss". |
| **Deliverable** | A clear statement of the business task |

**Tip:** when writing the business task, avoid a sentence like "analyse BES data" — that is an activity, not a task. The task must name the question to be answered and whose decision it answers.

## 2. Prepare

The data sits under Bilgi Merkezi > İstatistikler at [Emeklilik Gözetim Merkezi](https://www.egm.org.tr/). There are over 250 reports; each exports to Excel, and each report is a snapshot of one date chosen from a list at the top.

Reports to collect:

| Code | Report | What it answers |
| --- | --- | --- |
| `GR-01-015` | Termination rate of contracts by entry month | Cohort persistency curve — the primary question |
| `GR-01-010` | Terminated contracts by reason | Reasons for leaving |
| `GR-01-019` | Withdrawal (cayma) rate | Early exit |
| `GR-01-018` | Transfers between companies, by time at previous company | Competitive loss |
| `GR-01-014` | Contracts by seniority | Comparison against state contribution vesting |
| `GR-01-116` | Termination and collection rates by entry year (sector) | Cohort collection |
| `EGM-05-006` | Fund size by pension company | Company-level market share |
| `EGM-05-001` | Fund management fee rates | Cost competitiveness |

**Check first:** which of these carry a company breakdown and which are sector totals? Some say "(Sector)" in the title; others are totals without saying so. This distinction sets the scope — if persistency is only available at sector level, you cannot ask "is Anka's persistency better than its competitors'" and you have to reframe the question.

### Does the data ROCCC?

| Criterion | Assessment |
| --- | --- |
| **Reliable** | **Strong.** A regulatory monitoring body; companies have a reporting obligation |
| **Original** | **Strong.** Produced from what companies report to EGM, not a secondary compilation |
| **Comprehensive** | **Weak.** The data is aggregate — participant behaviour cannot be modelled. Which reports carry a company breakdown is not known upfront. Whether paused-contribution data is published is unverified |
| **Current** | **Strong.** Refreshed regularly; each report is tied to a chosen date |
| **Cited** | **Conditional.** Attribution is mandatory; no quoting without citing the source |

**Important limitation:** EGM data is **aggregate**, not participant level. You cannot model "which participant will leave" with it; you can answer "which cohort, at what seniority, for what reason". State this limit plainly in the case study — knowing what the data cannot do is as valuable as knowing what it can.

**Licence and attribution:** EGM reports carry the note that all statistical data, charts and analysis in them belong to Emeklilik Gözetim Merkezi A.Ş. and may not be quoted without citing the source. Attribution must be visible both in the README and **on the dashboard itself** — someone viewing it on Tableau Public never sees the README.

**Privacy:** because the data is aggregate it contains no personal data. That is an advantage of this project — there is no personal-data exposure to manage.

| Roadmap — Prepare | |
| --- | --- |
| **Guiding questions** | Where is the data and how is it organised? Are there bias or credibility issues? Does it ROCCC? How are you handling licensing, privacy and accessibility? Does it answer the question, and where does it fall short? |
| **Key tasks** | Download the reports and store them properly. Identify which carry a company breakdown. Verify data integrity. Write down the scope limits. |
| **Deliverable** | A description of all data sources used |

## 3. Process

The Excel files from EGM are not directly analysable. Three problems: headers are split across two rows (in `EGM-05-006` the top row reads "Gönüllü BES" and the row below "Faizli/Faizsiz"), large numbers drop into scientific notation, and each file covers a single date — you have to combine them for a time series.

**Steps:**

1. **Collect.** `scripts/egm_collector.py` walks the report's date list, clicks "Excel'e Aktar" for each date, and saves `CODE_YYYY-MM-DD.xlsx`. Run it with `--probe` first — it reports whether it found the date list and the export button without downloading anything.
2. **Flatten the headers.** Collapse the two-row header into one: `gonullu_bes_faizli`, `oks_faizsiz`. Use snake_case and drop Turkish characters — they cause trouble in SQL.
3. **Fix the types.** Amounts and rates to `numeric`, dates to `date`. Check for precision lost to scientific notation.
4. **Reshape to long.** Turn wide tables into `report_date, company, segment, metric, value`. Both SQL and Tableau prefer this shape.
5. **Combine.** Union the monthly files into one table keyed on `report_date`.
6. **Validate.** For each report date, does the grand total equal the sum of the company rows? Compare against EGM's own "Genel Toplam" line. If it does not reconcile, the transformation is wrong.
7. **Load.** Move the clean tables into PostgreSQL and build a star schema: `fact_fund_size`, `fact_contract_termination`, `dim_company`, `dim_date`, `dim_termination_reason`.

**Documentation rule:** write every cleaning decision as a comment in the notebook. "Why I dropped this column", "why I excluded this row" — you will not remember in three months, and in a job interview this is exactly what gets asked.

**Tool choices and why:**

| Tool | Where | Why |
| --- | --- | --- |
| Python (Playwright) | Collection | The EGM page renders with JavaScript; `requests` returns an empty table |
| Python (pandas) | Cleaning | Most practical for multi-row headers and wide-to-long reshaping |
| PostgreSQL | Warehouse | The layer the agent queries; also enforces schema discipline |
| Tableau | Dashboard | A Tableau Public link can be shared from the portfolio |

| Roadmap — Process | |
| --- | --- |
| **Guiding questions** | Which tools did you choose and why? How did you ensure data integrity? How did you verify the data is clean? Have you documented the cleaning so it can be shared? |
| **Key tasks** | Check the data for errors. Choose your tools. Transform the data so you can work with it. Document the cleaning process. |
| **Deliverable** | Documentation of any cleaning or manipulation of data |

## 4. Analyze

The data is ready; now answer the question. There are four lines of analysis.

### A. Cohort persistency curve — the primary analysis

`GR-01-015` gives two things for every entry month: how many contracts were written that month, and how many of them have terminated as of today. Monthly from 2003 to now — roughly 275 cohorts.

Watch out for this: older cohorts naturally show a higher termination rate, because they have been exposed for longer. Put the raw rates side by side and you reach the wrong conclusion that the 2004 cohort is worse than 2024. Compare **at equal seniority**: each cohort's termination rate at month 12, at month 24.

What to look for: is persistency improving over the years? Are there breaks at regulatory changes (the start of OKS, state contribution rate changes)? Do the vesting thresholds (3, 6, 10 years) show up in the curve — are people waiting to cross them?

### B. Reasons for termination

`GR-01-010` splits terminations into seven reasons. Collapse them into three business categories:

| Category | Reasons | What it means for the company |
| --- | --- | --- |
| Genuine loss | Exit from system, withdrawal, rejection/termination | Preventable — the real target |
| Competitive loss | Transfer to another company | Preventable — but needs a different intervention |
| Not a loss | Retirement, death/disability, account consolidation | Unpreventable, or already a success |

Any churn figure computed without this split is misleading.

### C. Competitive position

`EGM-05-006` gives fund size by company. Compute: Anka's voluntary BES and OKS shares, market concentration (how much the top four hold), and how shares move over time. There is also an interest-bearing / participation split — the preference for participation pensions varies a lot between companies, and that may be a finding in its own right.

### D. Cost

`EGM-05-001` gives fund management fee rates. The question: do companies with higher fees lose participants? This looks for a correlation; do not claim causation.

**Don't forget to look for surprises.** What separates a case study from a rote report is the unexpected finding. Approach the data asking "what's here", not "let me confirm this".

| Roadmap — Analyze | |
| --- | --- |
| **Guiding questions** | How should you organise the data for analysis? What surprises did you find? What trends and relationships emerged? How do these findings answer the business question? |
| **Key tasks** | Aggregate the data so it is useful. Perform the calculations. Compare at equal seniority. Identify trends and relationships. |
| **Deliverable** | A summary of your analysis |

## 5. Share

Deniz will present the findings to the executive committee. The visuals must be both polished and self-explanatory — they have to work without you standing next to them.

**Four visuals the dashboard should carry:**

1. **Cohort persistency curve** — survival by seniority. Each cohort a line or a heatmap; the x-axis is months of seniority, not entry date.
2. **Reasons for termination** — by the three business categories. Avoid a pie chart; a stacked bar also shows change over time.
3. **Market share** — Anka's position and concentration. A sorted bar is enough.
4. **Cost vs persistency** — is there a relationship between fee rate and loss? A scatter plot.

**Tableau Public constraint:** Tableau Public does not support live database connections. You cannot connect to PostgreSQL and publish — export the clean tables to CSV and build the Tableau workbook on those. The warehouse is still built; it is where the agent runs.

**Attribution:** put the EGM source on the dashboard itself. Someone who sees your work on Tableau Public does not see the GitHub README.

**Visual principles:** use contrast to point at the most important finding. Let the title state the finding, not the chart type — not "Termination rate by cohort" but "Recent cohorts survive their first year better". Put units on axes. Never let colour carry meaning on its own.

| Roadmap — Share | |
| --- | --- |
| **Guiding questions** | Were you able to answer why contracts end? What story does your data tell? Who is your audience and how do you best reach them? Does visualization help? |
| **Key tasks** | Determine the best way to share the findings. Create effective visualizations. Make the source visible. Ensure the work is accessible. |
| **Deliverable** | Supporting visualizations and key findings |

## 6. Act

Prepare the three recommendations Deniz asked for. A good recommendation carries three things: which finding it rests on, who does what, and how success will be measured.

**Ask yourself:** would the findings actually change a marketing budget decision? "We should improve persistency" is a wish, not a recommendation. "Participants who pass month 12 drop off far more slowly, so budget should shift to a first-year contact programme" is a recommendation.

**Write down your limits too.** EGM data is aggregate; you cannot predict which individual participant will leave. Say what the next step is: a participant-level model on the company's own CRM data. Knowing where your analysis ends makes it more credible, not less.

**Adding it to the portfolio:**

1. Add a "Key findings" section to the README in `pension-retention-analytics` — with numbers.
2. Publish the dashboard to Tableau Public and put the link in the README.
3. Put a dashboard screenshot at the top of the README, as in your other projects.
4. Update the "Result" line for project 6 in the root README.
5. Draw a post out of it for LinkedIn: the single most striking finding plus how you found it.

| Roadmap — Act | |
| --- | --- |
| **Guiding questions** | What is your final conclusion? How could the team and the business apply these insights? What step should stakeholders take? What additional data would extend the findings? |
| **Key tasks** | Write the three recommendations. State the limits. Add the case study to your portfolio. Rehearse the presentation. |
| **Deliverable** | Your top three recommendations based on your analysis |

## Appendix: the agentic AI layer

Everything above follows the same skeleton as Google's case studies. This section is extra — and it is what makes the difference in a portfolio.

**The problem:** Deniz comes to you for every question. "How many contracts are in the At Risk cohort", "what was the withdrawal rate last quarter" — each becomes a ticket, each takes a day. The fix: an assistant that turns the plain-language question into SQL.

### 1. Simulated participant layer

EGM data is aggregate; to test a SQL agent you need a warehouse with joins and fine grain. So you generate synthetic participant- and contract-level tables — but not at random: age distribution, seniority distribution, termination reasons and rates are anchored to the real EGM aggregates.

Do not confuse two things. Asking an LLM to "generate 10,000 customers" is fabrication and is useless — every pattern you then see in the dashboard was put there by the model. Calibrated simulation is different: its marginals and business rules are anchored to published real figures. Actuaries already do this for model testing.

**Rule:** no finding in the dashboard comes from simulated data. This distinction is stated plainly in the README and in the case study.

### 2. Metric dictionary

The definition file the agent reads. For each metric: the definition, the calculation rule, which table it lives in, and its limits. For "persistency" — which termination reasons count, and is the reference date today or the dataset's last date? For "active participant" — definition A or definition B?

This file is the most valuable part of the project. What makes the agent good is not the model; it is the definitions in this dictionary.

### 3. The 30-question accuracy test

Once the agent is built, "it works" is not enough. Write 30 questions, write the correct SQL for each by hand (the gold SQL), then run the agent and compare.

| Difficulty | Count | Content |
| --- | --- | --- |
| Easy | 10 | Single table, filter and aggregation |
| Medium | 10 | Joins, ratios, date logic |
| Hard | 7 | Window functions, period comparison, nested metrics |
| Should not answer | 3 | Something absent from the data — the agent must be able to say "I don't know" |

That last row matters: producing correct SQL counts, but so does **stopping where it should not produce any**. An agent that writes a query with an invented column name is more dangerous than a wrong answer, because it looks confident.

The result table looks like this: how many questions were right, and what kind the errors were (wrong table, wrong metric definition, ignored the dictionary, invented column). That table is what turns the project from a demo into portfolio work.

## Wrap-up

Google says a week is a reasonable goal for its case studies. This is larger — you are also doing the data collection and the agent layer. Assuming a few hours on weekday evenings:

| Week | Work |
| --- | --- |
| 1 | **Ask** — business task, "active participant" definition, agreement with actuarial |
| 2 | **Prepare** — collect the reports, identify which carry a company breakdown, settle the scope |
| 3 | **Process** — flatten headers, reshape to long, validate |
| 4 | **Process + Analyze** — PostgreSQL warehouse, cohort analysis |
| 5 | **Analyze + Share** — findings settle, Tableau dashboard |
| 6 | **Extra layer** — metric dictionary, simulated data, agent |
| 7 | **Measurement and close** — 30-question test, error analysis, portfolio and README |

**Deliverable checklist:**

- [ ] A clear statement of the business task
- [ ] A description of all data sources (including the ROCCC assessment)
- [ ] Cleaning and transformation documentation
- [ ] A summary of the analysis
- [ ] Supporting visualizations and key findings
- [ ] Three recommendations
- [ ] Tableau Public link
- [ ] Metric dictionary
- [ ] 30-question accuracy table
- [ ] GitHub README up to date

**One reminder:** the value of this case study lies less in how striking the findings are than in how traceable the reasoning is. Why you defined a metric the way you did, what the data could not say, where the agent got it wrong — writing those down honestly is worth more than a polished but empty presentation.

---

## Sources

- [Emeklilik Gözetim Merkezi](https://www.egm.org.tr/) — BES and OKS statistics. All data belongs to EGM A.Ş. and may not be quoted without citing the source.
- [State contribution rate cut from 30% to 20%](https://medyascope.tv/2026/01/07/beste-devlet-katkisi-yuzde-30dan-yuzde-20ye-indi/) — Official Gazette decision, 7 January 2026
- [State contribution vesting schedule](https://www.agesa.com.tr/bes/sss)
- [Rules on pausing BES contributions](https://www.turkiyegazetesi.com.tr/tasarruf-ortagim/bes-odemelerine-ara-verilebilir-mi-beste-5-yil-siniri-1822478)
- Google Data Analytics Certificate — Cyclistic and Bellabeat case studies (structural reference)
