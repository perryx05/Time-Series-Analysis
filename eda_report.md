# Exploratory Data Analysis: Singapore Total Live Births and Total Fertility Rate (1960–2024)

**Author:** Minh Chien Nguyen  
**GitHub Repository:** <https://github.com/perryx05/Time-Series-Analysis>

---

## 1. Introduction and Research Questions

Singapore has experienced a significant demographic transition since gaining independence, going from a high-fertility country in the 1960s to having one of the lowest fertility rates in the world by the 2000s. Understanding the trends in Total Live Births (TLB) and Total Fertility Rate (TFR) is important for demographic forecasting and policy evaluation.

This EDA investigates the following research questions:

1. **What are the key temporal trends and structural changes in Singapore's TLB and TFR from 1960 to 2024?**
2. **Which possible time series models are appropriate for forecasting TLB and TFR beyond the training period (1960–2012)?**
3. **To what extent do known social and policy events explain the observed patterns in TLB and TFR?**


---

## 2. Data Description

**Source:** Singapore Department of Statistics (singstat.gov.sg)  
**Variables of interest:**

- **Total Live Births (TLB):** Annual count of live births in Singapore
- **Total Fertility Rate (TFR):** Average number of children a woman would have over her lifetime, based on current age-specific fertility rates

**Period:** 1960 to 2024 (65 annual observations)  
**Frequency:** Annual (no seasonality)  
**Split:** Training set 1960–2012 (53 observations); test set 2013–2024 (12 observations)

### 2.1 Data Limitations

- Annual aggregation cannot highlight the intra-year variation.
- TFR is a period measure and does not directly reflect completed fertility of any cohort.
- **Coverage definition (SingStat):** TFR before 1980 refers to the **total population**; from 1980 onward it refers to the **resident population** (citizens and permanent residents). Long-run comparisons should consider this change.
- Policy interventions and external shocks (e.g., economic recessions, COVID-19) create structural breaks that standard time series models may not capture well.
- No missing values were identified in the dataset.

---

## 3. Data Cleaning

The raw data was downloaded from singstat.gov.sg and saved as a CSV file. The following cleaning steps were applied:

1. Extracted only the two required series from the SingStat wide-format export: `Total Live-Births (Number)` and `Total Fertility Rate (TFR) (Per Female)`.
2. Reshaped from wide year-columns format into a tidy table with only 3 columns `Year`, `TLB`, `TFR`.
3. Removed comma formatting from TLB values and converted both series to numeric.
4. Verified no missing values were present in either series.
5. Confirmed 65 rows and plausible value ranges:
   - TLB: 33,541 to 61,775
   - TFR: 0.97 to 5.76
6. Saved cleaned data as `cleaned_tlb_tfr_1960_2024.csv` for use in later sections.
7. Created annual time series objects (`tlb_ts`, `tfr_ts`) and the required training/test splits:
   - Training: 1960–2012
   - Test: 2013–2024

---

## 4. Visualisation and Temporal Features


### 4.1 Overview panel

![TLB and TFR overview (1960–2024)](plots/00_overview_panel.png)

Looking at the two graphs together we can have a good starting point for understanding the data. The Total Live Births (TLB) number tends to move up and down quite a lot from year to year. It drops quite sharply from the early 1960s, then there is a noticeable increase around the late 1980s, and after the 2000s it stays at a generally lower level. There is also a clear fall happening around 2020 to 2022. For the Total Fertility Rate (TFR), the overall pattern looks similar, but the line is much smoother compared to TLB. This makes sense because TFR is calculated from age-specific birth rates, so it does not get affected by the total population size in the same way as the raw birth count does. Since this data is recorded every year, there is no seasonal pattern to observe. The main thing we can see is the long-term downward trend, with some short periods where the numbers went slightly higher or lower than expected.

### 4.2 Total Live Births (1960–2024)

![Singapore Total Live Births, 1960–2024](plots/01_tlb_full.png)


