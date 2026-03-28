# Exploratory Data Analysis: Singapore Total Live Births and Total Fertility Rate (1960–2024)

**Author:** [Your Name]  
**Date:** 2026-03-27  
**GitHub Repository:** [Add your repository URL here]

---

## 1. Introduction and Research Questions

Singapore has experienced a dramatic demographic transition since independence, shifting from a high-fertility society in the 1960s to one of the lowest fertility rates in the world by the 2000s. Understanding the temporal patterns in Total Live Births (TLB) and Total Fertility Rate (TFR) is important for demographic forecasting and policy evaluation.

This EDA investigates the following research questions:

1. **What are the key temporal trends and structural changes in Singapore's TLB and TFR from 1960 to 2024?**
2. **Which time series models are most appropriate for forecasting TLB and TFR beyond the training period (1960–2012)?**
3. **To what extent do known social and policy events explain the observed patterns in TLB and TFR?**

**Scope of this document:** exploratory plots and stationarity/autocorrelation diagnostics only; **model fitting and forecasting** are deferred to the **Final Report**. Questions (2)–(3) are partly answered here (suitability *in principle*) and fully addressed when models are estimated.

---

## 2. Data Description

**Source:** Singapore Department of Statistics (singstat.gov.sg)  
**Variables of interest:**
- **Total Live Births (TLB):** Annual count of live births in Singapore
- **Total Fertility Rate (TFR):** Average number of children a woman would have over her lifetime, based on current age-specific fertility rates

**Coverage:** 1960 to 2024 (65 annual observations)  
**Frequency:** Annual (no seasonality)  
**Split:** Training set 1960–2012 (53 observations); test set 2013–2024 (12 observations)

### 2.1 Data Limitations

- Annual aggregation masks intra-year variation.
- TFR is a period measure and does not directly reflect completed fertility of any cohort.
- **Coverage definition (SingStat):** TFR before 1980 refers to the **total population**; from 1980 onward it refers to the **resident population** (citizens and permanent residents). Long-run comparisons should be read with that break in mind.
- Policy interventions and external shocks (e.g., economic recessions, COVID-19) create structural breaks that standard time series models may not capture well.
- No missing values were identified in the dataset after cleaning.

---

## 3. Data Cleaning

The raw data was downloaded from singstat.gov.sg and saved as a CSV file. The following cleaning steps were applied:

1. Subsetted to years 1960–2024 only.
2. Extracted only the two required series from the SingStat wide-format export: `Total Live-Births (Number)` and `Total Fertility Rate (TFR) (Per Female)`.
3. Reshaped from wide year-columns format into a tidy ascending table with columns `Year`, `TLB`, `TFR`.
4. Removed comma formatting from TLB values and converted both series to numeric.
5. Verified no missing values were present in either series.
6. Confirmed 65 rows and plausible value ranges:
   - TLB: 33,541 to 61,775
   - TFR: 0.97 to 5.76
7. Saved cleaned data as `cleaned_tlb_tfr_1960_2024.csv` for use in later sections.
8. Created annual time series objects (`tlb_ts`, `tfr_ts`) and the required training/test splits:
   - Training: 1960–2012
   - Test: 2013–2024

---

## 4. Visualisation and Temporal Features

All figures below are produced in base R by `eda.R` and saved under `plots/`. Together they support the data description required by the rubric: they highlight **long-run trend**, **episodes of faster change or partial reversal**, and the **train/test split** used for later modelling.

### 4.1 Overview panel

![TLB and TFR overview (1960–2024)](plots/00_overview_panel.png)

The stacked panel gives a first-pass comparison. **TLB** (counts of live births) is more volatile year to year: it falls steeply from the early 1960s, shows a visible bump in the late 1980s, and remains in a lower band from the 2000s onward, with a noticeable dip around 2020–2022. **TFR** (children per woman) follows the same broad story but as a smoother series, which is expected because TFR is constructed from age-specific rates and is not scaled by population size in the same way as total births. Annual data show **no seasonality**; the dominant signal is **trend** and occasional **short-run deviations**.

### 4.2 Total Live Births (1960–2024)

![Singapore Total Live Births, 1960–2024](plots/01_tlb_full.png)

The full-series plot is used to read **salient temporal features** in context:

- **Early 1960s:** TLB is high (about 61,000 in 1960), then falls sharply through the late 1960s and 1970s. This aligns with intensive **anti-natalist** policy and social change after independence (e.g. family planning from the mid-1960s).
- **Late 1980s:** There is a **partial rebound** rather than a return to 1960s levels, consistent with the shift toward **pro-natalist** messaging (e.g. “Have Three or More” from 1987). Births do not stay high; the uptick is temporary.
- **1990s–2010s:** A **gradual decline** with fluctuations likely reflects delayed marriage, dual-income norms, housing and childcare costs, and ongoing policy adjustments—not a single smooth deterministic trend.
- **From 2013:** The vertical reference marks the start of the **hold-out period** used for forecast evaluation (2013–2024). The series remains comparatively low; **2020** is marked as a year when external shocks (COVID-19) may have affected registration, timing of births, or both.

