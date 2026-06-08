# Modelling and Forecasting Singapore's Fertility Decline: A Time Series Analysis of the Total Fertility Rate and Total Live Births, 1960–2024

Minh Chien Nguyen | a1895269
Time Series Analysis — Final Report

**GitHub repository:** https://github.com/perryx05/Time-Series-Analysis

---

## Abstract

Singapore has one of the lowest birth rates in the world, and the average number of children born to each woman has fallen almost continuously since 1960. This report asks a simple question: can a statistical time series model describe how Singapore's fertility has changed over the past six decades, and can it predict what came next? Two yearly series were studied — the total fertility rate, which is the average number of children per woman, and the total number of live births. Sixty-five years of official data (1960–2024) were used. The model was built using only the first part of the data (up to 2012) and then tested by comparing its predictions against the most recent twelve years, which were held back.

The analysis showed that two features are needed to describe the data well: a steady long-run downward trend, and a repeating twelve-year cycle. The twelve-year cycle reflects a cultural pattern in which families of Chinese heritage tend to have more children in the auspicious Dragon year, which returns once every twelve years. A seasonal ARIMA model that combines the long-run trend with this twelve-year cycle fitted both series well and left no obvious pattern in its errors. When tested on the held-back years, the model tracked the continuing decline reasonably closely, with an average error of 8.9% for the fertility rate and 12.1% for births across the twelve held-back years. The clearest shortcoming was the most recent Dragon year, 2024, which the model expected to bring a small rise in births but which instead recorded a new low. This suggests that the cultural cycle, while real in the past, has weakened in recent years, and that future projections of Singapore's fertility should rely less on this cycle and more on social and economic factors.

## 1. Introduction

### 1.1 Background and motivation

Singapore's demographic history is a striking example of rapid fertility decline. After independence in 1965, the government adopted family-planning programmes to slow population growth, and from 1965 to 1986 the total fertility rate (TFR) fell steadily, reaching the replacement level of about 2.1 children per woman in 1975 (Chen, Yip and Yap, 2018). Policy was then reversed: in 1987, when the TFR was about 1.6, the government introduced a selectively pro-natalist policy under the slogan "Three or more, if you can afford it", later consolidated into the Marriage and Parenthood Package and a Baby Bonus scheme of cash gifts and matched savings (Chen, Yip and Yap, 2018). Despite these measures, fertility has continued to fall, and by the mid-2010s Singapore's TFR was among the lowest in East and South-East Asia (Chen, Yip and Yap, 2018). The most recent figures place the TFR below 1.0: the Singstat series used here records a fall from 5.76 children per woman in 1960 to 0.97 in 2024, less than half the replacement level of about 2.1.

This decline matters for policy. A sustained TFR far below replacement, combined with rising life expectancy, accelerates population ageing and shrinks the future labour force (Chen, Yip and Yap, 2018). Reliable forecasts of fertility are therefore an important input into long-term planning for the economy, healthcare and immigration.

A feature that makes Singapore's fertility unusual is a recurring fluctuation tied to the Chinese zodiac. About three-quarters of Singapore's resident population is of Chinese heritage (Singapore Department of Statistics, 2025), and families have historically timed births to fall in auspicious years, especially the Dragon year, which recurs once every twelve years. Agarwal et al. (2021) document this Dragon-year effect on births in Singapore using administrative records: between 1960 and 2007, births among the Chinese majority rose by about 9.7% in Dragon years, with no comparable pattern among non-Chinese groups. This recurring uplift produces a repeating twelve-year cycle, which any adequate time series model must capture.

### 1.2 Research question

This report addresses a single research question:

> _To what extent can a time series model represent both the long-run trend and the twelve-year cyclical structure in Singapore's TFR and total live births (TLB), and how accurately can such a model forecast fertility outcomes over the period 2013–2024?_

The question has two parts. The first is whether a model can be specified whose errors are statistically indistinguishable from random noise, which is the standard criterion for an adequate fit. The second is how accurately that model forecasts data it has not seen. The test period of twelve years was chosen deliberately so that it spans exactly one zodiac cycle, which lets the model's treatment of the 2024 Dragon year be examined directly.

### 1.3 Related literature

Time series methods have been applied widely to fertility forecasting, most often by first reducing the data to a small number of components and then modelling those components. Vanella (2016) projected Germany's TFR with a stochastic principal-components method, applying principal component analysis to the age-specific fertility rates and modelling the leading components as stochastic time series. Shair, Shaadan and Meor Amirudin (2024) modelled Malaysian age-specific fertility rates from 1958 to 2020 by ethnic group, comparing the Lee–Carter model with a functional data model and using the automatic order-selection procedure `auto.arima` to forecast the component series. They deliberately avoided higher-order specifications because the extra parameters risked overfitting a short series — a concern that applies equally to the present analysis. Both studies use a logarithmic scale for fertility, consistent with the long-standing argument that fertility rates are strictly positive and are better modelled multiplicatively (Lee, 1993; Shair, Shaadan and Meor Amirudin, 2024). These precedents bear directly on the choices made here (Section 2): we model the fertility rate on the same log scale, and we follow the same caution against over-parameterisation, preferring the most parsimonious specification whenever several remain statistically adequate.

