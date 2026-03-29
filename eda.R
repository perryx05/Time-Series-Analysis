# =============================================================================
# EDA: Singapore Total Live Births (TLB) and Total Fertility Rate (TFR)
# Period: 1960 to 2024
# =============================================================================

# =============================================================================
# SECTION 0: Set up and load packages
# =============================================================================

# Base R workflow: Sections 0–6 only (data → visuals → MA → ACF/PACF → differencing → ADF).
# install.packages("tseries") once if needed for adf.test.
# library(tseries)

options(stringsAsFactors = FALSE)
options(scipen = 999)
par(mar = c(5, 5, 4, 2))

data_file <- "M810091.csv"

# Helper: clean numeric strings from SingStat export
safe_num <- function(x) {
  x <- gsub(",", "", trimws(x), fixed = TRUE)
  x[x %in% c("", "na", "NA", "-", "nil")] <- NA
  as.numeric(x)
}

# =============================================================================
# SECTION 1: Data loading and Inspection
# =============================================================================
# 1.1 Load raw file
raw_lines <- readLines(data_file, warn = FALSE)

# 1.2 Extract rows needed for this project
header_line <- raw_lines[grepl("^Data Series,", raw_lines)]
tfr_line <- raw_lines[grepl("^Total Fertility Rate \\(TFR\\) \\(Per Female\\),", raw_lines)]
tlb_line <- raw_lines[grepl("^Total Live-Births \\(Number\\),", raw_lines)]

if (length(header_line) != 1 || length(tfr_line) != 1 || length(tlb_line) != 1) {
  stop("Could not locate required rows in M810091.csv. Check source format.")
}

# 1.3 Parse into vectors
header_vals <- strsplit(header_line, ",", fixed = TRUE)[[1]]
tfr_vals <- strsplit(tfr_line, ",", fixed = TRUE)[[1]]
tlb_vals <- strsplit(tlb_line, ",", fixed = TRUE)[[1]]

years_desc <- safe_num(header_vals[-1])
tfr_desc <- safe_num(tfr_vals[-1])
tlb_desc <- safe_num(tlb_vals[-1])

# 1.4 Order years ascending (file is exported in descending order)
# Dataset is already pre-filtered to 1960-2024 by download settings.
if (any(is.na(years_desc))) {
  stop("Year columns could not be parsed correctly.")
}

ord <- order(years_desc)
eda_df <- data.frame(
  Year = years_desc[ord],
  TLB = tlb_desc[ord],
  TFR = tfr_desc[ord]
)
# 1.5 Basic inspection 
head(eda_df)
tail(eda_df)
str(eda_df)
summary(eda_df)
dim(eda_df)
names(eda_df)

# 1.6 Quick checks used in report write-up
year_range <- range(eda_df$Year, na.rm = TRUE)
n_obs <- nrow(eda_df)
tlb_range <- range(eda_df$TLB, na.rm = TRUE)
tfr_range <- range(eda_df$TFR, na.rm = TRUE)
missing_counts <- colSums(is.na(eda_df))

# Save cleaned core dataset for later sections
write.csv(eda_df, "cleaned_tlb_tfr_1960_2024.csv", row.names = FALSE)


# =============================================================================
# SECTION 2: Data Cleaning
# =============================================================================

# 2.1 Check column names and basic structure
required_cols <- c("Year", "TLB", "TFR")
missing_cols <- setdiff(required_cols, names(eda_df))
if (length(missing_cols) > 0) {
  stop(paste0("Missing required column(s): ", paste(missing_cols, collapse = ", ")))
}

# 2.2 Ensure correct types (coerce only if needed)
# Year should be integer-like (1960..2024)
if (!is.numeric(eda_df$Year)) eda_df$Year <- safe_num(eda_df$Year)
eda_df$Year <- as.integer(eda_df$Year)

# TLB should be numeric counts
if (!is.numeric(eda_df$TLB)) eda_df$TLB <- safe_num(eda_df$TLB)

# TFR should be numeric rate
if (!is.numeric(eda_df$TFR)) eda_df$TFR <- safe_num(eda_df$TFR)

# 2.3 Basic validation checks
if (anyNA(eda_df$Year)) stop("Year contains missing values after parsing.")

# one row per year
if (length(unique(eda_df$Year)) != nrow(eda_df)) {
  stop("Year values are not unique (expected one row per year).")
}

