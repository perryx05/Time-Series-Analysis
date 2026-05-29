# Methods & Results Draft — Singapore TFR/TLB

## Part 1: Methods — Stationarity and Model Identification

---

### Figure 1 — Raw TFR Series (1960–2024)

![Figure 1: Singapore TFR with policy events and Zodiac years](methods/fig1_tfr_raw.png)

Singapore's TFR collapsed from 5.76 children per woman in 1960 to 0.97 in 2023, a decline of nearly 5 full children per woman over six decades driven by industrialisation, urbanisation, and explicit government population policy. The series crossed below the replacement level of 2.1 in approximately 1976 and has never returned — by the mid-1980s TFR was already below 1.7, making any mean-reversion assumption untenable. This persistent, monotone decline with no tendency to return to a stable mean is the defining visual signature of a non-stationary process, and it directly motivates the ADF test reported in Table 1. Dragon (green) and Tiger (orange) years highlight the Zodiac fertility cycle.

---

### Figure 3 — First-Differenced TLB and TFR (Fixed Vertical Scale)

![Figure 3: First-differenced TLB and TFR with fixed y-axis](methods/fig3_diff_series.png)

After one round of differencing, both series fluctuate around zero with no systematic upward or downward drift, confirming that d = 1 is the appropriate differencing order. The expanded y-axis (TLB: ±10 000 births/year; TFR: ±0.6 children/woman) makes the true magnitude of year-to-year shocks visible: for TLB, the "Have Three or More" campaign produced a +5 237 birth jump in 1987 and a further surge to +9 341 in 1988, while the 2003 dip (−3 275) reflects post-SARS effects. For ΔTFR, the largest annual fall was −0.55 in 1967 with a partial recovery of +0.34 in 1988. One differencing is clearly sufficient for TLB (ADF p = 0.040); the ADF result for ΔTFR is borderline (p = 0.083), but given the strong visual evidence of stationarity and the risk of over-differencing, d = 1 is adopted for both series.

---

### Figure 4a — ACF and PACF of First-Differenced TFR (lag.max = 50)

![Figure 4a: ACF and PACF of first-differenced TFR](methods/fig4a_acf_pacf_diff_tfr.png)

### Figure 4b — ACF and PACF of First-Differenced TLB (lag.max = 50)

![Figure 4b: ACF and PACF of first-differenced TLB](methods/fig4b_acf_pacf_diff_tlb.png)

By extending the ACF/PACF window to lag 50, a repeating 12-year autocorrelation structure is clearly visible, aligning perfectly with the Dragon-Tiger Chinese Zodiac fertility cycle.

---

### Table 1 — ADF Stationarity Test Results

Augmented Dickey-Fuller tests (H₀: unit root; alternative: stationary). Training period only (1960–2012 raw; 1961–2012 differenced).

| Series               | ADF statistic |  p-value  | Conclusion                                          |
| -------------------- | :-----------: | :-------: | --------------------------------------------------- |
| TFR, raw (1960–2012) |    −3.129     |   0.120   | Non-stationary — fail to reject H₀ at 5%            |
| TLB, raw (1960–2012) |    −2.543     |   0.356   | Non-stationary — fail to reject H₀ at 5%            |
| ΔTFR (1961–2012)     |    −3.288     |   0.083   | Borderline — fail to reject H₀ at 5%; reject at 10% |
| **ΔTLB (1961–2012)** |  **−3.625**   | **0.040** | **Stationary — reject H₀ at 5%**                    |

First-differencing clearly renders TLB stationary. The ADF result for ΔTFR is borderline (p = 0.083); we proceed with d = 1 for TFR based on the visual evidence in Figure 3 (no drift) and to avoid over-differencing.

---

### High-p Model Candidates

Upon discovering the lag-12 cycle, high-p models were tested up to $p=15$ for ARIMA and $p=2$ for SARIMA with $period=12$. 

- **ARIMA (high-p)**: Models like ARIMA(13,1,0), ARIMA(14,1,0), and ARIMA(15,1,0) were evaluated. All failed the strict Ljung-Box tests and exhibited problematic ACF spikes at larger lags, demonstrating that standard autoregressive terms cannot adequately capture the strict 12-year seasonal repeating structure.
- **SARIMA (high-p)**: SARIMA(1,1,0)(1,1,0)[12] and SARIMA(2,1,0)(1,1,0)[12] achieved lower AIC and better performance but still exhibited some residual structure (lag 3/4). 

Due to residual concerns with initial high-p models, further parsimonious tuning will be explored for the final report.
