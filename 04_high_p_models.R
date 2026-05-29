# =============================================================================
# INITIAL -> IMPROVED MODELS (professor's plan) — Singapore TFR & TLB
#
# Plan:
#   TFR (log scale)
#     Initial : log-ARIMA(p,1,0), p in {13,14,15}  -> first that passes LB
#     Improved: log-SARIMA(p,1,0)(1,1,0)[12], p in {1,2} (d=1 & D=1 double diff)
#   TLB (original scale)
#     Initial : ARIMA(p,1,0), p in {13,14}
#     Improved: SARIMA(p,1,0)(1,1,0)[12], p in {1,2}
#
# Viability bar: residuals must PASS Box-Ljung (standard checkresiduals,
# forecast pkg) AND show NO residual-ACF spike outside +/-1.96/sqrt(n).
# Improvement judged by: AIC drop, residual whiteness, comparable test error.
# Train 1960-2012 (53 obs) | test 2013-2024 (12 obs).
# =============================================================================

suppressPackageStartupMessages({
  library(forecast)
  library(tseries)
})
options(stringsAsFactors = FALSE, scipen = 999)
set.seed(42)
dir.create("methods", showWarnings = FALSE)
rule <- function(s) cat("\n", strrep("=", 78), "\n", s, "\n", strrep("=", 78), "\n", sep = "")

# ---- DATA -------------------------------------------------------------------
data  <- read.csv("cleaned_tlb_tfr_1960_2024.csv")
train <- subset(data, Year <= 2012)
test  <- subset(data, Year >= 2013)

# frequency = 1 for the plain ARIMA initials; frequency = 12 for the SARIMA
# improved models (the 12-year Dragon-zodiac cycle treated as the "season").
tfr_t1  <- ts(train$TFR, start = 1960, frequency = 1)
tlb_t1  <- ts(train$TLB, start = 1960, frequency = 1)
tfr_s12 <- ts(train$TFR, start = 1960, frequency = 12)
tlb_s12 <- ts(train$TLB, start = 1960, frequency = 12)
tfr_test <- test$TFR; tlb_test <- test$TLB; test_years <- test$Year
cat("n_train =", nrow(train), " n_test =", nrow(test), "\n")

# ---- one fit + full diagnostic ---------------------------------------------
# Returns a row with AIC, the standard checkresiduals Box-Ljung (stat/df/p),
# the count of residual-ACF bars outside the band up to lag 24 and lag 36, and
# out-of-sample RMSE/MAE/MAPE on 2013-2024 (lambda back-transform automatic).
diagnose <- function(series, order, seasonal = c(0,0,0), lambda = NULL,
                     test, label, plot_tag = NULL) {
  fit <- Arima(series, order = order,
               seasonal = list(order = seasonal, period = 12),
               lambda = lambda, method = "ML")
  np  <- length(fit$coef)
  png(tempfile(fileext = ".png"))
  cr <- suppressWarnings(checkresiduals(fit, plot = FALSE)); dev.off()
  r  <- as.numeric(residuals(fit)); r <- r[is.finite(r)]
  n  <- length(r); ci <- 1.96 / sqrt(n)
  acf_v <- acf(r, lag.max = 36, plot = FALSE)$acf[, 1, 1][-1]
  cross24 <- which(abs(acf_v[1:24]) > ci)
  cross36 <- which(abs(acf_v)        > ci)
  fc  <- forecast(fit, h = length(test), biasadj = FALSE)
  e   <- as.numeric(test) - as.numeric(fc$mean)
  rmse <- sqrt(mean(e^2)); mae <- mean(abs(e)); mape <- mean(abs(e/as.numeric(test)))*100
  white <- (cr$p.value > 0.05) && (length(cross24) == 0)
  status <- if (white) "VIABLE (white)" else
            if (cr$p.value > 0.05) "LB-pass but ACF spike" else "LB-FAIL"
  cat(sprintf("  %-34s npar=%2d AIC=%9.2f  LB: Q*=%6.2f df=%2d p=%.4f  ACFx<=24={%s} <=36={%s}  RMSE=%9.3f MAE=%9.3f MAPE=%5.2f  %s\n",
              label, np, AIC(fit), unname(cr$statistic), cr$parameter, cr$p.value,
              paste(cross24, collapse = ","), paste(cross36, collapse = ","),
              rmse, mae, mape, status))
  if (!is.null(plot_tag)) {
    fn <- sprintf("methods/im_%s_resid.png", plot_tag)
    png(fn, width = 1000, height = 460, res = 110, bg = "white")
    par(mfrow = c(1, 2), mar = c(4, 4.5, 3.2, 1))
    acf(r,  lag.max = 36, main = paste("Residual ACF —", label))
    pacf(r, lag.max = 36, main = paste("Residual PACF —", label))
    dev.off()
  }
  invisible(list(fit = fit, label = label, np = np, aic = AIC(fit),
                 lb_stat = unname(cr$statistic), lb_df = cr$parameter, lb_p = cr$p.value,
                 cross24 = cross24, cross36 = cross36, white = white,
                 rmse = rmse, mae = mae, mape = mape, fc = fc))
}

