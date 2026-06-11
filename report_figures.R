# =============================================================================
# REPORT FIGURES: Singapore TLB & TFR Time Series Analysis
# Generates 12 publication-quality figures + model diagnostics
# Output: plots/ subfolder, res = 150 dpi
# =============================================================================

library(tseries)
library(forecast)

options(stringsAsFactors = FALSE)
options(scipen = 999)
set.seed(42)
dir.create("figures", showWarnings = FALSE)

# =============================================================================
# DATA LOADING
# =============================================================================
df        <- read.csv("cleaned_tlb_tfr_1960_2024.csv")
tlb_ts    <- ts(df$TLB, start = 1960, frequency = 1)
tfr_ts    <- ts(df$TFR, start = 1960, frequency = 1)
tlb_train <- window(tlb_ts, start = 1960, end = 2012)
tlb_test  <- window(tlb_ts, start = 2013, end = 2024)
tfr_train <- window(tfr_ts, start = 1960, end = 2012)
tfr_test  <- window(tfr_ts, start = 2013, end = 2024)

n_test     <- length(tlb_test)   # 12
n_train    <- length(tlb_train)  # 53
test_years <- 2013:2024

tlb_diff1 <- diff(tlb_train, differences = 1)
tfr_diff1 <- diff(tfr_train, differences = 1)

# =============================================================================
# HELPER: annotation-safe y value for text labels in acf/pacf plots
# =============================================================================
ci_band <- function(n) 1.96 / sqrt(n)

# =============================================================================
# FIG 1: TLB Raw Series (1960-2024)
# =============================================================================
png("plots/fig01_tlb_raw.png", width = 1050, height = 560, res = 150, bg = "white")
par(mar = c(5, 6, 4, 2), bg = "white")
plot(tlb_ts, type = "l", lwd = 2, col = "black",
     main = "Fig 1: Singapore Total Live Births (1960–2024)",
     xlab = "Year", ylab = "Total Live Births",
     ylim = c(28000, 72000), las = 1)
abline(v = 2013, lty = 2, col = "gray35", lwd = 1.5)
abline(v = 1966,  lty = 3, col = "steelblue4", lwd = 1.2)
abline(v = 1987,  lty = 3, col = "darkorange3", lwd = 1.2)
abline(v = 2020,  lty = 3, col = "firebrick3",  lwd = 1.2)
text(1966, 70500, "1966\nFamily Planning Board", col = "steelblue4",  cex = 0.68, adj = c(0, 0.5))
text(1987, 70500, "1987\n'Have 3 or More'",      col = "darkorange3", cex = 0.68, adj = c(0, 0.5))
text(2020, 70500, "2020\nCOVID-19",              col = "firebrick3",  cex = 0.68, adj = c(1, 0.5))
text(2013, 29500, "Train | Test",               col = "gray35",      cex = 0.75, pos = 4)
legend("bottomleft", bty = "n",
       legend = c("TLB (observed)", "Train/Test split (2013)"),
       lwd = c(2, 1.5), lty = c(1, 2), col = c("black", "gray35"), cex = 0.85)
dev.off()

# =============================================================================
# FIG 2: TFR Raw Series (1960-2024)
# =============================================================================
png("plots/fig02_tfr_raw.png", width = 1050, height = 560, res = 150, bg = "white")
par(mar = c(5, 6, 4, 2), bg = "white")
plot(tfr_ts, type = "l", lwd = 2, col = "black",
     main = "Fig 2: Singapore Total Fertility Rate (1960–2024)",
     xlab = "Year", ylab = "Children per Woman (TFR)",
     ylim = c(0.5, 6.5), las = 1)
abline(h = 2.1,  lty = 2, col = "firebrick3", lwd = 1.8)
abline(v = 2013, lty = 2, col = "gray35",     lwd = 1.5)
text(1963, 2.4,  "Replacement level (2.1)", col = "firebrick3", cex = 0.78, pos = 4)
text(2013, 0.75, "Train | Test",            col = "gray35",    cex = 0.75, pos = 4)
legend("topright", bty = "n",
       legend = c("TFR (observed)", "Replacement level = 2.1", "Train/Test split (2013)"),
       lwd = c(2, 1.8, 1.5), lty = c(1, 2, 2),
       col = c("black", "firebrick3", "gray35"), cex = 0.85)
