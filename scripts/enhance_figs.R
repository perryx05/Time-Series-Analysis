# =============================================================================
# Enhancements for final_report_enhanced.md:
#  (a) STL decomposition (trend + 12-year zodiac seasonal + remainder) for both
#      series — demonstrates "composition of time series methods".
#  (b) Residual diagnostics WITH a normal Q-Q panel + Shapiro-Wilk test, for the
#      two adopted final models, to validate the Gaussian prediction intervals.
# New figure files use the enh_ prefix so the ORIGINAL figures are untouched.
# =============================================================================
suppressPackageStartupMessages({ library(forecast) })
options(stringsAsFactors = FALSE, scipen = 999); set.seed(42)
dir.create("figures", showWarnings = FALSE)
data  <- read.csv("cleaned_tlb_tfr_1960_2024.csv")
yr_all <- data$Year                                  # 1960..2024
train <- subset(data, Year <= 2012)
tfr_s12 <- ts(train$TFR, start = 1960, frequency = 12)
tlb_s12 <- ts(train$TLB, start = 1960, frequency = 12)

# ---- (a) STL decomposition on the FULL series (period 12 = zodiac cycle) -----
# log(TFR) (modelled on the log scale) and TLB (original scale). Components are
# extracted as plain vectors and plotted against calendar years to keep the axis
# correct (a frequency=12 ts otherwise mislabels the x-axis 1960-1965).
dec <- function(values) {
  s <- stl(ts(values, frequency = 12), s.window = "periodic")$time.series
  list(trend = as.numeric(s[, "trend"]),
       seas  = as.numeric(s[, "seasonal"]),
       rem   = as.numeric(s[, "remainder"]),
       obs   = as.numeric(values))
}
dt <- dec(log(data$TFR)); db <- dec(data$TLB)

png("figures/enh_decomp.png", width = 1180, height = 980, res = 120, bg = "white")
par(mfrow = c(4, 2), mar = c(2.6, 4.4, 2.2, 1), oma = c(2, 0, 2.4, 0))
panel <- function(y, ylab, main = NULL, col = "grey20") {
  plot(yr_all, y, type = "l", lwd = 1.6, col = col, xlab = "", ylab = ylab, main = main)
  abline(v = 2012.5, lty = 3, col = "grey60")
}
panel(dt$obs, "log(TFR)",  "log(TFR)");           panel(db$obs, "TLB",       "TLB")
panel(dt$trend, "Trend", col = "firebrick3");     panel(db$trend, "Trend", col = "firebrick3")
panel(dt$seas, "Seasonal\n(12-yr)", col = "steelblue4"); panel(db$seas, "Seasonal\n(12-yr)", col = "steelblue4")
panel(dt$rem, "Remainder", col = "grey45");       panel(db$rem, "Remainder", col = "grey45")
mtext("STL decomposition (period = 12-year zodiac cycle), 1960-2024", outer = TRUE, cex = 0.95, font = 2)
mtext("Year", side = 1, outer = TRUE, line = 0.6, cex = 0.8)
dev.off(); cat("wrote figures/enh_decomp.png\n")
cat(sprintf("  seasonal amplitude: log(TFR) range = %.3f (=%.1f%% on TFR); TLB range = %.0f births\n",
            diff(range(dt$seas)), (exp(diff(range(dt$seas)))-1)*100, diff(range(db$seas))))

# ---- (b) residual diagnostics with Q-Q + Shapiro-Wilk -----------------------
fit_tfr <- Arima(tfr_s12, c(4,1,0), list(order=c(1,1,0),period=12), lambda=0, method="ML")
fit_tlb <- Arima(tlb_s12, c(4,1,0), list(order=c(1,1,0),period=12),           method="ML")

resid_qq <- function(fit, lab, fname) {
  r  <- as.numeric(residuals(fit)); rt <- ts(r, start = 1960, frequency = 1)
  rg <- r[14:length(r)]                      # drop the 13 differencing-burn-in residuals
  sw <- shapiro.test(rg)                     # normality on the 40 genuine residuals
  png(fname, width = 1020, height = 760, res = 118, bg = "white")
  par(mfrow = c(2, 2), mar = c(4, 4.4, 3, 1))
  plot(rt, type = "l", lwd = 1.3, col = "grey25", main = paste("Residuals -", lab),
       xlab = "Year", ylab = "Residual"); abline(h = 0, lty = 2, col = "grey55")
  acf(r, lag.max = 24, main = "Residual ACF")
  hist(rg, breaks = 10, prob = TRUE, col = "grey85", border = "white",
       main = "Histogram + normal (post burn-in)", xlab = "Residual")
  curve(dnorm(x, mean(rg), sd(rg)), add = TRUE, col = "firebrick3", lwd = 2)
  qqnorm(rg, main = sprintf("Normal Q-Q (Shapiro-Wilk p = %.2f)", sw$p.value), pch = 1, cex = 0.8)
  qqline(rg, col = "firebrick3", lwd = 2)
  dev.off()
  cat(sprintf("wrote %s  (post-burn-in Shapiro-Wilk W = %.3f, p = %.3f)\n", fname, sw$statistic, sw$p.value))
  invisible(sw)
}
resid_qq(fit_tfr, "log-SARIMA(4,1,0)(1,1,0)[12]", "figures/enh_resid_tfr.png")
resid_qq(fit_tlb, "SARIMA(4,1,0)(1,1,0)[12]",     "figures/enh_resid_tlb.png")
