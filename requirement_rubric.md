# Assignment Reference: Singapore Birth and Fertility Time Series Analysis

> This file is the **single source of truth** for the assignment.
> All code and report writing must strictly follow the requirements and rubric below.
> Refer to this file before making any decision about what to analyse, how to structure code, or how to write the report.

---

## Project Overview

Produce a **fully reproducible statistical report** analysing Singapore birth and fertility data with temporal features, stored in a GitHub repository. The assignment is split into two parts: **EDA (Part 1)** and a **Final Report (Part 2)**. This file covers both, but the immediate deliverable is Part 1 (EDA).

**Data:** Singapore Total Live Births (TLB) and Total Fertility Rate (TFR), 1960–2024
**Data source:** https://www.singstat.gov.sg/ (Live Births and Fertility Rates table)
**Language:** R (base R preferred; additional packages allowed where justified)
**Reproducibility:** All code must run end-to-end from raw data without manual intervention

---

#

**Only commit** README.md, eda.R, dataset

---

## GitHub Requirements (checked by lecturer)

- Repository must be hosted on **GitHub**
- Must have a **thorough and informative README.md**
- **Commit regularly** — at least once per major analysis step, spread over time through the semester (not all at once at the end)
- Commit history must demonstrate a logical, progressive workflow
- The GitHub URL must be included inside the EDA report itself
- Code must be **well-structured and documented** through clear and informative inline comments

---

## Metadata
- Total Fertility Rate (TFR): Data prior to 1980 pertain to total population. Data from 1980 onwards pertain to resident population (i.e. Singapore citizens and permanent residents).
- Total Live-Births: Data for 2025 are based on date of registration, while data for years prior to 2025 are based on date of occurrence.



## Part 1: Exploratory Data Analysis (EDA)

### Scope

- Analyse **TLB and TFR from 1960 to 2024** for EDA (full range)
- The EDA does **not** need to be a formal report, but must be clearly written and well structured
- At minimum, include all elements listed in the rubric sections below

### Data Requirements

- Use only **Total Live Births (TLB)** and **Total Fertility Rate (TFR)**
- Years: **1960 to 2024** (65 annual observations)
- Training split: **1960–2012** (53 obs) — used for model fitting
- Test split: **2013–2024** (12 obs) — used for forecast evaluation

### Required EDA Elements

#### 1. Data Description
- Describe the data clearly, accurately, and critically
- Emphasise **salient temporal features** (trend, structural breaks, notable events)
- Describe any data limitations
- Document all **data cleaning steps** taken
- Include well-chosen **visualisations** that illustrate the temporal features
- All visualisations must be clearly described and used to support the data description

#### 2. Analysis of Time Series Features
- Produce and interpret **ACF and PACF plots** for both TLB and TFR (use training data)
- Perform **stationarity tests**: ADF test and KPSS test, on both raw and differenced series
- Apply and justify **composition of time series methods** (e.g. moving average decomposition, differencing)
- Provide **comprehensive and correct interpretation** of all results with reference to the data context (social and policy events)
- Analysis must follow a **coherent workflow** — each step must flow logically from the previous

#### 3. Preliminary Model Identification (for EDA, minimum 1 per series)
- Identify **at least 1 viable candidate time series model** for TLB (1960–2012)
- Identify **at least 1 viable candidate time series model** for TFR (1960–2012)
- These will be extended to **at least 2 models each** in the Final Report
- For each candidate model:
  - State the model form and justify the choice based on EDA findings
  - Fit the model on training data (1960–2012)
  - Check residual diagnostics (ACF/PACF of residuals, Box-Ljung test)
  - Report AIC and BIC

#### 4. Model Assessment Strategy
- Clearly discuss **how you will assess which model is best** for forecasting 2013–2024
- Must include both **in-sample criteria** (AIC, BIC, residual diagnostics) and **out-of-sample criteria** (RMSE, MAE, MAPE)
- Explain the trade-offs between criteria

#### 5. Research Questions
- State **1 to 3 research questions**, clearly and succinctly
- Questions must be **motivated by the EDA findings** and strongly linked to the data context
- For each question, outline what analysis could address it
- Acknowledge limitations or difficulties in answering the questions