dev.off()

# =============================================================================
# FIG 3: TLB with 5-year centred MA + irregular component (training 1960-2012)
# =============================================================================
ma5_tlb <- stats::filter(tlb_train, rep(1 / 5, 5), sides = 2)
irr_tlb <- ts(as.numeric(tlb_train) - as.numeric(ma5_tlb), start = 1960, frequency = 1)

png("plots/fig03_tlb_ma.png", width = 1050, height = 720, res = 150, bg = "white")
par(mfrow = c(2, 1), mar = c(2, 6, 3, 2), bg = "white", oma = c(3, 0, 0, 0))
plot(tlb_train, type = "l", lwd = 1.5, col = "gray60",
     main = "Fig 3 (top): TLB with 5-Year Centred MA — Training (1960–2012)",
     xlab = "", ylab = "Total Live Births",
     ylim = c(33000, 65000), las = 1)
lines(ma5_tlb, lwd = 2.5, col = "steelblue4")
legend("topright", bty = "n",
       legend = c("Observed TLB", "5-year centred MA (trend)"),
       col = c("gray60", "steelblue4"), lwd = c(1.5, 2.5), cex = 0.82)

plot(irr_tlb, type = "l", lwd = 1.5, col = "black",
     main = "Fig 3 (bottom): Irregular Component (Observed − MA)",
     xlab = "", ylab = expression(paste(Delta, " TLB from trend")),
     las = 1)
abline(h = 0, lty = 2, col = "gray50", lwd = 1.2)
mtext("Year", side = 1, outer = TRUE, line = 1.5, cex = 0.95)
par(mfrow = c(1, 1))
dev.off()

# =============================================================================
# FIG 4: TFR with 5-year centred MA + irregular component (training 1960-2012)
# =============================================================================
ma5_tfr <- stats::filter(tfr_train, rep(1 / 5, 5), sides = 2)
irr_tfr <- ts(as.numeric(tfr_train) - as.numeric(ma5_tfr), start = 1960, frequency = 1)

png("plots/fig04_tfr_ma.png", width = 1050, height = 720, res = 150, bg = "white")
par(mfrow = c(2, 1), mar = c(2, 6, 3, 2), bg = "white", oma = c(3, 0, 0, 0))
plot(tfr_train, type = "l", lwd = 1.5, col = "gray60",
     main = "Fig 4 (top): TFR with 5-Year Centred MA — Training (1960–2012)",
     xlab = "", ylab = "Children per Woman (TFR)", las = 1)
lines(ma5_tfr, lwd = 2.5, col = "steelblue4")
legend("topright", bty = "n",
       legend = c("Observed TFR", "5-year centred MA (trend)"),
       col = c("gray60", "steelblue4"), lwd = c(1.5, 2.5), cex = 0.82)

plot(irr_tfr, type = "l", lwd = 1.5, col = "black",
     main = "Fig 4 (bottom): Irregular Component (Observed − MA)",
     xlab = "", ylab = expression(paste(Delta, " TFR from trend")),
     las = 1)
abline(h = 0, lty = 2, col = "gray50", lwd = 1.2)
mtext("Year", side = 1, outer = TRUE, line = 1.5, cex = 0.95)
par(mfrow = c(1, 1))
dev.off()

# =============================================================================
# FIG 5: First-differenced TLB and TFR — FIXED vertical scales
# =============================================================================
# Compute range so ylim clearly shows all variation
tlb_range <- range(tlb_diff1, na.rm = TRUE)
tfr_range <- range(tfr_diff1, na.rm = TRUE)
tlb_ylim  <- c(min(-10000, tlb_range[1] * 1.1), max(10000, tlb_range[2] * 1.1))
tfr_ylim  <- c(min(-0.65,  tfr_range[1] * 1.1), max(0.65,  tfr_range[2] * 1.1))