- **Early 1960s:** TLB was high (about 61,000 in 1960), but then it dropped quite sharply through the late 1960s and 1970s. This may be connected to intensive government policy and social change to reduce births after independence. For example, the Singapore Family Planning and Population Board was established in 1966 as part of a national programme to control population growth (OBGyn Key n.d.).
- **Late 1980s:** The number of births increased slightly, which could be related to the change in government message at that time. Specifically, the **"Have Three or More if You Can Afford It"** campaign was announced in 1987 (National Library Board Singapore 2000). But this increase did not last long and the number did not go back to the same level as the 1960s.
- **1990s–2010s:** Births continued to slowly go down, but with some up and down movement along the way. This is likely due to several reasons happening at the same time — such as people getting married later, more women working, and the high cost of housing and childcare — rather than one simple cause.
- **From 2013:** The dotted vertical line around 2013 marks the beginning of the period used to test how well the forecasting model performs, which covers 2013 to 2024. The birth numbers remain quite low; 2020 is marked as a year when external shocks (COVID-19) may have affected when babies were born and when births were officially recorded.

For time series modelling, the figure suggests that treating TLB as **non-stationary** (clear level shift and trend) rather than fluctuating around a fixed mean.

### 4.3 Total Fertility Rate (1960–2024)

![Singapore Total Fertility Rate, 1960–2024](plots/02_tfr_full.png)

TFR starts near **5.8** in 1960 and drops below **2** by the mid-1970s. The horizontal dashed line at **2.1** is **replacement-level fertility** (a standard demographic benchmark; see United Nations Statistics Division n.d.). Singapore’s TFR has remained below that line for many decades, reaching roughly **1.0** in recent years, which is considered extremely low and is a major concern for the government when thinking about whether the population can replace itself naturally.

Because SingStat notes a **change in population coverage** for TFR in **1980** (total population before 1980; resident population from 1980 onward), the level around 1979–1981 should be interpreted cautiously when arguing about precise “breaks”. However, this technical detail does not really change the overall picture — it is still very clear from the graph that Singapore's fertility rate collapsed dramatically over this period.

### 4.4 TLB and TFR on one figure (dual vertical axis)

![TLB and TFR combined, 1960–2024](plots/03_tlb_tfr_combined.png)

This plot is not for reading exact numbers between two measurements (births vs. rate). It is useful to see **how the two lines move together over time**: both series decline together in the first two decades; both show a small increase in the **late 1980**; both end up at low levels in the **2000s and 2010s**. However, there are some short periods where the total live births line moves more sharply up or down compared to the TFR line. This can happen because TLB is also affected by things like how many women of childbearing age are in the population at a given time, or changes due to migration — not just whether women are choosing to have more or fewer children. This is one of the reasons why it makes more sense to model TLB and TFR as two separate series, rather than assuming that one is simply a scaled-up or scaled-down version of the other.

### 4.5 Training vs test split (modelling design)

![TLB: training vs test](plots/04_tlb_train_test_split.png)

![TFR: training vs test](plots/05_tfr_train_test_split.png)

The data is divided into two parts. The first part, from **1960 to 2012 (53 years)**, is used to train the models, while the second part, from **2013 to 2024 (12 years)**, is used to test how good the models can forecast. In each graph, the solid line represents the training period and the dashed line represents the test period, with a vertical marker showing where the split happens at 2013.

For the **Total Live Births**, the training period covers the most significant drops in birth numbers as well as the small increase in the late 1980s. The test period, on the other hand, includes the fall in births that happened around the COVID-19 period and some recovery afterwards. For the Total Fertility Rate, the test period stays within a quite narrow and very low range of roughly 1.0 to 1.3 children per woman. This means the models, which were only trained on data before 2013, need to make predictions for a period where fertility is already extremely low — quite far from where it started in the 1960s.

### 4.6 Trend smoothing and what we do *not* use (STL / seasonal decomposition)

For annual data there is no seasonal period within the year: `frequency = 1`, so STL decomposition and classical seasonal decomposition are not appropriate — they require a seasonal cycle (e.g. monthly s=12, quarterly s=4). 

