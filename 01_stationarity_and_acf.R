# =============================================================================
# STATIONARITY AND INITIAL ACF/PACF (Lag 25)
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

log_tlb_train <- log(tlb_train)
log_tfr_train <- log(tfr_train)
log_tlb_test  <- log(tlb_test)
log_tfr_test  <- log(tfr_test)

n_train    <- length(tlb_train)   # 53
n_test     <- length(tlb_test)    # 12
test_years <- 2013:2024

tlb_diff1     <- diff(tlb_train)
tfr_diff1     <- diff(tfr_train)
log_tlb_diff1 <- diff(log_tlb_train)
log_tfr_diff1 <- diff(log_tfr_train)

ci_band    <- 1.96 / sqrt(length(tlb_diff1))   # 0.2718
train_start <- 1995

# =============================================================================
# FIG 1: Raw TFR — policy annotations
# =============================================================================
png("methods/fig1_tfr_raw.png", width = 1100, height = 600, res = 150, bg = "white")
par(mar = c(5, 6, 4, 2), bg = "white")

plot(tfr_train, type = "l", lwd = 2.5, col = "black",
     xlim = c(1960, 2024), ylim = c(0.5, 7.2),
     main = "Figure 1: Singapore Total Fertility Rate (1960-2024)\nWith policy events",
     xlab = "Year", ylab = "Total Fertility Rate (children per woman)", las = 1)
lines(tfr_test, lwd = 2, col = "gray45", lty = 2)

# Replacement level
abline(h = 2.1, lty = 2, col = "firebrick3", lwd = 1.6)
# Train/test split
abline(v = 2013, lty = 3, col = "gray30", lwd = 1.5)

# Policy events
abline(v = 1966, lty = 1, col = "steelblue4", lwd = 1.2)
abline(v = 1987, lty = 1, col = "purple4",    lwd = 1.2)

text(1966, 6.9,  "1966\nFam. Planning", col = "steelblue4",  cex = 0.58, adj = c(0, 0.5))
text(1987, 6.9,  "1987\n'Have 3+'",     col = "purple4",     cex = 0.58, adj = c(0, 0.5))
text(2013, 0.72, "Train | Test",        col = "gray30",      cex = 0.70, pos = 4)
text(1970, 2.35, "Replacement (2.1)",   col = "firebrick3",  cex = 0.70, pos = 4)

legend("topright", bty = "n", cex = 0.72,
       legend = c("Training TFR (1960-2012)", "Test TFR (2013-2024)",
                  "Replacement level (2.1)", "Policy event"),
       col = c("black", "gray45", "firebrick3", "steelblue4"),
       lwd = c(2.5, 2, 1.6, 1.2),
       lty = c(1, 2, 2, 1))
dev.off()

# =============================================================================
# FIG 2a/2b: ACF/PACF of RAW series (lag.max=20)
# =============================================================================
png("methods/fig2a_acf_pacf_tfr_raw.png", width = 1050, height = 560, res = 150, bg = "white")
par(mfrow = c(1, 2), mar = c(4, 5, 3, 1), oma = c(0, 0, 3, 0), bg = "white")
acf(tfr_train,  lag.max = 20, main = "ACF",
    xlab = "Lag (years)", ylab = "ACF", ylim = c(-0.4, 1))
pacf(tfr_train, lag.max = 20, main = "PACF",
     xlab = "Lag (years)", ylab = "Partial ACF", ylim = c(-0.5, 1))
mtext("Figure 2a: ACF and PACF  --  TFR raw series (Training 1960-2012, lag.max = 20)",
      side = 3, outer = TRUE, line = 1, cex = 0.92, font = 2)
par(mfrow = c(1, 1))
dev.off()

png("methods/fig2b_acf_pacf_tlb_raw.png", width = 1050, height = 560, res = 150, bg = "white")
par(mfrow = c(1, 2), mar = c(4, 5, 3, 1), oma = c(0, 0, 3, 0), bg = "white")
acf(tlb_train,  lag.max = 20, main = "ACF",
    xlab = "Lag (years)", ylab = "ACF", ylim = c(-0.4, 1))
pacf(tlb_train, lag.max = 20, main = "PACF",
     xlab = "Lag (years)", ylab = "Partial ACF", ylim = c(-0.5, 1))
mtext("Figure 2b: ACF and PACF  --  TLB raw series (Training 1960-2012, lag.max = 20)",
      side = 3, outer = TRUE, line = 1, cex = 0.92, font = 2)
par(mfrow = c(1, 1))
dev.off()

# =============================================================================
# FIG 3: First-differenced series — fixed axes
# =============================================================================
tlb_diff_yr <- as.integer(time(tlb_diff1))
tfr_diff_yr <- as.integer(time(tfr_diff1))

png("methods/fig3_diff_series.png", width = 1100, height = 750, res = 150, bg = "white")
par(mfrow = c(2, 1), mar = c(2, 7.5, 3.5, 2), oma = c(3, 0, 0, 0), bg = "white")