# Notable extremes in training period
tlb_max_yr <- time(tlb_diff1)[which.max(tlb_diff1)]
tlb_min_yr <- time(tlb_diff1)[which.min(tlb_diff1)]
tfr_max_yr <- time(tfr_diff1)[which.max(tfr_diff1)]
tfr_min_yr <- time(tfr_diff1)[which.min(tfr_diff1)]

cat("\nTLB diff: max =", max(tlb_diff1), "in", tlb_max_yr,
    " | min =", min(tlb_diff1), "in", tlb_min_yr, "\n")
cat("TFR diff: max =", max(tfr_diff1), "in", tfr_max_yr,
    " | min =", min(tfr_diff1), "in", tfr_min_yr, "\n")

png("plots/fig05_diff_series.png", width = 1050, height = 700, res = 150, bg = "white")
par(mfrow = c(2, 1), mar = c(2, 7, 3.5, 2), bg = "white", oma = c(3, 0, 0, 0))

plot(tlb_diff1, type = "l", lwd = 1.5, col = "black",
     main = "Fig 5 (top): First-Differenced TLB, ΔTLB (1961–2012)",
     xlab = "", ylab = expression(paste(Delta, "TLB (births)")),
     ylim = tlb_ylim, las = 1)
abline(h = 0, lty = 2, col = "gray50", lwd = 1.2)
# Annotate the two most extreme years
text(tlb_max_yr, max(tlb_diff1),
     paste0(tlb_max_yr, "\n(+", round(max(tlb_diff1)), ")"),
     cex = 0.68, col = "darkorange3", pos = 3)
text(tlb_min_yr, min(tlb_diff1),
     paste0(tlb_min_yr, "\n(", round(min(tlb_diff1)), ")"),
     cex = 0.68, col = "firebrick3", pos = 1)

plot(tfr_diff1, type = "l", lwd = 1.5, col = "black",
     main = "Fig 5 (bottom): First-Differenced TFR, ΔTFR (1961–2012)",
     xlab = "", ylab = expression(paste(Delta, "TFR (children/woman)")),
     ylim = tfr_ylim, las = 1)
abline(h = 0, lty = 2, col = "gray50", lwd = 1.2)
text(tfr_min_yr, min(tfr_diff1),
     paste0(tfr_min_yr, "\n(", round(min(tfr_diff1), 2), ")"),
     cex = 0.68, col = "firebrick3", pos = 1)

mtext("Year", side = 1, outer = TRUE, line = 1.5, cex = 0.95)
par(mfrow = c(1, 1))
dev.off()

# =============================================================================
# FIG 6: ACF/PACF of diff(TLB_train) — lag 20 (FIXED)
# =============================================================================
ci_tlb <- ci_band(length(tlb_diff1))
png("plots/fig06_tlb_diff_acf_pacf.png", width = 1050, height = 560, res = 150, bg = "white")
par(mfrow = c(1, 2), mar = c(4, 5, 3, 1), oma = c(0, 0, 3, 0), bg = "white")
acf(tlb_diff1,  lag.max = 20,
    main = "ACF",
    xlab = "Lag (years)", ylab = "ACF", ylim = c(-0.55, 1))
pacf(tlb_diff1, lag.max = 20,
     main = "PACF",
     xlab = "Lag (years)", ylab = "Partial ACF", ylim = c(-0.55, 0.55))
mtext("Fig 6: ACF and PACF of First-Differenced TLB  (Training 1961-2012, lag.max = 20)",
      side = 3, outer = TRUE, line = 1, cex = 0.95, font = 2)
par(mfrow = c(1, 1))
dev.off()

