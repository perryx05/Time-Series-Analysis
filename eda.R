# =============================================================================
# EDA: Singapore Total Live Births (TLB) and Total Fertility Rate (TFR)
# Period: 1960 to 2024
# =============================================================================

# =============================================================================
# SECTION 0: Set up and load packages
# =============================================================================

# Load packages
install.packages(c("tseries", "forecast", "ggplot2"))
library(tseries)
library(forecast)
library(ggplot2)

# =============================================================================
# SECTION 1: Data loading and Inspection
# =============================================================================
# 1.1 Load data
data <- read.csv("M810091.csv")

# 1.2 Inspect data
head(data)
tail(data)
str(data)
summary(data)
dim(data)
names(data)


# =============================================================================
# SECTION 2: Data Cleaning
# =============================================================================
 