Neither of these studies addresses a cultural cycle of fixed, non-annual length. For Singapore, Agarwal et al. (2021) provide direct evidence of such a cycle in the form of the Dragon-year effect, which gives a data-grounded reason to set the seasonal period of the model to twelve years even though the data are annual. Without this evidence, a seasonal period of twelve would appear arbitrary.

The present study contributes a formal Box–Jenkins forecasting exercise for Singapore in which the seasonal component represents a documented cultural cycle, and in which the forecast horizon is set to one full cycle so that the model's treatment of the zodiac effect can be tested out of sample.

---

## 2. Methods

### 2.1 Data

Annual data on the TFR and the TLB for 1960 to 2024 were obtained from the Singapore Department of Statistics (Singstat). The TFR is the average number of children per resident woman, and the TLB is the total number of resident live births in a calendar year. Both series were checked for missing values and obvious recording errors; none were found.

The 65 observations were divided into a training set of 53 observations (1960–2012) and a test set of 12 observations (2013–2024). The twelve-year test horizon coincides with one complete zodiac cycle.

### 2.2 The Box–Jenkins methodology

The Box–Jenkins approach to ARIMA modelling proceeds through three iterative stages: identification, estimation and diagnostic checking (Box, Jenkins and Reinsel, 2008; Shumway and Stoffer, 2011). At the identification stage, transformation and differencing are used to make the series stationary, and the sample autocorrelation function (ACF) and partial autocorrelation function (PACF) are inspected to suggest candidate orders. At the estimation stage, the candidate models are fitted by maximum likelihood. At the diagnostic stage, the residuals are tested for departures from white noise; if any are found, the specification is revised and the cycle repeats.

### 2.3 Stationarity testing

The stationarity of each series was assessed using two tests with opposing null hypotheses. The Augmented Dickey–Fuller (ADF) test takes a unit root (non-stationarity) as its null, while the Kwiatkowski–Phillips–Schmidt–Shin (KPSS) test takes stationarity as its null. Decisions were made at the 5% level using each test's reported p-value, not the sample size. Where the two tests agreed, the evidence was treated as conclusive; where they disagreed, the disagreement was reported and resolved by visual inspection and by appeal to parsimony.

### 2.4 Transformations

For the TFR, the natural logarithm was applied before differencing, for two reasons. First, the TFR is a strictly positive ratio whose variability tends to scale with its level, so the log transformation stabilises the variance and guarantees positive back-transformed forecasts (Lee, 1993; Vanella, 2016). Second, a fall from above 5 to below 1 over six decades is closer to a multiplicative than an additive process, which the log scale represents more naturally. The first difference of the log series, $\nabla \log(\text{TFR}_t) = \log(\text{TFR}_t) - \log(\text{TFR}_{t-1})$, is the proportional year-on-year change in fertility.

For the TLB, the first difference $\nabla \text{TLB}_t = \text{TLB}_t - \text{TLB}_{t-1}$ was applied directly, without a prior log transformation, because the differenced series on the original scale was stationary under both tests (Section 3.1).

### 2.5 The seasonal model

The model used in this report is the seasonal autoregressive integrated moving average model, SARIMA(p, d, q)(P, D, Q)[s], defined by

$$
\phi(B)\,\Phi(B^s)\,(1-B)^d (1-B^s)^D X_t = \theta(B)\,\Theta(B^s)\,\varepsilon_t,
$$

where $\phi(B) = 1 - \phi_1 B - \cdots - \phi_p B^p$ and $\theta(B) = 1 + \theta_1 B + \cdots + \theta_q B^q$ are the non-seasonal autoregressive (AR) and moving-average (MA) polynomials, $\Phi(B^s)$ and $\Theta(B^s)$ are the corresponding seasonal polynomials at period $s$, $B$ is the backshift operator, and $\varepsilon_t$ is white noise with variance $\sigma^2$. The ordinary, non-seasonal ARIMA(p, d, q) model is the special case in which all seasonal orders are zero. The seasonal period was set to $s = 12$ to represent the twelve-year Chinese zodiac cycle: families of Chinese heritage have historically timed births to fall in the auspicious Dragon year, which recurs every twelve years, and Agarwal et al. (2021) document this Dragon-year effect directly in Singapore birth records. The choice of $s = 12$ therefore rests on documented behaviour rather than on a purely statistical periodicity; the same twelve-year recurrence is visible in the present data (Sections 1.1 and 3.2).

It is worth being precise about two points that are easily confused. The order $d$ is a differencing order, not a lag: it counts how many times the series is differenced, whereas $p$ and $q$ count AR and MA terms at successive lags. Likewise, a high MA order $q$ is justified only when the ACF is significant at every lag from 1 up to $q$; an isolated spike at a single high lag does not, on its own, call for a large $q$.

### 2.6 Why a seasonal specification