# =============================================================================
# FIG 7: ACF/PACF of diff(TFR_train) — lag 20 (FIXED)
# =============================================================================
ci_tfr <- ci_band(length(tfr_diff1))
png("plots/fig07_tfr_diff_acf_pacf.png", width = 1050, height = 560, res = 150, bg = "white")
par(mfrow = c(1, 2), mar = c(4, 5, 3, 1), oma = c(0, 0, 3, 0), bg = "white")
acf(tfr_diff1,  lag.max = 20,
    main = "ACF",
    xlab = "Lag (years)", ylab = "ACF", ylim = c(-0.55, 1))
pacf(tfr_diff1, lag.max = 20,
     main = "PACF",
     xlab = "Lag (years)", ylab = "Partial ACF", ylim = c(-0.55, 0.55))
mtext("Fig 7: ACF and PACF of First-Differenced TFR  (Training 1961-2012, lag.max = 20)",
      side = 3, outer = TRUE, line = 1, cex = 0.95, font = 2)
par(mfrow = c(1, 1))
dev.off()

# =============================================================================
# SECTION: Fit candidate models and collect diagnostics for the table
# =============================================================================
cat("\n=== CANDIDATE MODEL FITTING ===\n")

fit_diag <- function(model, label) {
  bl10 <- Box.test(residuals(model), lag = 10, type = "Ljung-Box")
  bl20 <- Box.test(residuals(model), lag = 20, type = "Ljung-Box")
  cat(sprintf("  %-50s AIC=%.2f  BIC=%.2f  BL10 p=%.4f  BL20 p=%.4f\n",
              label, AIC(model), BIC(model), bl10$p.value, bl20$p.value))
  list(aic = round(AIC(model), 2), bic = round(BIC(model), 2),
       bl10 = round(bl10$p.value, 4), bl20 = round(bl20$p.value, 4),
       wn = (bl10$p.value > 0.05) & (bl20$p.value > 0.05))
}

# ---- TLB candidates ----
cat("\n--- TLB candidates ---\n")
m_T1 <- arima(tlb_train, order = c(0, 1, 0),             method = "ML")       # ARMA(0,0) equiv
m_T2 <- arima(tlb_train, order = c(1, 1, 0),             method = "CSS-ML")   # AR(1)
m_T3 <- arima(tlb_train, order = c(1, 1, 1),             method = "CSS-ML")   # ARMA(1,1)
m_T4 <- arima(tlb_train, order = c(2, 1, 0),             method = "CSS-ML")   # AR(2)
m_TBEST <- arima(tlb_train,
                 order    = c(1, 1, 0),
                 seasonal = list(order = c(1, 0, 0), period = 12),
                 method   = "CSS-ML")                                           # SARIMA best

d_T1    <- fit_diag(m_T1,    "T1: ARIMA(0,1,0) [RW / ARMA(0,0)]")
d_T2    <- fit_diag(m_T2,    "T2: ARIMA(1,1,0) [AR(1)]")
d_T3    <- fit_diag(m_T3,    "T3: ARIMA(1,1,1) [ARMA(1,1)]")
d_T4    <- fit_diag(m_T4,    "T4: ARIMA(2,1,0) [AR(2)]")
d_TBEST <- fit_diag(m_TBEST, "BEST: SARIMA(1,1,0)(1,0,0)[12]")

# ---- TFR candidates ----
cat("\n--- TFR candidates ---\n")
m_F1 <- arima(tfr_train, order = c(1, 1, 0),             method = "CSS-ML")   # AR(1)
m_F2 <- arima(tfr_train, order = c(2, 1, 0),             method = "CSS-ML")   # AR(2)
m_F3 <- arima(tfr_train, order = c(1, 1, 1),             method = "CSS-ML")   # ARMA(1,1)
m_F4 <- arima(tfr_train, order = c(2, 1, 1),             method = "CSS-ML")   # ARMA(2,1)
m_FBEST <- arima(tfr_train,
                 order    = c(1, 1, 0),
                 seasonal = list(order = c(1, 0, 0), period = 12),
                 method   = "CSS-ML")