coefs <- function(fit, label) {
  se <- sqrt(diag(fit$var.coef))
  cat("\n  ", label, " — coef / se / t:\n", sep = "")
  print(round(rbind(coef = coef(fit), se = se, t = coef(fit)/se), 3))
}

# =============================================================================
# STEP 0 — the one check that determines d in the improved model
#   Seasonally difference (lag 12) ONLY; if the result still trends, d=1 is
#   needed alongside D=1.  (ADF small p = stationary; KPSS small stat = stationary.)
# =============================================================================
rule("STEP 0 — does the seasonally-differenced series still need d=1?")
dcheck <- function(x, nm) {
  x <- x[is.finite(x)]
  a <- suppressWarnings(adf.test(x)); k <- suppressWarnings(kpss.test(x))
  cat(sprintf("  %-26s ADF p=%.4f (%s) | KPSS stat=%.4f (%s)\n", nm,
              a$p.value, ifelse(a$p.value < 0.05, "stationary", "NON-stationary"),
              unname(k$statistic), ifelse(k$statistic < 0.463, "stationary", "NON-stationary")))
}
sd_log_tfr <- diff(log(as.numeric(tfr_t1)), lag = 12)
sd_tlb     <- diff(as.numeric(tlb_t1),       lag = 12)
dcheck(sd_log_tfr, "seas-diff log(TFR)")
dcheck(sd_tlb,     "seas-diff TLB")
png("methods/im_step0_seasdiff.png", width = 1000, height = 420, res = 110, bg = "white")
par(mfrow = c(1, 2), mar = c(4, 4.5, 3, 1))
plot(sd_log_tfr, type = "l", lwd = 2, col = "firebrick3",
     main = "Seas-diff log(TFR)  (lag 12)", xlab = "index", ylab = ""); abline(h = 0, lty = 3)
plot(sd_tlb, type = "l", lwd = 2, col = "steelblue4",
     main = "Seas-diff TLB  (lag 12)", xlab = "index", ylab = ""); abline(h = 0, lty = 3)
dev.off()

# =============================================================================
# TFR — INITIAL : log-ARIMA(p,1,0)
# =============================================================================
rule("TFR INITIAL — log-ARIMA(p,1,0): test p=13 (expected fail), 14, 15")
tfr_i13 <- diagnose(tfr_t1, c(13,1,0), lambda = 0, test = tfr_test, label = "log-ARIMA(13,1,0)")
tfr_i14 <- diagnose(tfr_t1, c(14,1,0), lambda = 0, test = tfr_test, label = "log-ARIMA(14,1,0)", plot_tag = "tfr_init14")
tfr_i15 <- diagnose(tfr_t1, c(15,1,0), lambda = 0, test = tfr_test, label = "log-ARIMA(15,1,0)", plot_tag = "tfr_init15")

# =============================================================================
# TFR — IMPROVED : log-SARIMA(p,1,0)(1,1,0)[12]
# =============================================================================
rule("TFR IMPROVED — log-SARIMA(p,1,0)(1,1,0)[12]: test p=1, then 2")
tfr_m1 <- diagnose(tfr_s12, c(1,1,0), c(1,1,0), lambda = 0, test = tfr_test, label = "log-SARIMA(1,1,0)(1,1,0)[12]", plot_tag = "tfr_impr1")
tfr_m2 <- diagnose(tfr_s12, c(2,1,0), c(1,1,0), lambda = 0, test = tfr_test, label = "log-SARIMA(2,1,0)(1,1,0)[12]", plot_tag = "tfr_impr2")