# Top: TLB differences
plot(tlb_diff1, type = "l", lwd = 1.6, col = "black",
     main = "Figure 3 (top): First-Differenced TLB  [ylim fixed: -10,000 to +10,000]",
     xlab = "", ylab = "Delta TLB (births/year)",
     ylim = c(-10000, 10000), las = 1)
abline(h = 0, col = "gray55", lwd = 1.2)
v87 <- tlb_diff1[tlb_diff_yr == 1987]; v88 <- tlb_diff1[tlb_diff_yr == 1988]
v03 <- tlb_diff1[tlb_diff_yr == 2003]
text(1987, v87 + 700, paste0("1987: +", round(v87)), cex = 0.64, col = "purple4", pos = 2)
text(1988, v88 + 700, paste0("1988: +", round(v88)), cex = 0.64, col = "black", pos = 4)
text(2003, v03 - 500, paste0("2003: ", round(v03)), cex = 0.64, col = "steelblue4", pos = 2)

# Bottom: TFR differences
plot(tfr_diff1, type = "l", lwd = 1.6, col = "black",
     main = "Figure 3 (bottom): First-Differenced TFR  [ylim fixed: -0.6 to +0.6]",
     xlab = "", ylab = "Delta TFR (per woman/year)",
     ylim = c(-0.6, 0.6), las = 1)
abline(h = 0, col = "gray55", lwd = 1.2)
v67 <- tfr_diff1[tfr_diff_yr == 1967]; v88t <- tfr_diff1[tfr_diff_yr == 1988]
text(1967, v67 - 0.04, paste0("1967: ", round(v67,2)), cex=0.64, col="steelblue4", pos=2)
text(1988, v88t + 0.04, paste0("1988: +", round(v88t,2)), cex=0.64, col="black", pos=4)

par(mfrow = c(1, 1))
dev.off()

# =============================================================================
# FIG 4a/4b: ACF/PACF of differenced series — lag.max = 25
# =============================================================================
make_acf_pacf_plot <- function(series, outer_title, outfile) {
  png(outfile, width = 1100, height = 580, res = 150, bg = "white")
  par(mfrow = c(1, 2), mar = c(4, 5, 3, 1), oma = c(0, 0, 3, 0), bg = "white")
  acf(series,  lag.max = 25, main = "ACF",
      xlab = "Lag (years)", ylab = "ACF", ylim = c(-0.55, 1))
  pacf(series, lag.max = 25, main = "PACF",
       xlab = "Lag (years)", ylab = "Partial ACF", ylim = c(-0.55, 0.55))
  mtext(outer_title, side = 3, outer = TRUE, line = 1, cex = 0.90, font = 2)
  par(mfrow = c(1, 1))
  dev.off()
}

make_acf_pacf_plot(tfr_diff1,
  "Figure 4a: ACF and PACF  --  First-Differenced TFR (Training 1961-2012, lag.max = 25)",
  "methods/fig4a_acf_pacf_diff_tfr.png")

make_acf_pacf_plot(tlb_diff1,
  "Figure 4b: ACF and PACF  --  First-Differenced TLB (Training 1961-2012, lag.max = 25)",
  "methods/fig4b_acf_pacf_diff_tlb.png")

# =============================================================================
# TABLE 1: ADF + KPSS tests
# =============================================================================
run_tests <- function(x, label) {
  adf  <- adf.test(x,  alternative = "stationary")
  kpss <- kpss.test(x, null = "Level")
  stat <- if (adf$p.value < 0.05 && kpss$p.value > 0.05) "Stationary"
          else if (adf$p.value >= 0.05 && kpss$p.value <= 0.05) "Non-stationary"
          else "Conflicting/borderline"
  cat(sprintf("  %-32s  ADF p=%.4f  KPSS stat=%.4f p=%.4f  => %s\n",
              label, adf$p.value, kpss$statistic, kpss$p.value, stat))
  list(label=label,
       adf_stat=round(adf$statistic,4), adf_p=round(adf$p.value,4),
       kpss_stat=round(kpss$statistic,4), kpss_p=round(kpss$p.value,4),
       conclusion=stat)
}

t1_tfr_raw      <- run_tests(tfr_train,     "TFR raw (1960-2012)")
t1_tlb_raw      <- run_tests(tlb_train,     "TLB raw (1960-2012)")
t1_dtfr         <- run_tests(tfr_diff1,     "d(TFR) (1961-2012)")
t1_dtlb         <- run_tests(tlb_diff1,     "d(TLB) (1961-2012)")
t1_log_tfr_raw  <- run_tests(log_tfr_train, "log(TFR) raw")
t1_log_tlb_raw  <- run_tests(log_tlb_train, "log(TLB) raw")
t1_dlog_tfr     <- run_tests(log_tfr_diff1, "d(log(TFR))")
t1_dlog_tlb     <- run_tests(log_tlb_diff1, "d(log(TLB))")