Our approach uses a **centred moving average** to approximate a **smooth trend**; what is left over when comparing the annual series to that trend is informal irregular variation.

![TLB with 5-year centred MA](plots/06_tlb_ma_trend.png)

![TFR with 5-year centred MA](plots/07_tfr_ma_trend.png)

**Why a 5-year window.** A 5-year centred moving average was selected over shorter or longer windows. A 3-year MA retains too much of the short-term ups and downs in the data, while a 7-year MA over-smooths and ends up hiding some important changes in the mid-1970s and late 1980s. The 5-year window also aligns with Singapore's governmental planning cycles, providing a substantively meaningful smoothing interval. Another practical reason for using a 5-year odd-ordered centred moving average is that it does not require an extra re-centring step, which would be needed if an even-numbered window was used instead.

---

## 5. Social and Economic Context

The patterns visible in TLB and TFR cannot be fully understood through statistical analysis. Several known policy events and social changes have directly shaped the data, and any time series model trained on this period will be implicitly fitting through these structural changes.

- **1966 — Family planning campaign:** The Singapore Family Planning and Population Board was established, launching an active campaign to discourage large families. This is closely associated with the sharp decline in TLB and TFR through the late 1960s and 1970s (OBGyn Key n.d.).
- **1987 — \"Have Three or More\" policy:** The government reversed its earlier position and introduced a pro-natalist message encouraging Singaporeans to have three or more children if they could afford it (National Library Board Singapore 2000). An increase in births is visible around this period, but the effect was temporary and small relative to the long-run decline.
- **1990s–2000s — Baby Bonus and other incentives:** The government introduced a range of financial supports, childcare subsidies, and housing priority policies to support families. Despite these efforts, TFR continued to fall, suggesting that many economic factors — high cost of living, delayed marriage, female labour force participation — were more dominant than policy supports alone.
- **2020–2021 — COVID-19:** The pandemic disrupted family formation patterns globally. A visible decrease in TLB around 2020–2021 is consistent with international trends where economic uncertainty and lockdown conditions led couples to postpone having children.

These events are important for model selection in the Final Report. A purely statistical model may not adequately capture these discrete structural changes, and any model that performs poorly on the 2013–2024 test period should be evaluated in light of whether the test period itself was unusual by historical standards (for example, COVID-19).

---

## 6. Analysis of Time Series Features

Following the workflow, all analytics in this section use **training data only (1960–2012)**: **raw** ACF/PACF, then **first differences** (annual change—each year minus the year before), then ACF/PACF of the differenced series. This is exploratory description of autocorrelation only. 

### 6.1 ACF and PACF (raw) and first differences

**Raw series**

![ACF/PACF TLB raw](plots/08_tlb_acf_pacf_raw.png)

![ACF/PACF TFR raw](plots/09_tfr_acf_pacf_raw.png)

For both **TLB** and **TFR** **ACF** plot, the bars stay quite high and drop down very slowly across many lags. This kind of pattern usually means the data has a strong memory — values from many years ago are still closely related to values today. This is a clear sign that both series are non-stationary, meaning they do not fluctuate around a fixed average but instead follow a long-running downward trend over time, which is consistent with what is sometimes called unit-root or near unit-root behaviour. The PACF patterns are not the useful tool until after differencing; trying to read it as a simple low-order autoregressive pattern on the original untransformed data would not give a meaningful or reliable result.

**First differences (illustrative series)**

![First-differenced TLB and TFR](plots/10_differenced_series.png)

After applying first differencing, both series now fluctuate around zero without any clear upward or downward drift. This means the data is now showing the year-to-year change — how much the number of births or the fertility rate went up or down compared to the previous year — rather than the overall level. This transformed version of the data is more suitable for modelling because it captures the accumulated effect of short-term shocks and the influence of different policy phases over time.

**ACF/PACF after differencing**

![ACF/PACF first-differenced TLB](plots/11_tlb_acf_pacf_diff.png)