The dependence to be reproduced sits at lag 12 and its neighbours (Section 3.2). A non-seasonal autoregression could reach lag 12 only by carrying its order out to at least 12 — twelve or more coefficients on 53 observations, at the limit of reliable estimation and prone to over-fitting (Shair, Shaadan and Meor Amirudin, 2024). A seasonal term is far more economical: the operator $\Phi_1 B^{12}$ reaches lag 12 with one parameter, and its product with a non-seasonal AR term also generates the dependence near lag 13. We therefore use a seasonal ARIMA from the outset. The seasonal structure could enter through a seasonal AR term or a seasonal difference ($D = 1$); but a seasonal difference alone leaves the downward trend (ADF on the seasonally-differenced series: $\log$ TFR $p = 0.59$, TLB $p = 0.34$ — not shown in Table 1, which tests the non-seasonally-differenced forms), so the regular difference $d = 1$ is required regardless. The adopted models therefore combine $d = 1$ with a seasonal AR term and a seasonal difference, the non-seasonal order being fixed empirically (Section 3.3).

### 2.7 Model identification and selection

The analysis follows the iterative Box–Jenkins loop. An **initial model** is read conservatively from the correlograms — the non-seasonal autoregressive order taken out to the last lag the PACF flags (the zodiac cluster near lags 11–13) — and its residuals are judged against a two-part white-noise requirement:

1. _Portmanteau test._ The Ljung–Box test, as reported by the `checkresiduals` routine (the lag chosen by its standard rule and the degrees of freedom reduced by the number of estimated AR and MA parameters), should not reject the null of no residual autocorrelation at the 5% level.
2. _No residual spike._ The residual ACF and PACF, inspected to at least lag 24 (two full seasonal cycles), should show **no individual autocorrelation outside the $\pm 1.96/\sqrt{n}$ band**.

Where the intermediate coefficients prove redundant, the order is reduced and the smaller model re-checked, yielding the **final** model; both must satisfy the two-part bar. Selection between the fuller and reduced specifications then turns on parsimony and information criteria — a model whose extra parameters lower the training-period fit but _not_ the Akaike Information Criterion (AIC) is over-fitted and rejected in favour of the smaller one, a real risk with ten or more parameters on a sixty-year record (Shair, Shaadan and Meor Amirudin, 2024). The test-set errors (MSE, MAE and MAPE; Hyndman and Athanasopoulos, 2021) are reported alongside the AIC, which is directly comparable across the candidates here because all carry the same differencing.

### 2.8 Software

All analyses were carried out in R version 4.4.3 (R Core Team, 2025), run within the Visual Studio Code editor using its R extension, with the `forecast` package (Hyndman and Khandakar, 2008) for model fitting and forecasting and the `tseries` package for the ADF and KPSS tests.

---

## 3. Results

### 3.1 Stationarity testing

Figure 1 plots the two raw series. Both decline almost monotonically over six decades, with the fertility rate crossing the replacement level around 1975 and the Dragon-year peaks (marked) clearly visible as local upturns in births. This sustained, level-dependent decline, with no tendency to revert to a fixed mean, is a characteristic feature of a non-stationary process, which the formal tests in Table 1 confirm.