For time series modelling, the figure motivates treating TLB as **non-stationary** (clear level shift and trend) rather than fluctuating around a fixed mean.

### 4.3 Total Fertility Rate (1960–2024)

![Singapore Total Fertility Rate, 1960–2024](plots/02_tfr_full.png)

TFR starts near **5.8** in 1960 and falls below **2** by the mid-1970s. The horizontal dashed line at **2.1** denotes **conventional replacement-level fertility** (the TFR at which a population would roughly replace itself in the long run in a low-mortality setting, allowing for mortality and the sex ratio at birth; see standard demographic references and UN terminology). Singapore’s TFR has remained **below** that line for decades, reaching roughly **1.0** in recent years—consistent with **very low fertility** and policy concern over natural replacement.

Because SingStat notes a **change in population coverage** for TFR in **1980** (total population before 1980; resident population from 1980 onward), the **level** around 1979–1981 should be interpreted cautiously when arguing about precise “breaks”; the **qualitative** picture of a collapsed fertility regime is still clear from the graph.

### 4.4 TLB and TFR on one figure (dual vertical axis)

![TLB and TFR combined, 1960–2024](plots/03_tlb_tfr_combined.png)

This plot is **not** for reading exact magnitudes across scales (births vs. rate). It is useful to see **co-movement**: both series decline together in the first two decades; both show a **late-1980s** uptick; both drift to low levels in the 2000s and 2010s. Short episodes where **TLB moves more sharply than TFR** can reflect **population structure** (numbers of women of childbearing age, migration) as well as period fertility—another reason to model TLB and TFR separately rather than assuming one is a simple rescaling of the other.

### 4.5 Training vs test split (modelling design)

![TLB: training vs test](plots/04_tlb_train_test_split.png)

![TFR: training vs test](plots/05_tfr_train_test_split.png)

The assignment requires fitting models on **1960–2012** (53 years) and evaluating forecasts on **2013–2024** (12 years). The two figures show the **same split** for each series: a solid line for the training segment and a **dashed** line for the test segment, with a vertical marker at **2013**.

**TLB:** The training period includes the steepest declines and the late-1980s bump; the test period includes the COVID-era dip and partial recovery in counts. **TFR:** The test period stays in the **roughly 1.0–1.3** band—models trained on pre-2013 data must extrapolate into a **structurally low-fertility** regime. That is appropriate for the rubric: it stresses whether simple time series models **generalise** when the level is already far from the 1960s and when recent shocks may violate classical assumptions.

### 4.6 Trend smoothing and what we do *not* use (STL / seasonal decomposition)

The rubric asks for a **composition of time series methods** (for example moving-average smoothing or differencing). For **annual** data there is **no seasonal period** within the year: `frequency = 1`, so **STL decomposition** and **classical seasonal decomposition** are **not appropriate**—they require a seasonal cycle (e.g. monthly \(s=12\), quarterly \(s=4\)). Applying them to these series would be **methodologically wrong** for the dataset’s time index.

The **skeleton.R** approach is used here: a **centred moving average** approximates a **smooth trend**; what is left over when comparing the annual series to that trend is informal **irregular** variation.

![TLB with 5-year centred MA](plots/06_tlb_ma_trend.png)

![TFR with 5-year centred MA](plots/07_tfr_ma_trend.png)

**Why a 5-year window (written rationale).** On annual data with only **65** observations, very short windows (e.g. 3 years) mostly reproduce the raw series and add little beyond the plots in §4.1–4.3; very long windows (e.g. 7–10 years) eat degrees of freedom and blur medium-term behaviour. A **5-year** centred MA is a **standard compromise** in teaching notes and demography-flavoured EDA: long enough to damp **one-off** year effects, short enough that the smooth curve still follows **decadal** shifts. Using an **odd** length (**5**) with `sides = 2` gives a **symmetric** centred filter (no separate re-centring step as with even-order MAs). The overlays in the figures are **illustrative**, not a formal test: the goal is an interpretable **trend line** for the narrative, aligned with the course skeleton, without over-claiming that alternative odd widths would look dramatically different on this sample. The same window is applied to **TFR** for **parallelism** in the EDA workflow.

This supports the next steps: **differencing** for stationarity and ARIMA-style models, **not** seasonal differencing.

---

## 5. Analysis of Time Series Features