if (min(eda_df$Year) != 1960 || max(eda_df$Year) != 2024) {
  stop("Unexpected year range (expected 1960 to 2024).")
}

if (nrow(eda_df) != 65) {
  stop("Unexpected number of rows (expected 65 yearly observations).")
}

# TLB: positive whole-number counts (allow numeric storage)
if (anyNA(eda_df$TLB) || any(eda_df$TLB <= 0)) {
  stop("TLB contains missing or non-positive values.")
}

# TFR: positive rate
if (anyNA(eda_df$TFR) || any(eda_df$TFR <= 0)) {
  stop("TFR contains missing or non-positive values.")
}

# 2.4 Missing values check (resolve only if present)
# In this dataset we expect none; stop early if any exist so we don't silently proceed.
if (anyNA(eda_df$TLB) || anyNA(eda_df$TFR)) {
  stop("Missing values detected in TLB/TFR. Handle missing data before modelling.")
}

# 2.5 Create time series objects (annual, frequency = 1)
tlb_ts <- ts(eda_df$TLB, start = 1960, frequency = 1)
tfr_ts <- ts(eda_df$TFR, start = 1960, frequency = 1)

# 2.6 Training/test split (as required by rubric)
tlb_train <- window(tlb_ts, start = 1960, end = 2012)
tlb_test <- window(tlb_ts, start = 2013, end = 2024)

tfr_train <- window(tfr_ts, start = 1960, end = 2012)
tfr_test <- window(tfr_ts, start = 2013, end = 2024)

# Optional: save the (possibly type-normalised) cleaned table
write.csv(eda_df, "cleaned_tlb_tfr_1960_2024.csv", row.names = FALSE)


# =============================================================================
# SECTION 3: Visualisation
# =============================================================================

# Keep all figures in one folder
dir.create("plots", showWarnings = FALSE)

# 3.1 First look at both series (practical-style exploratory panel)
png("plots/00_overview_panel.png", width = 900, height = 650, res = 120)
par(mfrow = c(2, 1))
plot(tlb_ts, type = "l", lwd = 2,
     main = "Total Live Births (1960-2024)",
     xlab = "Year", ylab = "Births")
plot(tfr_ts, type = "l", lwd = 2,
     main = "Total Fertility Rate (1960-2024)",
     xlab = "Year", ylab = "Children per woman")
par(mfrow = c(1, 1))
dev.off()

# 3.2 TLB over full period (1960-2024)
png("plots/01_tlb_full.png", width = 900, height = 500, res = 120)
plot(tlb_ts, type = "l", lwd = 2,
     main = "Singapore Total Live Births (1960-2024)",
     xlab = "Year", ylab = "Number of live births")

# draw a few reference years to guide interpretation
abline(v = c(1965, 1987, 2013, 2020), lty = 3, col = "gray60")
dev.off()

# 3.3 TFR over full period (1960-2024)
png("plots/02_tfr_full.png", width = 900, height = 500, res = 120)
plot(tfr_ts, type = "l", lwd = 2,
     main = "Singapore Total Fertility Rate (1960-2024)",
     xlab = "Year", ylab = "Children per woman")
abline(h = 2.1, lty = 2, col = "gray40")
# Label above the line on the right: after ~1975 TFR is below 2.1, so this band is clear
text(2005, 2.38, "Replacement level = 2.1", cex = 0.85, adj = c(0.5, 0))
dev.off()

# 3.4 Combined view (same panel, separate axes)
png("plots/03_tlb_tfr_combined.png", width = 900, height = 500, res = 120)
par(mar = c(5, 5, 4, 5))
plot(tlb_ts, type = "l", lwd = 2, col = "black",
     main = "TLB and TFR (1960-2024)",
     xlab = "Year", ylab = "TLB (left axis)")
par(new = TRUE)
plot(tfr_ts, type = "l", lwd = 2, lty = 2, col = "black",
     axes = FALSE, xlab = "", ylab = "")
axis(side = 4)
mtext("TFR (right axis)", side = 4, line = 3)
legend("topright", bty = "n",
       legend = c("TLB", "TFR"),
       lwd = c(2, 2), lty = c(1, 2), col = "black")
par(mar = c(5, 5, 4, 2))
dev.off()

# 3.5 Train/test split for TLB
png("plots/04_tlb_train_test_split.png", width = 900, height = 500, res = 120)
plot(tlb_train, type = "l", lwd = 2,
     main = "TLB: Training and Test Split",
     xlab = "Year", ylab = "Number of live births",
     xlim = c(1960, 2024))