![**Figure 1.** Singapore's total fertility rate (left) and total live births (right), 1960–2024. The dashed vertical line marks the train/test split at 2012; green points mark the Dragon years (1964, 1976, 1988, 2000, 2012, 2024).](figures/fr_fig0_raw_series.png)

**Table 1.** Stationarity tests on the training period (1960–2012). ADF null: a unit root (non-stationary); KPSS null: stationarity. The ADF decision uses the reported _p_-value at the 5% level; the KPSS decision compares the test statistic with its 5% critical value of 0.463.

| Series                  |  ADF*p*   | ADF decision   | KPSS stat | KPSS decision  |     |
| :---------------------- | :-------: | :------------- | :-------: | :------------- | :-: |
| TFR (raw)               |   0.120   | Non-stationary |   1.071   | Non-stationary |     |
| ∇TFR (_d_ = 1)          |   0.083   | Non-stationary |   0.841   | Non-stationary |     |
| log(TFR)                |   0.603   | Non-stationary |   1.201   | Non-stationary |     |
| **∇log(TFR) (_d_ = 1)** | **0.031** | **Stationary** | **0.505** | **Borderline** |     |
| TLB (raw)               |   0.356   | Non-stationary |   0.624   | Non-stationary |     |
| **∇TLB (_d_ = 1)**      | **0.039** | **Stationary** | **0.213** | **Stationary** |     |

The raw TFR series failed both tests (ADF _p_ = 0.120; KPSS = 1.071), confirming non-stationarity. Its first difference also remained non-stationary (ADF _p_ = 0.083; KPSS = 0.841), which prompted the log transformation: the first difference of the log TFR was stationary under the ADF test (_p_ = 0.031), although its KPSS statistic (0.505) sat just above the 0.463 threshold. This marginal result is attributable to the residual twelve-year cycle, which the seasonal component later absorbs. The first difference of the TLB was stationary under both tests without any transformation (ADF _p_ = 0.039; KPSS = 0.213). The working series were therefore $\nabla \log(\text{TFR}_t)$ and $\nabla \text{TLB}_t$, both with $d = 1$.

### 3.2 Identification: autocorrelation patterns

![**Figure 2.** Sample ACF and PACF after differencing, with 95% bands dashed. Top two rows: the first-differenced log-TFR and first-differenced TLB (to lag 45), whose PACFs show the zodiac cluster at lag 12 with a recurrence near lag 24. Bottom two rows: the same two series after an additional seasonal difference (the doubly-differenced series, to lag 24), whose PACFs show a single significant spike at lag 4 (about −0.42) and little beyond — the basis for the non-seasonal order p = 4 (Section 3.3).](figures/fr_fig1_acf_pacf.png)

Figure 2 (top two rows) shows the sample ACF and PACF of the two first-differenced series. For $\nabla \log(\text{TFR}_t)$, the partial autocorrelations are small at most short lags but form a distinct cluster around the boundary of one decade, with significant spikes near lags 12 and 13 and the largest at lag 12; the ACF shows the same spike at lag 12 and a further recurrence near lag 24, the second seasonal harmonic. As explained in Section 2.6, reaching this cluster with a non-seasonal model would require an autoregressive order of at least 12, so a seasonal specification at period 12 — the twelve-year Dragon-year cycle documented by Agarwal et al. (2021) — is the economical reading, and is the form fitted in Section 3.3. The PACF of $\nabla \text{TLB}_t$ shows the same cluster, with significant spikes around lags 11 to 13, which indicates that the births series carries the zodiac structure as well and calls for an equivalent treatment.

### 3.3 Model fitting and selection

We fit each series through the iterative Box–Jenkins loop of Section 2.7: a conservative high-order initial model read from the correlograms, a residual and information-criterion check, and a pared-back final model. Both series follow the same path and end at the same compact form.

**The initial models.** Read conservatively, the PACF (Figure 2) calls for a non-seasonal autoregression reaching the whole zodiac cluster: the births PACF is significant out to lag 13, and the rate's peaks at lag 12. Taking each at face value, together with the seasonal AR(1) and the seasonal difference, gives the initial models **SARIMA(13,1,0)(1,1,0)[12]** for the TLB and **SARIMA(12,1,0)(1,1,0)[12]** for the TFR. Both are viable: every residual autocorrelation lies within the band (Figure 3), and the Ljung–Box test does not reject — TLB $Q^* = 5.43$ ($p = 0.14$), comfortably non-significant; TFR $Q^* = 7.81$ ($p = 0.050$), only marginally so. But each spends a long autoregressive polynomial in which only a few coefficients carry signal — two of fourteen are individually significant for the TLB, four of thirteen for the TFR — which on 53 observations is the warning sign of over-parameterisation.

![**Figure 3.** Residual ACF of the two initial models, log-SARIMA(12,1,0)(1,1,0)[12] for the TFR (left) and SARIMA(13,1,0)(1,1,0)[12] for the TLB (right). Both lie entirely within the 95% significance bands, so both are viable.](figures/fr2_fig3_initial_resid_acf.png)

**The final models.** Inspecting the intermediate coefficients shows that those at lags 5 and above are near zero and insignificant, so the non-seasonal order is reduced to **4**. The PACF of the _doubly_-differenced series $(1-B)(1-B^{12})X_t$ (the lower two rows of Figure 2) confirms this: it shows a clearly significant spike at lag 4 (partial autocorrelation −0.42 for both series) and no significant structure beyond. The pared-back **SARIMA(4,1,0)(1,1,0)[12]** keeps the residuals equally clean — fully white, with no autocorrelation outside the band and a comfortably non-significant Ljung–Box test (TFR $Q^* = 7.66$, $p = 0.26$; TLB $Q^* = 6.48$, $p = 0.37$; Figures 4–5) — while cutting the model to five parameters. It is adopted for both series. All coefficients are interior and the models are pure autoregressions, so no invertibility question arises, and the fourth-order term is individually significant in both ($t = -2.56$ for the TFR, $t = -2.92$ for the TLB).

Tables 2 and 3 record the initial and final model for each series. Because both carry the same differencing ($d = 1$, $D = 1$) and seasonal structure, their AIC is directly comparable.

**Table 2.** TFR models (log scale), fitted on 1960–2012 and evaluated on 2013–2024; test errors are on the back-transformed (original) scale. Both models are white — each passes the Ljung–Box test and leaves no residual-ACF spike (text and Figures 3–4). AIC is directly comparable (both carry $d = 1$, $D = 1$). The final (adopted) model is in bold.

| Model                                | npar  |         AIC |   Test MSE |  Test MAE | Test MAPE (%) |
| :----------------------------------- | :---: | ----------: | ---------: | --------: | ------------: |
| SARIMA(12,1,0)(1,1,0)[12] (initial)  |  13   |      −95.19 |     0.0066 |     0.068 |           6.0 |
| **SARIMA(4,1,0)(1,1,0)[12] (final)** | **5** | **−100.98** | **0.0132** | **0.102** |       **8.9** |

**Table 3.** TLB models (original scale); conventions as in Table 2.

| Model                                | npar  |        AIC |       Test MSE |  Test MAE | Test MAPE (%) |
| :----------------------------------- | :---: | ---------: | -------------: | --------: | ------------: |
| SARIMA(13,1,0)(1,1,0)[12] (initial)  |  14   |     762.52 |     1.13 × 10⁷ |     2,593 |           6.7 |
| **SARIMA(4,1,0)(1,1,0)[12] (final)** | **5** | **751.55** | **3.03 × 10⁷** | **4,822** |      **12.1** |

**The improvement is parsimony.** Reducing the order leaves the diagnostic quality unchanged — both models are white, and each keeps the same significant coefficients (two for the TLB, four for the TFR) — but removes nine redundant parameters and _lowers_ the AIC: by 11 points for the TLB (762.5 → 751.5) and by 6 for the TFR (−95.2 → −101.0). A lower AIC at far fewer parameters is exactly what an information criterion rewards, and it is the quantitative case for the simpler model. The one cost is in test-set accuracy: the MAPE rises (TLB 6.7% → 12.1%; TFR 6.0% → 8.9%). This is expected and is _not_ evidence for the fuller model — its lower error reflects its larger parameter set fitting the specific training pattern more closely, whereas the parsimonious model generalises more conservatively. Over a twelve-year test horizon the over-fitting risk is real, so we prefer the model the AIC prefers; the trade-off is revisited in Section 4.3.

The fitted equations for the two adopted (final) models are

$$
\Big(1 - \textstyle\sum_{j=1}^{4}\hat{\phi}_j B^{j}\Big)(1 - \hat{\Phi}_1 B^{12})(1-B)(1-B^{12})\,\log(\text{TFR}_t) = \varepsilon_t, \tag{1}
$$

with $\hat{\phi} = (0.450,\,-0.059,\,0.333,\,-0.405)$, $\hat{\Phi}_1 = -0.334$ and $\varepsilon_t \sim N(0,\,0.00376)$; and

$$
\Big(1 - \textstyle\sum_{j=1}^{4}\hat{\phi}_j B^{j}\Big)(1 - \hat{\Phi}_1 B^{12})(1-B)(1-B^{12})\,\text{TLB}_t = \varepsilon_t, \tag{2}
$$

with $\hat{\phi} = (0.292,\,0.081,\,0.231,\,-0.441)$, $\hat{\Phi}_1 = -0.252$ and $\varepsilon_t \sim N(0,\,6.85 \times 10^{6})$. Full coefficient estimates with standard errors are given in Appendix A.1.

### 3.4 Residual diagnostics for the adopted models

Figures 4 and 5 present the full residual diagnostics for the two adopted models: the residuals over time, the residual ACF, a histogram with a fitted normal curve, and a normal quantile–quantile (Q–Q) plot.

![**Figure 4.** Residual diagnostics for the adopted TFR model, log-SARIMA(4,1,0)(1,1,0)[12]: residuals over time, residual ACF (to two seasonal cycles), a histogram with a fitted normal curve, and a normal Q–Q plot. The Shapiro–Wilk p-value shown is computed on the post-initialisation residuals.](figures/enh_resid_tfr.png)

![**Figure 5.** Residual diagnostics for the adopted TLB model, SARIMA(4,1,0)(1,1,0)[12], with the same panels as Figure 4. The single point above the upper tail of the Q–Q plot is the 1988 Dragon-year residual.](figures/enh_resid_tlb.png)

For both adopted models the residuals fluctuate around zero with no visible trend or periodicity, and the histograms are approximately symmetric and bell-shaped. **Every residual autocorrelation lies within the 95% bands**, including at the seasonal lags 12 and 24. The Ljung–Box tests confirm whiteness: $Q^* = 7.66$ on 6 degrees of freedom ($p = 0.264$) for the TFR model and $Q^* = 6.48$ on 6 degrees of freedom ($p = 0.372$) for the TLB model. The larger initial models were already white (Figure 3); reducing the order preserves that whiteness, so the gain from the refinement is in parsimony and AIC, not in the residuals.

A normal Q–Q plot and a Shapiro–Wilk test then check the Gaussian assumption that underlies the prediction intervals. The first thirteen residuals are differencing-initialisation artefacts (near zero by construction — the flat 1960–1971 segment in Figures 4 and 5) and are excluded from the test. On the remaining forty residuals, normality is **not rejected for the rate** (Shapiro–Wilk $p = 0.20$), so the fertility-rate prediction intervals rest on a sound assumption; for **births it is only marginally rejected** ($p = 0.03$), driven by the single large positive residual of the 1988 Dragon year, so the births intervals are best read as approximate. This asymmetry is taken up in Section 4.3.

### 3.5 Forecast evaluation

![**Figure 6.** TFR forecast for 2013–2024 from log-SARIMA(4,1,0)(1,1,0)[12]. Black: training data; blue: actual; dashed red: point forecast; shaded: 80% and 95% prediction intervals; the forecast is back-transformed with exp(). The 2020 (COVID-19) and 2024 (Dragon-year) points are marked.](figures/fr2_fig6_forecast_tfr.png)

![**Figure 7.** TLB forecast for 2013–2024 from SARIMA(4,1,0)(1,1,0)[12], with the same conventions.](figures/fr2_fig7_forecast_tlb.png)

**Table 4.** Forecast accuracy of the adopted (improved) models on the test set (2013–2024).

| Series | Model                        |        MSE |   MAE | MAPE (%) |
| :----: | :--------------------------- | ---------: | ----: | -------: |
|  TFR   | log-SARIMA(4,1,0)(1,1,0)[12] |     0.0132 | 0.102 |     8.89 |
|  TLB   | SARIMA(4,1,0)(1,1,0)[12]     | 3.03 × 10⁷ | 4,822 |    12.14 |

Figure 6 shows that the TFR forecast follows the continuing decline, with every observed value inside the prediction intervals throughout. The seasonal difference projects the fall slightly too fast, so the model _under_-predicts through most of the horizon; its single largest miss is in **2015** (actual 1.24 against a forecast of 1.03, error +0.21), early in the test window where fertility briefly plateaued. The 2020 COVID-19 year was forecast almost exactly (error +0.06), so the pandemic was not a notable source of error in this annual series. The substantively telling miss is at the end: for **2024**, the most recent Dragon year, the model builds in a small uplift to a TFR of 1.03, whereas the realised value held at the record low of 0.97 — a modest over-forecast (error −0.06), but one that points upward exactly when the data turned down.

Figure 7 shows the same pattern for births, more pronounced. The TLB forecast tracks the broad decline but sits below the actual series for most of the horizon: the seasonal difference makes each forecast depend on the value twelve years earlier and so projects too steep a fall, leaving the model to _under_-predict births through 2013–2022 (the largest error is 2015, about 10,000 births below the actual) for an average error of 12.14%. Here too the model builds a Dragon-year uplift into 2024 — projecting about 36,700 births against the realised 33,700 — so its 2024 forecast again points upward as the data fell. In both series, then, the forecasts embed a 2024 Dragon-year rise that did not occur; this shared failure, rather than the COVID-19 year, is the substantively important one, and it is examined next.

---

## 4. Discussion

### 4.1 What the model captures

Each adopted model represents its series as a long-run downward trend (captured by first differencing) plus a twelve-year cultural cycle (captured by a seasonal autoregressive term and a seasonal difference at period 12), in which fertility tends to rise in Dragon years. Both components are necessary: a seasonal difference applied on its own leaves the downward trend intact (Section 2.6), and without the seasonal term the twelve-year dependence is left in the residuals. A notable result is that the _same_ compact specification, SARIMA(4,1,0)(1,1,0)[12] (on the log scale for the rate), serves both the period rate and the raw count: the zodiac cycle is a common structure that a single seasonal model captures in each. Reaching that cycle economically — with five parameters rather than the twelve-or-more-term autoregression a non-seasonal model would demand — is what keeps the model estimable, and its inference trustworthy, on a sixty-year record.

### 4.2 The 2024 Dragon-year anomaly

The most striking result is that the 2024 Dragon year produced no rise in fertility. In the Dragon years from 1976 onwards — 1976, 1988, 2000 and 2012 — the TFR rose relative to the year before (the one exception, 1964, fell only because it coincided with the era of steepest secular decline). A model fitted to these observations therefore built a small uplift into both 2024 forecasts: a TFR of 1.03 against the realised 0.97, and about 36,700 births against the realised 33,700. In each case the forecast pointed upward exactly when the data turned down. This unrealised rise was not the single largest error for either series — the steep mid-horizon under-prediction (largest in 2015) dominated both — but it is the substantively important one, because the treatment of the cultural cycle is precisely what future projections most depend on. Several explanations for the missing rise are plausible: a post-pandemic delay in family formation, persistent housing-affordability constraints, which earlier research identifies as a major barrier to marriage and childbearing in Singapore (Chen, Yip and Yap, 2018), and a generational shift in attitudes toward zodiac symbolism. In modelling terms, this points to a structural change in the seasonal component that an ARIMA-class model, which assumes a stable correlation structure, cannot represent.

### 4.3 Limitations

Several limitations should be acknowledged. First, the training sample of 53 observations is short for time series modelling, and the precision of the estimated coefficients is correspondingly limited — a general constraint when modelling demographic series, and one that the related literature also confronts (Shair, Shaadan and Meor Amirudin, 2024). The seasonal model mitigates this by reaching lag 12 with very few parameters, but it cannot remove the underlying limitation.

Second, the ARIMA framework assumes a stable stochastic process and is ill-suited to structural breaks. The 1987 policy reversal and the 2020 COVID-19 shock are both visible in the data and are likely to affect the estimates. Intervention analysis or regime-switching models would treat these events more appropriately but were beyond the scope of this report.

Third, the adopted models trade some test-set accuracy for parsimony, most visibly for births. The fuller initial models forecast the held-out decade more closely (MAPE 6.7% for births, 6.0% for the rate) than the adopted models (12.1% and 8.9%), but this lower error reflects their larger parameter set fitting the specific 1960–2012 pattern more tightly, not a better grasp of the process — their AIC is higher, and on fifty-three observations the over-fitting risk over a twelve-year horizon is real. We therefore preferred the simpler models, the choice the AIC endorses, though a reader who weighted short-horizon point accuracy above parsimony might reasonably prefer the fuller ones. A related, births-specific weakness is the seasonal difference both models carry: it is only weakly supported (seasonal differencing alone does not achieve stationarity for the TLB; Section 2.6), and because it ties each forecast to the value twelve years earlier it drags the inflated 2012 Dragon-year peak into the projection — the main source of the mid-horizon under-prediction. A longer record would resolve both the over-fitting trade-off and the structural ambiguity more cleanly. A further births-specific caveat is distributional: the residuals are approximately Gaussian for the rate (Shapiro–Wilk $p = 0.20$) but only marginally so for births ($p = 0.03$; Section 3.4), because the model cannot fully absorb the exceptionally large 1988 Dragon-year birth cohort. The 80% and 95% prediction intervals for births should therefore be read as approximate rather than exact.

Fourth, the twelve-year forecast horizon is long relative to the training sample. The prediction intervals widen substantially toward the end of the horizon, so point forecasts eight to twelve years ahead should not be read as precise projections.

### 4.4 Implications

Three practical implications follow. First, the twelve-year zodiac cycle in Singaporean fertility was a real and non-negligible source of variation through 2012. Second, the cycle appears to have weakened or disappeared by 2024, so future projections may need to place less weight on cultural seasonality and more on structural factors such as housing and the timing of marriage, which the wider literature identifies as central to Singapore's fertility (Chen, Yip and Yap, 2018). Third, the forecasts here were least accurate not at the far end of the horizon but in its first half, where the seasonal difference projected the decline too steeply while fertility briefly plateaued; even so, every realised value stayed within the 80–95% prediction intervals. The practical lesson is that, for a series of this length with a weakening cultural cycle, the prediction intervals should be reported and respected rather than the point forecast alone, even at short horizons.

---

## 5. Conclusion

This report applied the Box–Jenkins methodology to Singapore's total fertility rate and total live births from 1960 to 2024. After a log transformation of the TFR and first differencing of both series, the autocorrelation analysis revealed a clear twelve-year cycle around lags 11–13, consistent with the documented Dragon-year effect (Agarwal et al., 2021). Each series was modelled with a seasonal ARIMA at period 12. A deliberately full initial model — SARIMA(13,1,0)(1,1,0)[12] for births and SARIMA(12,1,0)(1,1,0)[12] for the rate, taking the autoregressive order across the whole zodiac cluster — was fitted and found viable, then pared back to the compact SARIMA(4,1,0)(1,1,0)[12] for both series once the intermediate autoregressive terms proved redundant. The reduction left the residuals white and _lowered_ the AIC (by 11 points for births, 6 for the rate) at a third of the parameters — the information-criterion case for the simpler model — at the cost of some test-set accuracy, a deliberate guard against over-fitting on a sixty-year record. The final models leave no autocorrelation outside the bands and forecast the held-back decade with mean absolute percentage errors of 8.9% (TFR) and 12.1% (TLB). In direct answer to the research question, then, a seasonal model represents the structure of both series fully (its residuals are statistically indistinguishable from white noise), but it forecasts the held-back decade only moderately, and its over-projection of the 2024 Dragon year shows that the cyclical component, real over the training period, can no longer be relied on for prediction. The main substantive limitation exposed by the forecast was the apparent recent weakening of the zodiac effect: both models built a rise into the 2024 Dragon year, which instead recorded a new low. Future demographic forecasting for Singapore should combine the cultural cycle with structural drivers, and may benefit from intervention or regime-switching models that allow the seasonal component to change over time.

---

## References

Agarwal, S., Qian, W., Sing, T. F. and Tan, P. L. (2021) 'Fortunes of dragons: cohort size effects on life outcomes', _Population Studies_, 75(2), pp. 191–207. doi: 10.1080/00324728.2020.1864458.

Box, G. E. P., Jenkins, G. M. and Reinsel, G. C. (2008) _Time series analysis: forecasting and control_. 4th edn. Hoboken, NJ: Wiley.

Chen, M., Yip, P. S. F. and Yap, M. T. (2018) 'Identifying the most influential groups in determining Singapore's fertility', _Journal of Social Policy_, 47(1), pp. 139–160.

Hyndman, R. J. and Athanasopoulos, G. (2021) _Forecasting: principles and practice_. 3rd edn. Melbourne: OTexts.

Hyndman, R. J. and Khandakar, Y. (2008) 'Automatic time series forecasting: the forecast package for R', _Journal of Statistical Software_, 27(3), pp. 1–22.

Lee, R. D. (1993) 'Modeling and forecasting the time series of US fertility: age distribution, range, and ultimate level', _International Journal of Forecasting_, 9(2), pp. 187–202.

R Core Team (2025) _R: a language and environment for statistical computing_. Vienna: R Foundation for Statistical Computing. Available at: https://www.R-project.org/ (Accessed: 10 June 2026).

Shair, S. N., Shaadan, N. and Meor Amirudin, N. A. B. (2024) 'Predictions of Malaysia age-specific fertility rates using the Lee-Carter and the functional data approaches', _AIUB Journal of Science and Engineering_, 23(1), pp. 71–78.

Shumway, R. H. and Stoffer, D. S. (2011) _Time series analysis and its applications: with R examples_. 3rd edn. New York: Springer.

Singapore Department of Statistics (2024) _Live-births and fertility rate_. Available at: https://www.singstat.gov.sg (Accessed: 10 June 2026).

Singapore Department of Statistics (2025) _Population trends 2025_. Singapore: Department of Statistics.

Vanella, P. (2016) _The total fertility rate in Germany until 2040: a stochastic principal components projection based on age-specific fertility rates_. Hannover Economic Papers (HEP) No. 579. Hannover: Leibniz Universität Hannover.

---

## Appendix A: Statistical appendix

### A.1 Full specification of the adopted models

**TFR — log-SARIMA(4,1,0)(1,1,0)[12].**

$$
\Big(1 - \hat{\phi}_1 B - \hat{\phi}_2 B^2 - \hat{\phi}_3 B^3 - \hat{\phi}_4 B^4\Big)(1 - \hat{\Phi}_1 B^{12})(1-B)(1-B^{12})\,\log(\text{TFR}_t) = \varepsilon_t,
$$

with $\hat{\phi}_1 = 0.450$ (SE 0.144, _t_ = 3.12), $\hat{\phi}_2 = -0.059$ (SE 0.163, _t_ = −0.36), $\hat{\phi}_3 = 0.333$ (SE 0.163, _t_ = 2.05), $\hat{\phi}_4 = -0.405$ (SE 0.158, _t_ = −2.56), $\hat{\Phi}_1 = -0.334$ (SE 0.166, _t_ = −2.01), and residual variance $\hat\sigma^2 = 0.00376$ (log-likelihood 56.49; AIC −100.98; BIC −90.84). Four of the five coefficients are individually significant ($\phi_2$ is not); the model is a pure autoregression with all AR roots outside the unit circle, so no invertibility question arises. The AIC incorporates the seasonal difference ($D = 1$) and is directly comparable with the other row of Table 2, which carries the same differencing, but should not be compared with any $D = 0$ specification not shown here.

**TLB — SARIMA(4,1,0)(1,1,0)[12].**

$$
\Big(1 - \hat{\phi}_1 B - \hat{\phi}_2 B^2 - \hat{\phi}_3 B^3 - \hat{\phi}_4 B^4\Big)(1 - \hat{\Phi}_1 B^{12})(1-B)(1-B^{12})\,\text{TLB}_t = \varepsilon_t,
$$

with $\hat{\phi}_1 = 0.292$ (SE 0.143, _t_ = 2.05), $\hat{\phi}_2 = 0.081$ (SE 0.155, _t_ = 0.52), $\hat{\phi}_3 = 0.231$ (SE 0.149, _t_ = 1.56), $\hat{\phi}_4 = -0.441$ (SE 0.151, _t_ = −2.92), $\hat{\Phi}_1 = -0.252$ (SE 0.169, _t_ = −1.49), and residual variance $\hat\sigma^2 = 6.85 \times 10^{6}$ ($\hat\sigma \approx 2{,}618$; log-likelihood −369.77; AIC 751.55; BIC 761.68). The fourth-order autoregressive term is the strongest non-seasonal coefficient and justifies $p = 4$ — it matches the significant spike at lag 4 (partial autocorrelation −0.42) in the PACF of the doubly-differenced series $(1-B)(1-B^{12})\text{TLB}$; the seasonal AR term is not individually significant but is retained to represent the zodiac cycle. As a pure autoregression the model raises no invertibility question. The AIC incorporates the seasonal difference ($D = 1$) and is directly comparable with the other row of Table 3, which carries the same differencing, but should not be compared with any $D = 0$ specification not shown here.

### A.2 Parameter estimation

The maximum likelihood estimates were obtained from the state-space (Kalman filter) representation of the SARIMA model, as implemented in `forecast::Arima()`. The likelihood is

$$
L(\boldsymbol{\theta}) = (2\pi)^{-n/2}\,|\boldsymbol{\Sigma}|^{-1/2}\exp\!\left(-\tfrac{1}{2}\,\boldsymbol{X}^\top \boldsymbol{\Sigma}^{-1}\boldsymbol{X}\right),
$$

where $\boldsymbol{\theta}$ collects all AR, MA, seasonal and variance parameters, $\boldsymbol{X}$ is the vector of transformed and differenced observations, and $\boldsymbol{\Sigma}$ is the implied variance–covariance matrix. The log-likelihood was maximised numerically using the BFGS algorithm, with starting values from the conditional sum-of-squares estimator.

### A.3 Diagnostic test definitions

The Ljung–Box statistic at lag $m$ for residuals $\hat{\varepsilon}_1,\dots,\hat{\varepsilon}_n$ is

$$
Q^*(m) = n(n+2)\sum_{k=1}^{m}\frac{\hat{r}_k^{\,2}}{n-k},
$$

where $\hat{r}_k$ is the residual autocorrelation at lag $k$. Under the null of no autocorrelation, $Q^*(m)$ is asymptotically $\chi^2_{m-r}$, where $r$ is the number of estimated AR and MA parameters; a p-value above 0.05 supports white-noise residuals.

The ADF regression is

$$
\nabla X_t = \alpha + \beta t + \gamma X_{t-1} + \sum_{i=1}^{p}\delta_i \nabla X_{t-i} + \varepsilon_t,
$$

with null $H_0:\gamma = 0$ (unit root) against $H_1:\gamma < 0$ (stationary). The KPSS test regresses the series on a constant (and a trend where appropriate) and tests whether the sum of squared partial sums of the residuals exceeds a critical value, under a null of stationarity.

---