![ACF/PACF first-differenced TFR](plots/12_tfr_acf_pacf_diff.png)

After **one difference**, the correlations die off much faster compared to the original series. This is what we want because AR / MA / ARMA models assume the series is roughly stationary around a stable mean.

For **TLB (annual change)**, the ACF and PACF at short lags (1–3) are mostly inside the confidence bands. This suggests the year-to-year change in births does not have a strong and stable autocorrelation pattern. A reasonable and very parsimonious first candidate is **ARMA(0,0)** for the differenced series (meaning the changes are close to white noise plus an average drift).

For **TFR (annual change)**, the PACF shows a clear spike at lag 1 while the ACF drops quickly. This pattern is often consistent with an **AR(1)** structure on the differenced series, so a sensible first candidate is **AR(1)** for the annual changes in TFR. Some later lags show spikes too, but because the sample after differencing is only 52 points and fertility has structural breaks, we start with a simple low-order model and rely on residual checks to see if the model is acceptable.

### 6.2 Stationarity tests

Tests are run in **R** (`tseries` package) with default settings. **Augmented Dickey–Fuller (ADF):** $H_0$ = **unit root** (non-stationary); **rejection** of $H_0$ (small p-value, typically compared to $\alpha = 0.05$) supports **stationarity**.

**Justification of the formula used above (first difference).** In $\Delta y_t = y_t - y_{t-1}$, $y_t$ means the series value in year $t$, $y_{t-1}$ means the previous year value, and $\Delta y_t$ is the year-to-year change (annual change). We use it because the level series has strong trend, and AR/MA/ARMA needs a more stable series.

| Series | ADF p-value | Interpretation ($\alpha = 0.05$) |
|--------|-------------|---------------------------|
| TLB (raw) | 0.356 | Do not reject $H_0$ → **no evidence against a unit root**; level treated as **non-stationary**. |
| TFR (raw) | 0.120 | Do not reject $H_0$ → **non-stationary** level (not significant at 5%). |
| TLB, first difference | 0.039 | Reject $H_0$ → **stationary** differenced series. |
| TFR, first difference | 0.083 | Do **not** reject $H_0$ at 5% (borderline); **inconclusive**—unit root not ruled out strongly. |

**Summary.** ADF on the raw series suggests both TLB and TFR are non-stationary in levels (they have strong trend / long memory). After one difference (annual change, $\Delta y_t = y_t - y_{t-1}$), **TLB** clearly becomes stationary by ADF at 5%. For **TFR**, the differenced ADF result is borderline at 5%, which is not unusual for short annual series with policy breaks. In this EDA we still proceed with modelling the annual changes using simple AR / MA / ARMA candidates, and we check if residuals look like white noise.

---

## 7. Preliminary Model Identification (training: 1960–2012)


For each candidate model below, we report:
- AIC and BIC (in-sample fit with complexity penalty)
- residual ACF/PACF (should look like white noise)
- Box–Ljung test on residuals (lag 10)

**Justification of terms (AIC/BIC and Box–Ljung).**  
- **AIC/BIC**: it can be considered as **fit − penalty**. Smaller is better. In formula form (for reference): **AIC = −2 log(L) + 2k** and **BIC = −2 log(L) + k log(n)**, where **L** is likelihood, **k** is number of parameters, **n** is sample size. BIC penalises complexity stronger than AIC, so BIC often prefers simpler model.  
- **Box–Ljung**: tests whether residual autocorrelations are jointly close to zero up to a chosen lag (here lag 10). In formula form (for reference): $Q = n(n+2)\sum_{k=1}^{m} r_k^2/(n-k)$ where $r_k$ is residual autocorrelation at lag $k$. A large p-value means residuals are consistent with white noise, which is what we want after fitting a good model.

### 7.1 TLB candidate: ARMA(0,0) on annual changes