lines(tlb_test, lwd = 2, lty = 2)
abline(v = 2013, lty = 3, col = "gray40")
legend("topright", bty = "n",
       legend = c("Training 1960-2012", "Test 2013-2024"),
       lwd = 2, lty = c(1, 2), col = "black")
dev.off()

# 3.6 Train/test split for TFR
png("plots/05_tfr_train_test_split.png", width = 900, height = 500, res = 120)
plot(tfr_train, type = "l", lwd = 2,
     main = "TFR: Training and Test Split",
     xlab = "Year", ylab = "Children per woman",
     xlim = c(1960, 2024))
lines(tfr_test, lwd = 2, lty = 2)
abline(v = 2013, lty = 3, col = "gray40")
legend("topright", bty = "n",
       legend = c("Training 1960-2012", "Test 2013-2024"),
       lwd = 2, lty = c(1, 2), col = "black")
dev.off()


# =============================================================================
# SECTION 4: Trend smoothing (decomposition-style, annual data)
# =============================================================================
# Dataset: annual TLB and TFR, frequency = 1. There is no within-year seasonal
# structure, so STL / classical seasonal decomposition (which need a seasonal
# period) is not the right tool. We use a centred moving average to approximate
# a smooth trend; the gap between observed and MA is informal "irregular"
# variation (policy shocks, noise). Window length (5 years) is explained in the
# EDA report — not replicated as a multi-line comparison plot here.

ma5_tlb <- stats::filter(tlb_ts, rep(1 / 5, 5), sides = 2)
ma5_tfr <- stats::filter(tfr_ts, rep(1 / 5, 5), sides = 2)

png("plots/06_tlb_ma_trend.png", width = 900, height = 500, res = 120)
plot(tlb_ts, type = "l", lwd = 1.5, col = "gray50",
     main = "TLB with 5-year centred moving average (smooth trend)",
     xlab = "Year", ylab = "Number of live births")
lines(ma5_tlb, lwd = 2.5, col = "black")
legend("topright", bty = "n",
       legend = c("Observed", "5-year MA (trend)"),
       col = c("gray50", "black"), lwd = c(1.5, 2.5))
dev.off()

png("plots/07_tfr_ma_trend.png", width = 900, height = 500, res = 120)
plot(tfr_ts, type = "l", lwd = 1.5, col = "gray50",
     main = "TFR with 5-year centred moving average (smooth trend)",
     xlab = "Year", ylab = "Children per woman")
lines(ma5_tfr, lwd = 2.5, col = "black")
legend("topright", bty = "n",
       legend = c("Observed", "5-year MA (trend)"),
       col = c("gray50", "black"), lwd = c(1.5, 2.5))
dev.off()


# =============================================================================
# SECTION 5: ACF, PACF, and first differencing (training data only)
# =============================================================================

# 5.1 ACF and PACF: raw training series
png("plots/08_tlb_acf_pacf_raw.png", width = 900, height = 450, res = 120)
par(mfrow = c(1, 2))
acf(tlb_train, main = "ACF: TLB (1960-2012, raw)", lag.max = 20)
pacf(tlb_train, main = "PACF: TLB (1960-2012, raw)", lag.max = 20)
par(mfrow = c(1, 1))
dev.off()

png("plots/09_tfr_acf_pacf_raw.png", width = 900, height = 450, res = 120)
par(mfrow = c(1, 2))
acf(tfr_train, main = "ACF: TFR (1960-2012, raw)", lag.max = 20)
pacf(tfr_train, main = "PACF: TFR (1960-2012, raw)", lag.max = 20)
par(mfrow = c(1, 1))
dev.off()

# 5.2 First differences (d = 1): annual change in TLB and TFR
tlb_diff1 <- diff(tlb_train, differences = 1)
tfr_diff1 <- diff(tfr_train, differences = 1)

png("plots/10_differenced_series.png", width = 900, height = 500, res = 120)
par(mfrow = c(2, 1))
plot(tlb_diff1, type = "l", lwd = 1.5, col = "black",
     main = "First-differenced TLB (1961-2012)",
     xlab = "Year", ylab = expression(Delta ~ "TLB"))
abline(h = 0, lty = 2, col = "gray50")
plot(tfr_diff1, type = "l", lwd = 1.5, col = "black",
     main = "First-differenced TFR (1961-2012)",
     xlab = "Year", ylab = expression(Delta ~ "TFR"))
