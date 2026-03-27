# =============================================================================
# EDA: Singapore Total Live Births (TLB) and Total Fertility Rate (TFR)
# Period: 1960 to 2024
# =============================================================================

# =============================================================================
# SECTION 0: Set up and load packages
# =============================================================================

# Base R workflow (no extra packages needed for Section 0-1)
# Optional packages for later sections:
# install.packages(c("tseries", "forecast", "ggplot2"))
# library(tseries)
# library(forecast)
# library(ggplot2)

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