**Model form.** We fit ARMA(0,0) on `diff(TLB_train)`. This is the simplest baseline model: it assumes the change from one year to the next is mostly just random variation around a constant average drift, with no additional autoregressive or moving average components built in, with no AR or MA structure. It is sometimes called a random walk with drift on the differenced series. Including it as a baseline is essential — it sets a minimum standard that any more complex model needs to clearly beat. If a more complicated model cannot outperform this basic benchmark, then the extra complexity is not really justified.

**Why this is reasonable.** The differenced ACF/PACF for TLB do not show clear and stable short-lag spikes, so adding AR or MA terms may not improve much in a reliable way. Starting with the simplest model helps us to avoid overfitting.

- **AIC / BIC (training):** AIC = **975.13**, BIC = **979.03**

![Residual ACF/PACF: TLB ARMA(0,0)](plots/13_tlb_arma00_residuals_acf_pacf.png)

- **Box–Ljung (lag 10):** p-value = **0.707** → do not reject white-noise residuals at 5%.

**Conclusion.** ARMA(0,0) is a potential preliminary candidate for TLB annual changes. In the Final Report we will compare it with at least one more flexible model (e.g. AR(1) or ARMA(1,1)) and decide based on forecast performance on 2013–2024.

### 7.2 TFR candidate: AR(1) on annual changes

**Model form.** We fit AR(1) on `diff(TFR_train)`. In formula form: $x_t = c + \phi_1 x_{t-1} + \varepsilon_t$, where $x_t$ is the annual change in TFR, $c$ is a constant, $\phi_1$ is the lag-1 effect, and $\varepsilon_t$ is random shock (white noise).

**Why this is reasonable.** In the differenced TFR PACF there is a clear spike at lag 1, while the ACF drops quickly. This is a standard visual pattern that supports an AR(1) structure.

- **AIC / BIC (training):** AIC = **−45.86**, BIC = **−40.01**

![Residual ACF/PACF: TFR AR(1)](plots/14_tfr_ar1_residuals_acf_pacf.png)

- **Box–Ljung (lag 10):** p-value = **0.439** → do not reject white-noise residuals at 5%.

**Conclusion.** AR(1) on annual changes is a viable preliminary candidate for TFR. In the Final Report we will still compare it with at least one alternative ARMA model because fertility has structural breaks and the ADF result is borderline after differencing.

---

## 8. Model Assessment Strategy

For the Final Report, where we will have at least two models per series and forecasts for 2013–2024 are needed, the model comparison will use both in-sample and out-of-sample criteria.

**In-sample (training fit, 1960–2012):**
- AIC and BIC — penalise model complexity; lower is better.
- Residual diagnostics — ACF/PACF of residuals should resemble white noise; Box-Ljung test p-value should be > 0.05.

**Out-of-sample (forecast accuracy, 2013–2024):**
- Root Mean Squared Error (RMSE) — penalises large errors.
- Mean Absolute Error (MAE) — robust to outliers.
- Mean Absolute Percentage Error (MAPE) — allows comparison across TLB and TFR scales.
- Visual inspection of forecast vs actual plot — important for assessing direction and structural plausibility.

**Trade-offs.** AIC can prefer more complex models, while BIC penalises complexity more strongly and often prefers simpler models in moderate samples like 53 years. A good in-sample fit may still overfit the historical period (especially with structural breaks). Because of this, the Final Report will prioritise **out-of-sample RMSE** on 2013–2024, supported by MAE/MAPE and residual checks.

---


## 9. Summary of EDA Findings and Research Questions Revisited

**Research question 1 — Key temporal trends and structural changes:**  
Both TLB and TFR show a strong and consistent downward trend from 1960 to 2024. The decline is not smooth — there are some small shifts linked to policy events in 1966 and 1987, and an external shock from COVID-19 in 2020. ADF tests confirm that both level series are non-stationary, and first differencing achieves stationarity for TLB (p = 0.039) and near-stationarity for TFR (p = 0.083, borderline).