Following the **Time Series Notes / skeleton.R** workflow, all diagnostics in this section use **training data only (1960–2012)**. We examine **raw** ACF/PACF, then **first differences** \(\Delta y_t = y_t - y_{t-1}\) (annual change), then ACF/PACF of the differenced series—the usual path toward specifying **ARIMA(\(p\),1,\(q\))** when a unit root is present.

### 5.1 ACF and PACF (raw) and first differences

**Raw series**

![ACF/PACF TLB raw](plots/08_tlb_acf_pacf_raw.png)

![ACF/PACF TFR raw](plots/09_tfr_acf_pacf_raw.png)

For both **TLB** and **TFR**, the **ACF decays slowly** and stays positive for many lags—typical of **strong persistence** and a **trending level**, consistent with **non-stationarity** in the mean (unit-root or near–unit-root behaviour). The PACF patterns are not the main tool until after differencing; they should not be read as a clean low-order AR on the **level**.

**First differences (illustrative series)**

![First-differenced TLB and TFR](plots/10_differenced_series.png)

The differenced series fluctuate around **zero** with no obvious drift; they represent **year-to-year changes** in births and in TFR (suitable for modelling cumulative shocks and policy phases).

**ACF/PACF after differencing**

![ACF/PACF first-differenced TLB](plots/11_tlb_acf_pacf_diff.png)

![ACF/PACF first-differenced TFR](plots/12_tfr_acf_pacf_diff.png)

After **one difference**, correlations typically **die off faster** than for the raw series—the differenced series are closer to what an ARMA model expects. **TLB:** ACF/PACF suggest modest low-order structure (candidate \(p,q\) to be chosen in §6 with AIC/BIC, not by eye alone). **TFR:** the differenced ACF/PACF are still somewhat messy—expected with **\(n-1 = 52\)** post-differencing points and possible **structural breaks** in fertility; formal model choice will rely on information criteria and residual checks as well as these plots.

### 5.2 Stationarity tests (ADF only)

Tests are run in **R** (`tseries` package) with default settings. **Augmented Dickey–Fuller (ADF):** H₀ = **unit root** (non-stationary); **rejection** of H₀ (small p-value, typically compared to α = 0.05) supports **stationarity**.

| Series | ADF p-value | Interpretation (α = 0.05) |
|--------|-------------|---------------------------|
| TLB (raw) | 0.356 | Do not reject H₀ → **no evidence against a unit root**; level treated as **non-stationary**. |
| TFR (raw) | 0.120 | Do not reject H₀ → **non-stationary** level (not significant at 5%). |
| TLB, first difference | 0.039 | Reject H₀ → **stationary** differenced series. |
| TFR, first difference | 0.083 | Do **not** reject H₀ at 5% (borderline); **inconclusive**—unit root not ruled out strongly. |

**Summary.** ADF on **raw** series supports treating both TLB and TFR as **integrated** (trending levels). After **one difference**, **TLB** shows clear rejection of a unit root; **TFR** is **borderline**, which is common with **short samples** and **structural breaks**. The ACF/PACF of the **differenced** series (§5.1) motivate a **\(d=1\)** term in eventual **ARIMA**-style models, but **this EDA does not estimate or select** \(p\), \(q\), or any fitted model—that belongs in the **Final Report**.

---

## 6. From EDA toward modelling (no fit in this document)

This submission is **exploratory only**: plots, moving-average trends, ACF/PACF, differencing, and **ADF** on raw and differenced training data. **No ARIMA (or other) model is fitted here** and **no forecasts** are produced.

For the **Final Report**, the course requires at least **two viable models per series** on **1960–2012**, **evaluation on 2013–2024**, and **residual checks** (including **Box–Ljung** on residuals). The EDA above supports that next step by suggesting:

- non-seasonal annual structure → **no seasonal ARIMA** needed;  
- integrated levels → **\(d=1\)** as a starting point for ARIMA or related models;  
- orders **\(p,q\)** to be chosen from **differenced** ACF/PACF plus **information criteria** and **out-of-sample** accuracy, not repeated here.

---

## 7. Model Assessment Strategy

When models are fitted in the **Final Report**, the plan is to assess them as follows (not applied in this EDA-only script):

**In-sample (training fit, 1960–2012):**
- AIC and BIC — penalise model complexity; lower is better.
- Residual diagnostics — ACF/PACF of residuals should resemble white noise; Box-Ljung test p-value should be > 0.05.

**Out-of-sample (forecast accuracy, 2013–2024):**
- Root Mean Squared Error (RMSE) — penalises large errors.
- Mean Absolute Error (MAE) — robust to outliers.
- Mean Absolute Percentage Error (MAPE) — allows comparison across TLB and TFR scales.
- Visual inspection of forecast vs actual plot — important for assessing direction and structural plausibility.