#### 6. Literature Review (brief)
- If literature exists on time series modelling of TLB or TFR (Singapore or other countries), include a short discussion
- Focus on techniques used, as these may be relevant to your own model choices
- Literature may justify your model selection over what pure statistical tests suggest

#### 7. Social and Economic Context
- Discuss known policy events and social factors that influence TLB and TFR
  - e.g. family planning campaigns (1965), "Have 3 or More" policy (1987), Baby Bonus schemes, COVID-19
- Be prepared to justify choosing a model for social/contextual reasons even if statistical tests suggest otherwise
- This discussion should be integrated into the EDA narrative, not siloed at the end

#### 8. Statistical Appendix
- Include mathematical descriptions of **all statistical tests used** (ADF, KPSS)
- Include mathematical descriptions of **all models considered**
- Include formulae for **all forecast accuracy metrics** used
- Descriptions must be comprehensive, correct, and well-structured

---

## Part 2: Final Report (future deliverable — plan for it now)

> Not yet due, but EDA choices must be made with this in mind.

- Produce at least **2 viable time series models each** for TLB and TFR, fitted on 1960–2012
- Use models to **forecast 2013–2024** and compare against actual values
- Select the best model for each series with full justification (statistical + contextual)
- Justify any deviation from what statistical tests recommend (e.g. based on known structural breaks)
- Report must be formal, reproducible, and fully documented

---

## Rubric (EDA — used for marking)

| Criterion | HD Requirement | Marks |
|---|---|---|
| **Coding and GitHub** | Repo on GitHub with full commit history. README thorough and instructive. Commit history shows effective workload distribution over time. Flawless, reproducible, well-structured R code with clear and informative comments. | 1 pt (HD: > 0.84) |
| **Data description** | Data clearly, accurately, and critically described with strong emphasis on salient temporal features. Limitations described. Data cleaning documented. Visualisations well chosen to illustrate key temporal features. Visualisations clearly described and used cohesively. | 2 pts (HD: > 1.69) |
| **Analysis of time series features** | Temporal features comprehensively evaluated with appropriate statistical tests and visualisations. Composition of time series methods and advanced techniques used appropriately with strong justification. Analysis described succinctly, clearly, and accurately within a coherent workflow. Comprehensive and correct interpretation with strong reference to data context. | 4 pts (HD: > 3.39) |
| **Research questions** | 1–3 research questions clearly and succinctly stated, well-motivated by EDA, strongly linked to data context. Possible analyses clearly outlined. Limitations/difficulties integrated. | 1 pt (HD: > 0.84) |
| **Statistical appendix** | Comprehensive and well-structured mathematical descriptions of all statistical tests and models used. | 2 pts (HD: > 1.69) |

**Total: 10 points**

---

## Coding Standards (apply to all R code)

- Every section must start with a clearly labelled comment block: `# === SECTION X: Title ===`
- Every non-obvious line must have an inline comment explaining *why*, not just *what*
- No hardcoded file paths — use relative paths from the project root
- All plots must have: title, axis labels with units, legend where applicable
- Save all plots to `plots/` directory (create if needed)
- Print all test statistics and p-values to console with descriptive labels
- Use `set.seed()` if any stochastic process is used
- Code must run in one go from top to bottom without errors
- Only write simple code syntax. Based strictly on the style in the reference folder which is Time Series Note

---

## Key Decisions Already Made

| Decision | Value |
|---|---|
| Language | R (base R + tseries package for ADF/KPSS) |
| Report format | Markdown (.md) |
| Training period | 1960–2012 |
| Test/forecast period | 2013–2024 |
| Minimum models (EDA) | 1 per series (TLB, TFR) |
| Minimum models (Final) | 2 per series |
| Primary forecast metric | RMSE (out-of-sample) |
| Secondary metrics | MAE, MAPE, AIC, BIC |

---

## Checklist Before Each Commit

- [ ] Code runs end-to-end without errors
- [ ] New plots are saved to `plots/` and referenced in the report
- [ ] Test results (ADF, KPSS, Box-Ljung) are printed with descriptive labels
- [ ] Report narrative is updated to reflect the latest analysis step
- [ ] Commit message clearly describes what was done (e.g. `Add ACF/PACF plots and stationarity tests for TLB`)
- [ ] No reference notes or zip files accidentally staged

---

*Last updated: [Date] — update this line whenever requirements are revised.*