# =============================================================================
# BASELINE ARIMA MODELS
# =============================================================================

library(tseries)
library(forecast)

options(stringsAsFactors = FALSE)
options(scipen = 999)
set.seed(42)
dir.create("methods", showWarnings = FALSE)

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

n_train    <- length(tlb_train)   # 53
n_test     <- length(tlb_test)    # 12
test_years <- 2013:2024
train_start <- 1995

# =============================================================================
# HELPER: fit a model, return diagnostics
# =============================================================================
fit_info <- function(model, label, log_scale = FALSE) {
  bl10 <- Box.test(residuals(model), lag = 10, type = "Ljung-Box")
  bl20 <- Box.test(residuals(model), lag = 20, type = "Ljung-Box")
  list(label   = label,
       aic     = round(AIC(model), 2),
       bic     = round(BIC(model), 2),
       bl10p   = round(bl10$p.value, 4),
       bl10q   = round(bl10$statistic, 3),
       bl20p   = round(bl20$p.value, 4),
       viable  = bl10$p.value > 0.05,
       log_scale = log_scale,
       model   = model)
}

safe_fit <- function(expr_call, label, log_scale = FALSE) {
  tryCatch(
    fit_info(eval(expr_call), label, log_scale),
    error = function(e) {
      cat("  FAILED:", label, "->", conditionMessage(e), "\n")
      NULL
    }
  )
}

print_row <- function(m) {
  if (is.null(m)) return()
  cat(sprintf("  %-42s  AIC=%8.2f  BIC=%8.2f  BL10 p=%.4f  BL20 p=%.4f  %s\n",
              m$label, m$aic, m$bic, m$bl10p, m$bl20p,
              ifelse(m$viable, "[VIABLE]", "[FAIL BL10]")))
}

# =============================================================================
# TFR CANDIDATE MODELS (ARIMA ONLY)
# =============================================================================
cat("\n", paste(rep("=",65),collapse=""),"\n")
cat("TFR CANDIDATE MODELS (ARIMA)\n")
cat(paste(rep("=",65),collapse=""),"\n\n")

tfr_cands <- list(
  safe_fit(quote(Arima(tfr_train, order=c(1,1,0))), "ARIMA(1,1,0)"),
  safe_fit(quote(Arima(tfr_train, order=c(2,1,0))), "ARIMA(2,1,0)"),
  safe_fit(quote(Arima(tfr_train, order=c(6,1,0))), "ARIMA(6,1,0)"),
  safe_fit(quote(Arima(tfr_train, order=c(1,1,1))), "ARIMA(1,1,1)"),
  safe_fit(quote(Arima(tfr_train, order=c(6,1,1))), "ARIMA(6,1,1)")
)
tfr_cands <- Filter(Negate(is.null), tfr_cands)
for (m in tfr_cands) print_row(m)

tfr_viable <- Filter(function(m) m$viable, tfr_cands)
tfr_best   <- tfr_viable[[which.min(sapply(tfr_viable, function(m) m$aic))]]
if(is.null(tfr_best)) tfr_best <- tfr_cands[[which.min(sapply(tfr_cands, function(m) m$aic))]]

# =============================================================================
# TLB CANDIDATE MODELS (ARIMA ONLY)
# =============================================================================
cat("\n", paste(rep("=",65),collapse=""),"\n")
cat("TLB CANDIDATE MODELS (ARIMA)\n")
cat(paste(rep("=",65),collapse=""),"\n\n")

tlb_cands <- list(
  safe_fit(quote(Arima(tlb_train, order=c(0,1,0))), "ARIMA(0,1,0)"),
  safe_fit(quote(Arima(tlb_train, order=c(1,1,0))), "ARIMA(1,1,0)"),
  safe_fit(quote(Arima(tlb_train, order=c(2,1,0))), "ARIMA(2,1,0)"),
  safe_fit(quote(Arima(tlb_train, order=c(6,1,0))), "ARIMA(6,1,0)"),
  safe_fit(quote(Arima(tlb_train, order=c(1,1,1))), "ARIMA(1,1,1)")
)
tlb_cands <- Filter(Negate(is.null), tlb_cands)
for (m in tlb_cands) print_row(m)

tlb_viable <- Filter(function(m) m$viable, tlb_cands)
tlb_best   <- tlb_viable[[which.min(sapply(tlb_viable, function(m) m$aic))]]
if(is.null(tlb_best)) tlb_best <- tlb_cands[[which.min(sapply(tlb_cands, function(m) m$aic))]]

# =============================================================================
# HELPER: forecast accuracy metrics
# =============================================================================
acc <- function(actual, fc) {
  e <- as.numeric(actual) - fc
  list(rmse = sqrt(mean(e^2)), mae = mean(abs(e)),
       mape = mean(abs(e / as.numeric(actual))) * 100, sse = sum(e^2))
}