**Research question 2 — Appropriate time series models:**  
Based on the ACF/PACF structure of the differenced series, ARMA(0,0) is the potential candidate for TLB annual changes and AR(1) is the potential candidate for TFR annual changes. Both pass residual diagnostics at this stage. At least one additional candidate model per series will be fitted and compared in the Final Report.

**Research question 3 — Role of social and policy events:**  
Policy events are clearly visible in the data. The 1966 family planning campaign coincides with the sharpest period of decline in both series. The 1987 pro-natalist policy produced a small and temporary uptick. COVID-19 produced a dip in TLB around 2020–2021. These features are a practical limitation for any purely statistical model, and the Final Report will discuss whether a model that accounts for known break points performs better than one that does not.

**Limitations going forward:**  
The short training sample (n = 53) limits the reliability of higher-order models and makes it difficult to formally detect structural breaks. The borderline ADF result for differenced TFR adds uncertainty to the modelling choice. The test period (2013–2024) includes COVID-19, which is arguably out-of-sample in a distributional sense and not just a temporal one.

---

## 10. References

- OBGyn Key n.d., *Singapore's pro-natalist policies: to what extent have they worked?*, OBGyn Key, viewed 29 March 2026, <https://obgynkey.com/singapores-pro-natalist-policies-to-what-extent-have-they-worked/>.
- National Library Board Singapore 2000, *“Have three, or more if you can afford it” is announced*, NLB Singapore, viewed 29 March 2026, <https://www.nlb.gov.sg/main/article-detail?cmsuuid=1d106f7e-aca1-4c0e-ac7a-d35d0772707d>.
- United Nations Statistics Division n.d., *Total Fertility Rate: Demographics — Population Change*, UN Statistics Division, viewed 29 March 2026, <https://www.un.org/esa/sustdev/natlinfo/indicators/methodology_sheets/demographics/total_fertility_rate.pdf>.
- Hyndman, R.J. & Athanasopoulos, G. 2021, *Forecasting: Principles and Practice*, 3rd edn, OTexts, viewed 29 March 2026, <https://otexts.com/fpp3/moving-averages.html>.
- Singapore Department of Statistics n.d., *Live Births and Fertility Rates*, SingStat, viewed 29 March 2026, <https://www.singstat.gov.sg/>.
- Urban Redevelopment Authority 2023, *Master Plan*, URA Singapore, viewed 29 March 2026, <https://www.ura.gov.sg/Corporate/Planning/Master-Plan>.

---

## 11. Statistical Appendix

### A. Augmented Dickey–Fuller (ADF) Test

The ADF test assesses whether a time series has a unit root (i.e. is non-stationary). The test estimates the regression:

$$
\Delta y_t = \alpha + \beta t + \gamma y_{t-1} + \sum_{j} \delta_j \Delta y_{t-j} + \varepsilon_t
$$

where $\alpha$ is a constant, $\beta t$ is an optional linear trend, $\gamma$ is the coefficient of interest, and the lagged difference terms $\sum_j \delta_j \Delta y_{t-j}$ are included to absorb any remaining serial correlation in the residuals (this is the "augmented" part that distinguishes ADF from the simpler Dickey–Fuller test).

- **$H_0$:** $\gamma = 0$ — a unit root is present (series is non-stationary)  
- **$H_1$:** $\gamma < 0$ — no unit root (series is stationary)

Rejection of $H_0$ at $\alpha = 0.05$ (p-value < 0.05) provides evidence of stationarity. A failure to reject $H_0$ suggests the series has a unit root and may need differencing before modelling.

### B. First Differencing

If a level series $y_t$ is non-stationary, the first difference is defined as:

$$
\Delta y_t = y_t - y_{t-1}
$$

This transformation removes a linear stochastic trend. If one difference is sufficient to achieve stationarity, the series is said to be integrated of order one, written **I(1)**. For TLB and TFR, ADF evidence supports using one difference.

### C. Autoregressive Model — AR(p)

An AR(p) model on a stationary series $x_t$ (here: the first-differenced series) is:

