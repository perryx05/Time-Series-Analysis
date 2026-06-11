# =============================================================================
# Fixes for review issues:
#  (1) Regenerate Figs 4 & 5 (residual diagnostics) with the residual time-series
#      x-axis spanning 1960-2012 (not 1960-1964). Models are fit on a frequency=12
#      ts for the period-12 seasonality, so residuals(fit) carries frequency 12;
#      we coerce to an annual (frequency=1) ts starting 1960 for the time plot.
#  (2) Test-set MSE / MAE / MAPE for ALL FOUR models (initials + finals), on the
#      back-transformed (original) scale, to fill the new Table 2 / Table 3 columns.
#  (4) Verify the lag-4 PACF of the DOUBLY-differenced series for both series.
# Train 1960-2012 | test 2013-2024.  LB stats unchanged (still the freq=12 fits).
# =============================================================================
suppressPackageStartupMessages({ library(forecast) })
options(stringsAsFactors = FALSE, scipen = 999)
data  <- read.csv("cleaned_tlb_tfr_1960_2024.csv")
train <- subset(data, Year <= 2012); test <- subset(data, Year >= 2013)
tfr_s12 <- ts(train$TFR, start = 1960, frequency = 12)
tlb_s12 <- ts(train$TLB, start = 1960, frequency = 12)
tfr_test <- test$TFR; tlb_test <- test$TLB

fit <- function(series, p, seas, lambda)
  Arima(series, order = c(p,1,0), seasonal = list(order = seas, period = 12),
        lambda = lambda, method = "ML")

tfr_init <- fit(tfr_s12, 12, c(1,1,0), 0)
tfr_fin  <- fit(tfr_s12,  4, c(1,1,0), 0)
tlb_init <- fit(tlb_s12, 13, c(1,1,0), NULL)
tlb_fin  <- fit(tlb_s12,  4, c(1,1,0), NULL)

# ---- (2) test errors (back-transformed/original scale, as in Table 4) -------
errs <- function(f, actual, lab) {
  fc <- forecast(f, h = length(actual), biasadj = FALSE)
  e  <- as.numeric(actual) - as.numeric(fc$mean)
  cat(sprintf("%-40s  MSE=%.6g  MAE=%.6g  MAPE=%.3f\n",
              lab, mean(e^2), mean(abs(e)), mean(abs(e/as.numeric(actual)))*100))
}
cat("==== test-set errors (original scale) ====\n")
errs(tfr_init, tfr_test, "TFR initial SARIMA(12,1,0)(1,1,0)[12]")
errs(tfr_fin,  tfr_test, "TFR final   SARIMA(4,1,0)(1,1,0)[12]")
errs(tlb_init, tlb_test, "TLB initial SARIMA(13,1,0)(1,1,0)[12]")
errs(tlb_fin,  tlb_test, "TLB final   SARIMA(4,1,0)(1,1,0)[12]")

# ---- (4) lag-4 PACF of the doubly-differenced series ------------------------
cat("\n==== PACF at lag 4 of (1-B)(1-B^12) X ====\n")
dd_tfr <- diff(diff(log(as.numeric(train$TFR))), lag = 12)
dd_tlb <- diff(diff(as.numeric(train$TLB)),       lag = 12)
cat(sprintf("  TFR (log): pacf[4] = %.3f\n", pacf(dd_tfr, plot=FALSE)$acf[4]))
cat(sprintf("  TLB:       pacf[4] = %.3f\n", pacf(dd_tlb, plot=FALSE)$acf[4]))

# ---- (1) residual-diagnostic figures with correct annual x-axis -------------
resid_fig <- function(f, lab, fname) {
  r  <- as.numeric(residuals(f))
  rt <- ts(r, start = 1960, frequency = 1)           # annual axis 1960-2012
  png(fname, width = 1000, height = 720, res = 120, bg = "white")
  layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
  par(mar = c(4, 4.5, 3, 1))
  plot(rt, type = "l", lwd = 1.4, col = "grey25",
       main = paste("Residuals —", lab), xlab = "Year", ylab = "Residual")
  abline(h = 0, lty = 2, col = "grey55")
  acf(r, lag.max = 24, main = "Residual ACF")
  hist(r, breaks = 12, prob = TRUE, col = "grey85", border = "white",
       main = "Histogram of residuals", xlab = "Residual")
  curve(dnorm(x, mean(r), sd(r)), add = TRUE, col = "firebrick3", lwd = 2)
  dev.off(); cat("wrote", fname, "\n")
}
cat("\n")
resid_fig(tfr_fin, "log-SARIMA(4,1,0)(1,1,0)[12]", "plots/fr2_fig4_resid_tfr.png")
resid_fig(tlb_fin, "SARIMA(4,1,0)(1,1,0)[12]",     "plots/fr2_fig5_resid_tlb.png")