# =============================================================================
# HELPER: 2x2 residual diagnostic panel
# =============================================================================
diag_panel <- function(resid_vec, start_yr, label, outfile) {
  resid_ts <- ts(resid_vec, start = start_yr, frequency = 1)
  png(outfile, width = 1100, height = 820, res = 150, bg = "white")
  par(mfrow = c(2, 2), mar = c(4, 5, 3.5, 2), oma = c(0, 0, 3, 0), bg = "white")
  plot(resid_ts, type = "l", lwd = 1.4, col = "black",
       main = "Residuals over Time", xlab = "Year", ylab = "Residual", las = 1)
  abline(h = 0, lty = 2, col = "gray50")
  hist(resid_vec, breaks = 14, freq = FALSE,
       main = "Histogram of Residuals", xlab = "Residual",
       col = "gray85", border = "white", las = 1)
  curve(dnorm(x, mean(resid_vec), sd(resid_vec)), col = "firebrick3", lwd = 2.2, add = TRUE)
  acf(resid_vec,  lag.max = 25, main = "ACF of Residuals (lag.max=25)",
      xlab = "Lag (years)", ylab = "ACF")
  pacf(resid_vec, lag.max = 25, main = "PACF of Residuals (lag.max=25)",
       xlab = "Lag (years)", ylab = "Partial ACF")
  mtext(label, side = 3, outer = TRUE, line = 1, cex = 0.88, font = 2)
  par(mfrow = c(1, 1))
  dev.off()
}

diag_panel(as.numeric(residuals(tfr_best$model)), 1961,
           paste0("ARIMA-Only Residuals  --  TFR: ", tfr_best$label,
                  "  [BL10 p=", tfr_best$bl10p, "  BL20 p=", tfr_best$bl20p, "]"),
           "methods/fig5a_arima_tfr.png")

diag_panel(as.numeric(residuals(tlb_best$model)), 1961,
           paste0("ARIMA-Only Residuals  --  TLB: ", tlb_best$label,
                  "  [BL10 p=", tlb_best$bl10p, "  BL20 p=", tlb_best$bl20p, "]"),
           "methods/fig5b_arima_tlb.png")

# =============================================================================
# FORECASTS
# =============================================================================
pred_tfr_a  <- forecast(tfr_best$model, h = n_test, level = c(80, 95))
pred_tlb_a  <- forecast(tlb_best$model, h = n_test, level = c(80, 95))
fc_tfr_a    <- as.numeric(pred_tfr_a$mean)
fc_tlb_a    <- as.numeric(pred_tlb_a$mean)
lo80_tfr_a  <- as.numeric(pred_tfr_a$lower[,1]); hi80_tfr_a <- as.numeric(pred_tfr_a$upper[,1])
lo95_tfr_a  <- as.numeric(pred_tfr_a$lower[,2]); hi95_tfr_a <- as.numeric(pred_tfr_a$upper[,2])
lo80_tlb_a  <- as.numeric(pred_tlb_a$lower[,1]); hi80_tlb_a <- as.numeric(pred_tlb_a$upper[,1])
lo95_tlb_a  <- as.numeric(pred_tlb_a$lower[,2]); hi95_tlb_a <- as.numeric(pred_tlb_a$upper[,2])
acc_tfr_a   <- acc(tfr_test, fc_tfr_a)
acc_tlb_a   <- acc(tlb_test, fc_tlb_a)

make_fc_plot <- function(ts_full, ts_test, fc, lo80, hi80, lo95, hi95,
                         ylab_txt, title_txt, outfile) {
  ylim_r <- range(c(as.numeric(window(ts_full, start=train_start)),
                    lo95, hi95)) * c(0.85, 1.06)
  png(outfile, width=1100, height=600, res=150, bg="white")
  par(mar=c(5,6,4,2), bg="white")
  plot(window(ts_full, start=train_start), type="l", lwd=2.5, col="black",
       xlim=c(train_start,2024), ylim=ylim_r,
       main=title_txt, xlab="Year", ylab=ylab_txt, las=1)
  abline(v=2012.5, lty=3, col="gray40", lwd=1.2)
  text(2012.5, ylim_r[2]*0.99, "Train | Test", col="gray40", cex=0.72, pos=2)
  polygon(c(test_years,rev(test_years)), c(lo95,rev(hi95)),
          col=rgb(0.7,0.7,0.7,0.35), border=NA)
  polygon(c(test_years,rev(test_years)), c(lo80,rev(hi80)),
          col=rgb(0.4,0.4,0.4,0.35), border=NA)
  lines(ts_test, lwd=2, col="steelblue4")
  lines(test_years, fc, lwd=2, col="firebrick3", lty=2)
  legend("topright", bty="n", cex=0.75,
         legend=c("Training","Actual","Forecast","80% PI","95% PI"),
         col=c("black","steelblue4","firebrick3",
               rgb(0.4,0.4,0.4,0.6),rgb(0.7,0.7,0.7,0.6)),
         lwd=c(2.5,2,2,8,8), lty=c(1,1,2,1,1))
  dev.off()
}

make_fc_plot(tfr_ts, tfr_test, fc_tfr_a, lo80_tfr_a, hi80_tfr_a, lo95_tfr_a, hi95_tfr_a,
             "TFR (children per woman)",
             paste0("TFR Forecast (ARIMA-only): ", tfr_best$label,
                    "  [MAPE=", round(acc_tfr_a$mape,2), "%]"),
             "methods/fig6a_arima_tfr.png")

make_fc_plot(tlb_ts, tlb_test, fc_tlb_a, lo80_tlb_a, hi80_tlb_a, lo95_tlb_a, hi95_tlb_a,
             "Total Live Births",
             paste0("TLB Forecast (ARIMA-only): ", tlb_best$label,
                    "  [MAPE=", round(acc_tlb_a$mape,2), "%]"),
             "methods/fig6b_arima_tlb.png")