$$
x_t = c + \phi_1 x_{t-1} + \phi_2 x_{t-2} + \cdots + \phi_p x_{t-p} + \varepsilon_t
$$

where $c$ is a constant, $\phi_1, \ldots, \phi_p$ are autoregressive coefficients, and $\varepsilon_t \sim WN(0, \sigma^2)$ is white noise. The model says the current value depends on its own past $p$ values. The order $p$ is identified from the PACF of the stationary series: the PACF cuts off sharply after lag $p$ for a pure AR(p) process.

### D. Moving Average Model — MA(q)

An MA(q) model on a stationary series $x_t$ is:

$$
x_t = c + \varepsilon_t + \theta_1 \varepsilon_{t-1} + \theta_2 \varepsilon_{t-2} + \cdots + \theta_q \varepsilon_{t-q}
$$

where $\theta_1, \ldots, \theta_q$ are moving average coefficients and $\varepsilon_t \sim WN(0, \sigma^2)$ is white noise. The model says the current value depends on current and past $q$ shocks. The order $q$ is identified from the ACF of the stationary series: the ACF cuts off sharply after lag $q$ for a pure MA(q) process.

### E. Mixed Model — ARMA(p, q)

An ARMA(p, q) model combines both AR and MA components:

$$
x_t = c + \phi_1 x_{t-1} + \cdots + \phi_p x_{t-p} + \varepsilon_t + \theta_1 \varepsilon_{t-1} + \cdots + \theta_q \varepsilon_{t-q}
$$

where all notation is as above. When both ACF and PACF tail off gradually rather than cutting off sharply, a mixed ARMA model is suggested. The special case **ARMA(0,0)** reduces to $x_t = c + \varepsilon_t$, meaning the series is pure white noise around a constant mean — used here as a baseline model for the differenced TLB series.

### F. Box–Ljung Portmanteau Test

After fitting a model, the Box–Ljung test checks whether the residual autocorrelations are jointly zero up to lag **m**:

$$
Q = n(n+2)\sum_{k=1}^{m} \frac{\hat{r}_k^2}{n-k}
$$

where $n$ is the number of observations, $\hat{r}_k$ is the sample autocorrelation of residuals at lag $k$, and $m$ is the chosen maximum lag (here $m = 10$).

- **$H_0$:** no autocorrelation in residuals up to lag $m$ (residuals are white noise)  
- **$H_1$:** at least one autocorrelation is non-zero

A large p-value (> 0.05) means the residuals are consistent with white noise, indicating the model has adequately captured the autocorrelation structure. A small p-value suggests remaining structure that the model has not captured.

### G. Information Criteria — AIC and BIC

Both criteria balance goodness of fit against model complexity:

$$
\mathrm{AIC} = -2\log(L) + 2k
$$

$$
\mathrm{BIC} = -2\log(L) + k\log(n)
$$

where **L** is the maximised likelihood of the fitted model, **k** is the number of estimated parameters, and **n** is the number of observations. Lower values of AIC or BIC indicate a better model. BIC applies a stronger penalty for additional parameters than AIC, so it tends to favour more parsimonious models, which is important in small samples like the 53-year training period used here.

### H. Forecast Accuracy Metrics (for Final Report)

When forecasts for 2013–2024 are produced in the Final Report, model performance will be evaluated using:

$$
\mathrm{RMSE} = \sqrt{\frac{1}{h}\sum_t (y_t - \hat{y}_t)^2}
$$

$$
\mathrm{MAE} = \frac{1}{h}\sum_t \lvert y_t - \hat{y}_t \rvert
$$

$$
\mathrm{MAPE} = \frac{1}{h}\sum_t \frac{\lvert y_t - \hat{y}_t \rvert}{\lvert y_t \rvert}\times 100
$$

where $h = 12$ is the forecast horizon (2013–2024), $y_t$ is the actual value, and $\hat{y}_t$ is the forecast. RMSE is the primary criterion as it penalises large errors more heavily, which matters when forecasting a declining series where large deviations are most costly for policy use.