d_F1    <- fit_diag(m_F1,    "F1: ARIMA(1,1,0) [AR(1)]")
d_F2    <- fit_diag(m_F2,    "F2: ARIMA(2,1,0) [AR(2)]")
d_F3    <- fit_diag(m_F3,    "F3: ARIMA(1,1,1) [ARMA(1,1)]")
d_F4    <- fit_diag(m_F4,    "F4: ARIMA(2,1,1) [ARMA(2,1)]")
d_FBEST <- fit_diag(m_FBEST, "BEST: SARIMA(1,1,0)(1,0,0)[12]")

# Print Box-Ljung details for T1 to confirm ARMA(0,0) issue
bl_T1 <- Box.test(residuals(m_T1), lag = 10, type = "Ljung-Box")
cat(sprintf("\nT1 BL10: Q=%.3f, p=%.4f\n", bl_T1$statistic, bl_T1$p.value))
bl_T1_20 <- Box.test(residuals(m_T1), lag = 20, type = "Ljung-Box")
cat(sprintf("T1 BL20: Q=%.3f, p=%.4f\n", bl_T1_20$statistic, bl_T1_20$p.value))

# =============================================================================
# FIG 9: Residual ACF/PACF — Best TLB model SARIMA(1,1,0)(1,0,0)[12]
# =============================================================================
resid_tbest <- residuals(m_TBEST)
bl_tbest_10 <- Box.test(resid_tbest, lag = 10, type = "Ljung-Box")
bl_tbest_20 <- Box.test(resid_tbest, lag = 20, type = "Ljung-Box")
cat(sprintf("\nBEST TLB BL10: p=%.4f  BL20: p=%.4f\n",
            bl_tbest_10$p.value, bl_tbest_20$p.value))

png("plots/fig09_tlb_best_resid_acfpacf.png", width = 1050, height = 560, res = 150, bg = "white")
par(mfrow = c(1, 2), mar = c(4, 5, 3, 1), oma = c(0, 0, 3, 0), bg = "white")
acf(resid_tbest,  lag.max = 20,
    main = "ACF",
    xlab = "Lag (years)", ylab = "ACF", ylim = c(-0.55, 1))
pacf(resid_tbest, lag.max = 20,
     main = "PACF",
     xlab = "Lag (years)", ylab = "Partial ACF", ylim = c(-0.55, 0.55))
mtext("Fig 9: Residual ACF and PACF  --  TLB Best Model: SARIMA(1,1,0)(1,0,0)[12]",
      side = 3, outer = TRUE, line = 1, cex = 0.95, font = 2)
par(mfrow = c(1, 1))
dev.off()

# =============================================================================
# FIG 10: Residual ACF/PACF — Best TFR model SARIMA(1,1,0)(1,0,0)[12]
# =============================================================================
resid_fbest <- residuals(m_FBEST)
bl_fbest_10 <- Box.test(resid_fbest, lag = 10, type = "Ljung-Box")
bl_fbest_20 <- Box.test(resid_fbest, lag = 20, type = "Ljung-Box")
cat(sprintf("BEST TFR BL10: p=%.4f  BL20: p=%.4f\n",
            bl_fbest_10$p.value, bl_fbest_20$p.value))

png("plots/fig10_tfr_best_resid_acfpacf.png", width = 1050, height = 560, res = 150, bg = "white")
par(mfrow = c(1, 2), mar = c(4, 5, 3, 1), oma = c(0, 0, 3, 0), bg = "white")
acf(resid_fbest,  lag.max = 20,
    main = "ACF",
    xlab = "Lag (years)", ylab = "ACF", ylim = c(-0.55, 1))
pacf(resid_fbest, lag.max = 20,
     main = "PACF",
     xlab = "Lag (years)", ylab = "Partial ACF", ylim = c(-0.55, 0.55))
mtext("Fig 10: Residual ACF and PACF  --  TFR Best Model: SARIMA(1,1,0)(1,0,0)[12]",
      side = 3, outer = TRUE, line = 1, cex = 0.95, font = 2)
par(mfrow = c(1, 1))
dev.off()