abline(h = 0, lty = 2, col = "gray50")
par(mfrow = c(1, 1))
dev.off()

# 5.3 ACF and PACF: first-differenced series 
png("plots/11_tlb_acf_pacf_diff.png", width = 900, height = 450, res = 120)
par(mfrow = c(1, 2))
acf(tlb_diff1, main = "ACF: first-differenced TLB", lag.max = 20)
pacf(tlb_diff1, main = "PACF: first-differenced TLB", lag.max = 20)
par(mfrow = c(1, 1))
dev.off()

png("plots/12_tfr_acf_pacf_diff.png", width = 900, height = 450, res = 120)
par(mfrow = c(1, 2))
acf(tfr_diff1, main = "ACF: first-differenced TFR", lag.max = 20)
pacf(tfr_diff1, main = "PACF: first-differenced TFR", lag.max = 20)
par(mfrow = c(1, 1))
dev.off()


# =============================================================================
# SECTION 6: Stationarity tests (ADF only)
# =============================================================================
# Augmented Dickey-Fuller: H0 = unit root. Package: tseries.

if (!requireNamespace("tseries", quietly = TRUE)) {
  stop("Install package tseries for ADF, e.g. install.packages(\"tseries\")")
}
library(tseries)

cat("\n=== ADF (H0: unit root) — TLB raw (1960-2012) ===\n")
print(adf.test(tlb_train, alternative = "stationary"))

cat("\n=== ADF — TFR raw (1960-2012) ===\n")
print(adf.test(tfr_train, alternative = "stationary"))

cat("\n=== ADF — first-differenced TLB ===\n")
print(adf.test(tlb_diff1, alternative = "stationary"))

cat("\n=== ADF — first-differenced TFR ===\n")
print(adf.test(tfr_diff1, alternative = "stationary"))


# =============================================================================
# SECTION 7: Preliminary model identification (training: 1960-2012)
# =============================================================================
# Course scope: we do not use KPSS and we do not cover ARIMA yet.
# We fit simple AR / MA / ARMA models on the first-differenced series.
#
# NOTE: these are preliminary candidates for the Final Report. No forecasts here.

# --- 7.1 TLB candidate on first differences ---
# ACF/PACF on tlb_diff1 show weak short-lag structure, so a parsimonious baseline
# is white noise for annual changes: ARMA(0,0).
tlb_arma00 <- stats::arima(tlb_diff1, order = c(0, 0, 0), method = "ML")

cat("\n=== TLB candidate: ARMA(0,0) on first differences (annual change) ===\n")
cat("AIC:", tlb_arma00$aic, "  BIC:", BIC(tlb_arma00), "\n")
print(tlb_arma00)

png("plots/13_tlb_arma00_residuals_acf_pacf.png", width = 900, height = 450, res = 120)
par(mfrow = c(1, 2))
acf(residuals(tlb_arma00), main = "ACF: TLB ARMA(0,0) residuals", lag.max = 20)
pacf(residuals(tlb_arma00), main = "PACF: TLB ARMA(0,0) residuals", lag.max = 20)
par(mfrow = c(1, 1))
dev.off()

cat("\n=== Box-Ljung: TLB ARMA(0,0) residuals (lag = 10) ===\n")
print(Box.test(residuals(tlb_arma00), lag = 10, type = "Ljung-Box"))

# --- 7.2 TFR candidate on first differences ---
# PACF shows a clear spike at lag 1 while ACF drops quickly, so AR(1) is a
# reasonable first candidate on annual changes.
tfr_ar1 <- stats::arima(tfr_diff1, order = c(1, 0, 0), method = "ML")

cat("\n=== TFR candidate: AR(1) on first differences (annual change) ===\n")
cat("AIC:", tfr_ar1$aic, "  BIC:", BIC(tfr_ar1), "\n")
print(tfr_ar1)

png("plots/14_tfr_ar1_residuals_acf_pacf.png", width = 900, height = 450, res = 120)
par(mfrow = c(1, 2))
acf(residuals(tfr_ar1), main = "ACF: TFR AR(1) residuals", lag.max = 20)
pacf(residuals(tfr_ar1), main = "PACF: TFR AR(1) residuals", lag.max = 20)
par(mfrow = c(1, 1))
dev.off()

cat("\n=== Box-Ljung: TFR AR(1) residuals (lag = 10) ===\n")
print(Box.test(residuals(tfr_ar1), lag = 10, type = "Ljung-Box"))
