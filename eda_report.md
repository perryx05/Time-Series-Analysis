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

These questions motivate the choice of models and the evaluation strategy detailed in subsequent sections.

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

### 4.1 Total Live Births (1960–2024)

*[Insert plot: 01_tlb_full.png]*

The TLB series shows a broadly declining long-run trend from around 60,000 births in 1960 to approximately 30,000–35,000 by the 2020s. Several notable features are visible:

- **Baby boom and rapid decline (1960s–1980s):** Birth numbers were high in the early 1960s, followed by a sharp decline coinciding with Singapore's family planning campaigns launched in 1965–1966, which actively discouraged large families.
- **Temporary uptick (late 1980s):** A modest reversal followed the "Have 3 or More Children" pro-natalist policy introduced in 1987.
- **Gradual decline (1990s–2010s):** Birth numbers continued falling as education levels rose, women's labour force participation increased, and housing and childcare costs became prohibitive.
- **COVID-19 effect (2020–2021):** A notable dip in births is observable around 2020–2021, consistent with pandemic-related disruptions to family formation globally.

The series appears **non-stationary** with a clear downward trend and no obvious seasonal component (as expected for annual data).

### 4.2 Total Fertility Rate (1960–2024)

*[Insert plot: 02_tfr_full.png]*

The TFR series mirrors the general pattern of TLB but is smoother and more clearly monotonically declining:

- TFR started at approximately 5.8 in 1960, reflecting a typical developing-economy fertility level.
- It fell rapidly below the replacement rate of 2.1 by the mid-1970s, driven by family planning policy.
- Since the 1980s, TFR has been persistently below 2.1, reaching historical lows near 1.0–1.1 by the 2020s.
- The series is more uniformly smooth than TLB, with fewer short-run fluctuations.

### 4.3 Moving Average Trend

*[Insert plot: 05_tlb_ma_trend.png]*

A 5-year centred moving average superimposed on the raw TLB series confirms the dominant downward trend, while the residuals from the trend reveal short-run variation that may be linked to policy changes and economic cycles.

### 4.4 Training vs Test Split

*[Insert plot: 04_train_test_split.png]*

The training period (1960–2012) captures the main structural decline. The test period (2013–2024) continues the downward trend but with less certainty, partly due to COVID-19. This split is appropriate because it tests whether models trained on historical data can generalise to a period with new policy contexts.

---

## 5. Analysis of Time Series Features

### 5.1 ACF and PACF

*[Insert plots: 06_tlb_acf_pacf.png]*

The ACF for TLB on the training data shows slow decay across many lags, consistent with a non-stationary process containing a unit root or near-unit-root. The PACF shows a single significant spike at lag 1, suggesting an AR(1) structure may be present.

After first differencing, the ACF cuts off more sharply (within [lags X]), and the PACF shows [describe your result]. This is consistent with an ARIMA(p, 1, q) model being appropriate.

For TFR, the ACF also shows slow decay. After differencing, [describe result]. This also suggests an ARIMA specification on the differenced series.

### 5.2 Stationarity Tests

| Series        | ADF p-value | KPSS p-value | Conclusion        |
|---------------|-------------|--------------|-------------------|
| TLB (raw)     | [XX]        | [XX]         | Non-stationary    |
| TFR (raw)     | [XX]        | [XX]         | Non-stationary    |
| TLB (diff 1)  | [XX]        | [XX]         | Stationary        |
| TFR (diff 1)  | [XX]        | [XX]         | Stationary        |

The ADF test (H₀: unit root present) and KPSS test (H₀: stationary) give complementary evidence. Both raw series appear non-stationary. After first differencing, both series achieve stationarity, indicating d = 1 is appropriate for ARIMA modelling.

---

## 6. Preliminary Model Identification

Based on the ACF/PACF patterns on the differenced training data, the following candidate models are identified:

### 6.1 TLB Candidate Models

**Candidate 1: ARIMA(p, 1, q)**  
- Orders p and q selected based on significant lags in PACF and ACF of the first-differenced series respectively.
- Tentative specification: ARIMA([X], 1, [X]) — to be refined.
- In-sample AIC: [XX]; BIC: [XX]
- Residual ACF shows [white noise / remaining structure — describe].

**Candidate 2 (for Final Report): [e.g., Holt's Linear Trend / Random Walk with Drift]**  
- Rationale: [brief justification]

### 6.2 TFR Candidate Models

**Candidate 1: ARIMA(p, 1, q)**  
- Tentative specification: ARIMA([X], 1, [X])
- In-sample AIC: [XX]; BIC: [XX]
- Residual diagnostics: [describe]

**Candidate 2 (for Final Report):** [to be added]

---

## 7. Model Assessment Strategy

To evaluate which model is best for forecasting 2013–2024, the following criteria will be used:

**In-sample (training fit, 1960–2012):**
- AIC and BIC — penalise model complexity; lower is better.
- Residual diagnostics — ACF/PACF of residuals should resemble white noise; Box-Ljung test p-value should be > 0.05.

**Out-of-sample (forecast accuracy, 2013–2024):**
- Root Mean Squared Error (RMSE) — penalises large errors.
- Mean Absolute Error (MAE) — robust to outliers.
- Mean Absolute Percentage Error (MAPE) — allows comparison across TLB and TFR scales.
- Visual inspection of forecast vs actual plot — important for assessing direction and structural plausibility.

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

### C. KPSS Test

The KPSS test decomposes the series as Y_t = μ_t + η_t where η_t is a random walk. H₀ is stationarity (variance of η_t = 0). A significant test statistic indicates non-stationarity.

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