# =============================================================================
# FORECASTING 2013-2024 — best models
# =============================================================================
pred_tlb <- predict(m_TBEST, n.ahead = n_test)
pred_tfr <- predict(m_FBEST, n.ahead = n_test)

fc_tlb  <- as.numeric(pred_tlb$pred)
se_tlb  <- as.numeric(pred_tlb$se)
fc_tfr  <- as.numeric(pred_tfr$pred)
se_tfr  <- as.numeric(pred_tfr$se)

# Prediction intervals
tlb_lo80 <- fc_tlb - 1.281 * se_tlb
tlb_hi80 <- fc_tlb + 1.281 * se_tlb
tlb_lo95 <- fc_tlb - 1.960 * se_tlb
tlb_hi95 <- fc_tlb + 1.960 * se_tlb

tfr_lo80 <- fc_tfr - 1.281 * se_tfr
tfr_hi80 <- fc_tfr + 1.281 * se_tfr
tfr_lo95 <- fc_tfr - 1.960 * se_tfr
tfr_hi95 <- fc_tfr + 1.960 * se_tfr

# Accuracy metrics
calc_acc <- function(actual, fc, label) {
  e <- as.numeric(actual) - fc
  rmse <- sqrt(mean(e^2))
  mae  <- mean(abs(e))
  mape <- mean(abs(e / as.numeric(actual))) * 100
  cat(sprintf("%s — RMSE=%.2f  MAE=%.2f  MAPE=%.2f%%\n", label, rmse, mae, mape))
  list(rmse = rmse, mae = mae, mape = mape)
}

cat("\n=== FORECAST ACCURACY (2013-2024) ===\n")
acc_tlb <- calc_acc(tlb_test, fc_tlb, "TLB SARIMA(1,1,0)(1,0,0)[12]")
acc_tfr <- calc_acc(tfr_test, fc_tfr, "TFR SARIMA(1,1,0)(1,0,0)[12]")

# =============================================================================
# FIG 11: TLB Forecast vs Actual (2013-2024) with 80% and 95% PI
# =============================================================================
train_window_start <- 1995   # show from 1995 for context
ylim_tlb_fc <- range(c(as.numeric(window(tlb_ts, start = train_window_start)),
                        tlb_lo95, tlb_hi95)) * c(0.92, 1.04)

png("plots/fig11_tlb_forecast.png", width = 1050, height = 580, res = 150, bg = "white")
par(mar = c(5, 6, 4, 2), bg = "white")
plot(window(tlb_ts, start = train_window_start), type = "l", lwd = 2, col = "black",
     xlim = c(train_window_start, 2024), ylim = ylim_tlb_fc,
     main = "Fig 11: TLB Forecast vs Actual (2013–2024)\nBest Model: SARIMA(1,1,0)(1,0,0)[12]",
     xlab = "Year", ylab = "Total Live Births", las = 1)
abline(v = 2012.5, lty = 3, col = "gray40", lwd = 1.2)
text(2012.5, ylim_tlb_fc[2] * 0.99, "Train | Test", col = "gray40", cex = 0.72, pos = 2)

# 95% PI — outer band
polygon(c(test_years, rev(test_years)),
        c(tlb_lo95, rev(tlb_hi95)),
        col = adjustcolor("steelblue3", alpha.f = 0.20), border = NA)
# 80% PI — inner band
polygon(c(test_years, rev(test_years)),
        c(tlb_lo80, rev(tlb_hi80)),
        col = adjustcolor("steelblue3", alpha.f = 0.35), border = NA)

# Test actuals
lines(tlb_test, lwd = 2, col = "steelblue4")
# Forecast
lines(test_years, fc_tlb, col = "firebrick3", lwd = 2, lty = 2)

# Annotate COVID dip
cov_idx <- which(test_years == 2020)
text(2020, as.numeric(tlb_test)[cov_idx] - 1000,
     "2020\nCOVID-19", cex = 0.65, col = "gray30", pos = 1)