# =============================================================================
# TLB — INITIAL : ARIMA(p,1,0)
# =============================================================================
rule("TLB INITIAL — ARIMA(p,1,0): test p=13 (borderline), 14")
tlb_i13 <- diagnose(tlb_t1, c(13,1,0), test = tlb_test, label = "ARIMA(13,1,0)", plot_tag = "tlb_init13")
tlb_i14 <- diagnose(tlb_t1, c(14,1,0), test = tlb_test, label = "ARIMA(14,1,0)", plot_tag = "tlb_init14")

# =============================================================================
# TLB — IMPROVED : SARIMA(p,1,0)(1,1,0)[12]
# =============================================================================
rule("TLB IMPROVED — SARIMA(p,1,0)(1,1,0)[12]: test p=1, then 2")
tlb_m1 <- diagnose(tlb_s12, c(1,1,0), c(1,1,0), test = tlb_test, label = "SARIMA(1,1,0)(1,1,0)[12]", plot_tag = "tlb_impr1")
tlb_m2 <- diagnose(tlb_s12, c(2,1,0), c(1,1,0), test = tlb_test, label = "SARIMA(2,1,0)(1,1,0)[12]", plot_tag = "tlb_impr2")

# =============================================================================
# SELECTION — first viable initial, first viable improved (per series)
# =============================================================================
rule("SELECTION — first model in each chain that is VIABLE (white)")
pick_first <- function(...) { for (m in list(...)) if (isTRUE(m$white)) return(m); NULL }
tfr_init <- pick_first(tfr_i13, tfr_i14, tfr_i15)
tfr_impr <- pick_first(tfr_m1,  tfr_m2)
tlb_init <- pick_first(tlb_i13, tlb_i14)
tlb_impr <- pick_first(tlb_m1,  tlb_m2)
say <- function(tag, m) cat(sprintf("  %-14s -> %s\n", tag, if (is.null(m)) "(none passed)" else m$label))
say("TFR initial",  tfr_init); say("TFR improved", tfr_impr)
say("TLB initial",  tlb_init); say("TLB improved", tlb_impr)

# =============================================================================
# FORECAST PLOTS for the four selected models
# =============================================================================
rule("FORECAST PLOTS -> methods/im_*_forecast.png")
fc_plot <- function(m, hist_years, hist_vals, ylab, fname, title) {
  if (is.null(m)) return(invisible())
  fc <- m$fc
  png(fname, width = 1000, height = 520, res = 110, bg = "white")
  par(mar = c(4, 4.5, 3.2, 1))
  yr_all <- c(hist_years, test_years)
  yl <- range(c(hist_vals, as.numeric(fc$lower[,2]), as.numeric(fc$upper[,2]),
                as.numeric(test_years*0)+ if (ylab=="TFR") tfr_test else tlb_test), na.rm = TRUE)
  plot(hist_years, as.numeric(hist_vals), type = "l", lwd = 2, xlim = range(yr_all),
       ylim = yl, xlab = "Year", ylab = ylab, main = title)
  polygon(c(test_years, rev(test_years)),
          c(as.numeric(fc$lower[,2]), rev(as.numeric(fc$upper[,2]))),
          col = adjustcolor("steelblue", 0.18), border = NA)
  lines(test_years, as.numeric(fc$mean), col = "red", lwd = 2, lty = 2)
  obs <- if (ylab == "TFR") tfr_test else tlb_test
  lines(test_years, obs, col = "blue", lwd = 2); points(test_years, obs, col = "blue", pch = 16, cex = 0.8)
  abline(v = 2012.5, lty = 3, col = "grey50")
  legend("topright", c("train", "forecast", "actual", "95% PI"),
         col = c("black","red","blue", adjustcolor("steelblue",0.5)),
         lwd = c(2,2,2,8), lty = c(1,2,1,1), bty = "n", cex = 0.85)
  dev.off(); cat("  wrote", fname, "\n")
}
fc_plot(tfr_init, train$Year, train$TFR, "TFR", "methods/im_tfr_initial_forecast.png", paste0("TFR initial — ", tfr_init$label))
fc_plot(tfr_impr, train$Year, train$TFR, "TFR", "methods/im_tfr_improved_forecast.png", paste0("TFR improved — ", tfr_impr$label))
fc_plot(tlb_init, train$Year, train$TLB, "TLB", "methods/im_tlb_initial_forecast.png", paste0("TLB initial — ", tlb_init$label))
fc_plot(tlb_impr, train$Year, train$TLB, "TLB", "methods/im_tlb_improved_forecast.png", paste0("TLB improved — ", tlb_impr$label))
