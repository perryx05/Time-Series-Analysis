# Regenerate Figure 2 (plots/fr_fig1_acf_pacf.png) to show BOTH the
# singly-differenced series (top 2 rows, reveals the lag-12 zodiac cluster) AND
# the doubly-differenced (1-B)(1-B^12) series (bottom 2 rows, reveals the lag-4
# spike that justifies the non-seasonal order p = 4).  Train = 1960-2012.
options(scipen = 999)
suppressPackageStartupMessages(library(forecast))   # Acf/Pacf omit the lag-0 spike
data  <- read.csv("cleaned_tlb_tfr_1960_2024.csv")
train <- subset(data, Year <= 2012)
ltfr  <- log(train$TFR); tlb <- train$TLB

s_ltfr <- diff(ltfr)               ; s_tlb <- diff(tlb)                 # (1-B)
d_ltfr <- diff(diff(ltfr, lag = 12)); d_tlb <- diff(diff(tlb, lag = 12)) # (1-B)(1-B^12)

# ACF helper that hides the lag-0 = 1 spike (xlim from lag 1), matching the
# original figure's appearance; PACF starts at lag 1 already.
A <- function(x, L, main) Acf (x, lag.max = L, lwd = 1.8, xlab = "Lag (years)", main = main)
P <- function(x, L, main) Pacf(x, lag.max = L, lwd = 1.8, xlab = "Lag (years)", main = main)

# High-resolution render (300 dpi) so the figure stays crisp at page width.
png("plots/fr_fig1_acf_pacf.png", width = 2950, height = 3300, res = 300, bg = "white")
par(mfrow = c(4, 2), mar = c(4.2, 4.6, 3, 1.2),
    cex.axis = 1.0, cex.lab = 1.15, cex.main = 1.2, font.main = 1)
A(s_ltfr, 45, expression(ACF~of~nabla*log(TFR[t])))
P(s_ltfr, 45, expression(PACF~of~nabla*log(TFR[t])))
A(s_tlb , 45, expression(ACF~of~nabla*TLB[t]))
P(s_tlb , 45, expression(PACF~of~nabla*TLB[t]))
A(d_ltfr, 24, expression(ACF~of~(1-B)(1-B^12)*log(TFR[t])))
P(d_ltfr, 24, expression(PACF~of~(1-B)(1-B^12)*log(TFR[t])))
A(d_tlb , 24, expression(ACF~of~(1-B)(1-B^12)*TLB[t]))
P(d_tlb , 24, expression(PACF~of~(1-B)(1-B^12)*TLB[t]))
dev.off()

cat("doubly-differenced PACF at lag 4:  log-TFR =",
    round(pacf(d_ltfr, plot = FALSE)$acf[4], 3), " TLB =",
    round(pacf(d_tlb,  plot = FALSE)$acf[4], 3), "\n")
cat("wrote plots/fr_fig1_acf_pacf.png\n")