legend("topright", bty = "n",
       legend = c("Training (1995–2012)", "Test actuals (2013–2024)",
                  "Forecast (SARIMA)", "80% PI", "95% PI"),
       col = c("black", "steelblue4", "firebrick3",
               adjustcolor("steelblue3", alpha.f = 0.5),
               adjustcolor("steelblue3", alpha.f = 0.25)),
       lwd = c(2, 2, 2, 8, 8), lty = c(1, 1, 2, 1, 1), cex = 0.78)
dev.off()

# =============================================================================
# FIG 12: TFR Forecast vs Actual (2013-2024) with 80% and 95% PI
# =============================================================================
ylim_tfr_fc <- range(c(as.numeric(window(tfr_ts, start = train_window_start)),
                        tfr_lo95, tfr_hi95)) * c(0.88, 1.06)

png("plots/fig12_tfr_forecast.png", width = 1050, height = 580, res = 150, bg = "white")
par(mar = c(5, 6, 4, 2), bg = "white")
plot(window(tfr_ts, start = train_window_start), type = "l", lwd = 2, col = "black",
     xlim = c(train_window_start, 2024), ylim = ylim_tfr_fc,
     main = "Fig 12: TFR Forecast vs Actual (2013–2024)\nBest Model: SARIMA(1,1,0)(1,0,0)[12]",
     xlab = "Year", ylab = "Children per Woman (TFR)", las = 1)
abline(v = 2012.5, lty = 3, col = "gray40", lwd = 1.2)
text(2012.5, ylim_tfr_fc[2] * 0.99, "Train | Test", col = "gray40", cex = 0.72, pos = 2)

polygon(c(test_years, rev(test_years)),
        c(tfr_lo95, rev(tfr_hi95)),
        col = adjustcolor("steelblue3", alpha.f = 0.20), border = NA)
polygon(c(test_years, rev(test_years)),
        c(tfr_lo80, rev(tfr_hi80)),
        col = adjustcolor("steelblue3", alpha.f = 0.35), border = NA)

lines(tfr_test, lwd = 2, col = "steelblue4")
lines(test_years, fc_tfr, col = "firebrick3", lwd = 2, lty = 2)

# Replacement level
abline(h = 2.1, lty = 2, col = "gray60", lwd = 1.0)
text(1996, 2.15, "Replacement level (2.1)", cex = 0.65, col = "gray50", pos = 4)

legend("topright", bty = "n",
       legend = c("Training (1995–2012)", "Test actuals (2013–2024)",
                  "Forecast (SARIMA)", "80% PI", "95% PI"),
       col = c("black", "steelblue4", "firebrick3",
               adjustcolor("steelblue3", alpha.f = 0.5),
               adjustcolor("steelblue3", alpha.f = 0.25)),
       lwd = c(2, 2, 2, 8, 8), lty = c(1, 1, 2, 1, 1), cex = 0.78)
dev.off()

# =============================================================================
# PRINT SUMMARY FOR MARKDOWN REPORT
# =============================================================================
cat("\n\n===== SUMMARY FOR REPORT =====\n")
cat("\n-- TLB Candidate Diagnostics --\n")
cat(sprintf("T1 ARIMA(0,1,0): AIC=%.2f  BIC=%.2f  BL10=%.4f  BL20=%.4f  WN=%s\n",
    d_T1$aic, d_T1$bic, d_T1$bl10, d_T1$bl20, d_T1$wn))
cat(sprintf("T2 ARIMA(1,1,0): AIC=%.2f  BIC=%.2f  BL10=%.4f  BL20=%.4f  WN=%s\n",
    d_T2$aic, d_T2$bic, d_T2$bl10, d_T2$bl20, d_T2$wn))
cat(sprintf("T3 ARIMA(1,1,1): AIC=%.2f  BIC=%.2f  BL10=%.4f  BL20=%.4f  WN=%s\n",
    d_T3$aic, d_T3$bic, d_T3$bl10, d_T3$bl20, d_T3$wn))