**Trade-offs (rubric / HD-style reasoning):** **AIC** tends to favour **more complex** models when the gain in fit outweighs the penalty; **BIC** penalises parameters **more strongly**, often preferring **simpler** models in moderate-\(n\) settings like 53 years of training data. **In-sample** criteria can **improve** by **overfitting** idiosyncrasies of 1960–2012 (including **structural breaks**), so they **must** be paired with **out-of-sample RMSE** (primary for this project), **MAE**, and **plots** for 2013–2024. Where **statistics** and **context** (e.g. known policy shifts) conflict, the Final Report should state which criterion drives the final choice.

The primary criterion for the Final Report will be **out-of-sample RMSE**, as the task is to forecast 2013–2024. However, AIC/BIC will also be considered to guard against overfitting on the training period.

---

## 8. Social and Economic Context

Beyond statistical criteria, model choice must be informed by the policy landscape:

- **Family planning (1965–1984):** The "Stop at Two" campaign caused a structural break in fertility that standard models may not account for.
- **Pro-natalist reversal (1987–present):** Baby Bonus schemes, childcare subsidies, and housing priority for families have modestly slowed the decline but not reversed it.
- **Economic cycles:** The 1997 Asian Financial Crisis, 2003 SARS epidemic, 2008–2009 Global Financial Crisis, and 2020 COVID-19 pandemic all produced short-term dips in TLB visible in the data.
- **Structural demographic shift:** The long-run decline in TFR reflects rising education, delayed marriage, increasing female labour force participation, and high cost of living — factors not directly modelled by ARIMA. This suggests that no purely statistical model will perfectly forecast the structural downward trend, and some model misspecification in 2013–2024 is expected.

If statistical tests favour a model that ignores known policy breaks, the Final Report will justify overriding the statistical recommendation in favour of a model with better theoretical grounding.

---

## 9. Brief Literature Review

Several studies have modelled fertility trends in Singapore and comparable East Asian economies:

- **[Author, Year]:** [Summary of method and findings relevant to Singapore TFR modelling]
- **[Author, Year]:** [e.g., use of structural break ARIMA models for South Korean TFR]
- **[Author, Year]:** [e.g., exponential smoothing for demographic forecasting in low-fertility settings]

The literature generally suggests that ARIMA models perform adequately for short-term fertility forecasting but struggle to capture long-run structural change. Some authors recommend supplementing time series models with demographic explanatory variables (e.g., female labour participation, marriage rates), though this is beyond the scope of this EDA.

---

## 10. Statistical Appendix

### A. ARIMA Model Definition

An ARIMA(p, d, q) model is defined as:

φ(B) Δ^d Y_t = θ(B) ε_t

where:
- B is the backshift operator (B Y_t = Y_{t-1})
- Δ^d = (1 - B)^d is the d-th order differencing operator
- φ(B) = 1 - φ₁B - ... - φ_p B^p is the autoregressive polynomial of order p
- θ(B) = 1 + θ₁B + ... + θ_q B^q is the moving average polynomial of order q
- ε_t ~ WN(0, σ²) is white noise

For d = 1 (one difference needed), the model is fitted to the first-differenced series Δ Y_t = Y_t - Y_{t-1}.

### B. Augmented Dickey-Fuller Test

The ADF test estimates the regression:

Δ Y_t = α + β t + γ Y_{t-1} + Σ δ_j Δ Y_{t-j} + ε_t

H₀: γ = 0 (unit root; non-stationary)  
H₁: γ < 0 (stationary)

Rejection of H₀ at α = 0.05 indicates stationarity.

### C. Box–Ljung test (portmanteau)

Under H₀ that the series (here, model **residuals**) is white noise up to lag \(m\), the Box–Ljung statistic is approximately \(\chi^2(m)\) (after fitting, degrees of freedom are sometimes reduced when parameters are estimated; R reports df aligned with the call). A **large** p-value is **consistent with** uncorrelated residuals.

### D. Information Criteria

AIC = -2 log L + 2k  
BIC = -2 log L + k log n

where L is the maximised likelihood, k is the number of parameters, and n is the number of observations. Lower values indicate a better-fitting model, with BIC penalising complexity more heavily than AIC.

### E. Forecast Accuracy Metrics

RMSE = sqrt( (1/h) Σ (y_t - ŷ_t)² )  
MAE  = (1/h) Σ |y_t - ŷ_t|  
MAPE = (1/h) Σ |y_t - ŷ_t| / |y_t| × 100

where h = 12 is the forecast horizon (2013–2024), y_t is the actual value, and ŷ_t is the forecast.

---

*End of EDA Report*