cat(sprintf("T4 ARIMA(2,1,0): AIC=%.2f  BIC=%.2f  BL10=%.4f  BL20=%.4f  WN=%s\n",
    d_T4$aic, d_T4$bic, d_T4$bl10, d_T4$bl20, d_T4$wn))
cat(sprintf("BEST SARIMA(1,1,0)(1,0,0)[12]: AIC=%.2f  BIC=%.2f  BL10=%.4f  BL20=%.4f  WN=%s\n",
    d_TBEST$aic, d_TBEST$bic, d_TBEST$bl10, d_TBEST$bl20, d_TBEST$wn))

cat("\n-- TFR Candidate Diagnostics --\n")
cat(sprintf("F1 ARIMA(1,1,0): AIC=%.2f  BIC=%.2f  BL10=%.4f  BL20=%.4f  WN=%s\n",
    d_F1$aic, d_F1$bic, d_F1$bl10, d_F1$bl20, d_F1$wn))
cat(sprintf("F2 ARIMA(2,1,0): AIC=%.2f  BIC=%.2f  BL10=%.4f  BL20=%.4f  WN=%s\n",
    d_F2$aic, d_F2$bic, d_F2$bl10, d_F2$bl20, d_F2$wn))
cat(sprintf("F3 ARIMA(1,1,1): AIC=%.2f  BIC=%.2f  BL10=%.4f  BL20=%.4f  WN=%s\n",
    d_F3$aic, d_F3$bic, d_F3$bl10, d_F3$bl20, d_F3$wn))
cat(sprintf("F4 ARIMA(2,1,1): AIC=%.2f  BIC=%.2f  BL10=%.4f  BL20=%.4f  WN=%s\n",
    d_F4$aic, d_F4$bic, d_F4$bl10, d_F4$bl20, d_F4$wn))
cat(sprintf("BEST SARIMA(1,1,0)(1,0,0)[12]: AIC=%.2f  BIC=%.2f  BL10=%.4f  BL20=%.4f  WN=%s\n",
    d_FBEST$aic, d_FBEST$bic, d_FBEST$bl10, d_FBEST$bl20, d_FBEST$wn))

cat("\n-- Forecast Accuracy (2013-2024) --\n")
cat(sprintf("TLB SARIMA: RMSE=%.1f  MAE=%.1f  MAPE=%.2f%%\n",
            acc_tlb$rmse, acc_tlb$mae, acc_tlb$mape))
cat(sprintf("TFR SARIMA: RMSE=%.4f  MAE=%.4f  MAPE=%.2f%%\n",
            acc_tfr$rmse, acc_tfr$mae, acc_tfr$mape))

cat("\n-- ADF Tests --\n")
adf_tlb_raw  <- adf.test(tlb_train, alternative = "stationary")
adf_tfr_raw  <- adf.test(tfr_train, alternative = "stationary")
adf_tlb_diff <- adf.test(tlb_diff1, alternative = "stationary")
adf_tfr_diff <- adf.test(tfr_diff1, alternative = "stationary")
cat(sprintf("ADF TLB raw:  stat=%.4f  p=%.4f\n", adf_tlb_raw$statistic,  adf_tlb_raw$p.value))
cat(sprintf("ADF TFR raw:  stat=%.4f  p=%.4f\n", adf_tfr_raw$statistic,  adf_tfr_raw$p.value))
cat(sprintf("ADF TLB diff: stat=%.4f  p=%.4f\n", adf_tlb_diff$statistic, adf_tlb_diff$p.value))
cat(sprintf("ADF TFR diff: stat=%.4f  p=%.4f\n", adf_tfr_diff$statistic, adf_tfr_diff$p.value))

cat("\n-- SARIMA Coefficients --\n")
cat("TLB SARIMA(1,1,0)(1,0,0)[12] coefficients:\n")
print(m_TBEST$coef)
cat("TFR SARIMA(1,1,0)(1,0,0)[12] coefficients:\n")
print(m_FBEST$coef)

cat("\nAll figures saved to plots/ directory.\n")
