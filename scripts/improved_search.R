# =============================================================================
# IMPROVED-MODEL SEARCH within the professor's seasonal-difference framework.
# The exact spec SARIMA(p,1,0)(1,1,0)[12] left residual-ACF spikes at lags 3-4
# (TFR) / lag 4 (TLB).  Per the professor's own rule ("if a spike remains,
# increment p"), push p up; also try the airline seasonal (0,1,1)[12] and the
# combined (1,1,1)[12].  Keep d=1 & D=1 (the d-check showed the seasonally-
# differenced series still trends).  Report every white candidate (LB pass AND
# no residual-ACF spike to lag 36), ranked by AIC and by test MAPE.
# =============================================================================
suppressPackageStartupMessages({ library(forecast) })
options(stringsAsFactors = FALSE, scipen = 999)
data  <- read.csv("cleaned_tlb_tfr_1960_2024.csv")
train <- subset(data, Year <= 2012); test <- subset(data, Year >= 2013)
tfr_s12 <- ts(train$TFR, start = 1960, frequency = 12)
tlb_s12 <- ts(train$TLB, start = 1960, frequency = 12)
tfr_test <- test$TFR; tlb_test <- test$TLB

scan <- function(series, lambda, test, tag) {
  cat("\n=====", tag, "— SARIMA(p,1,q)(P,1,Q)[12], d=1 D=1 (seasonal diff kept) =====\n")
  rows <- list()
  for (p in 0:4) for (q in 0:1) for (P in 0:1) for (Q in 0:1) {
    if (P == 0 && Q == 0 && p == 0 && q == 0) next
    seas <- c(P,1,Q)
    fit <- tryCatch(Arima(series, order = c(p,1,q),
                          seasonal = list(order = seas, period = 12),
                          lambda = lambda, method = "ML"), error = function(e) NULL)
    if (is.null(fit)) next
    np <- length(fit$coef)
    cr <- tryCatch({ png(tempfile(fileext=".png"))
      v <- suppressWarnings(checkresiduals(fit, plot=FALSE)); dev.off(); v },
      error = function(e) NULL)
    if (is.null(cr)) next
    r <- as.numeric(residuals(fit)); r <- r[is.finite(r)]; n <- length(r)
    ci <- 1.96/sqrt(n)
    acf_v <- acf(r, lag.max = 36, plot = FALSE)$acf[,1,1][-1]
    cross <- which(abs(acf_v) > ci)
    fc <- forecast(fit, h = length(test), biasadj = FALSE)
    e  <- as.numeric(test) - as.numeric(fc$mean)
    mape <- mean(abs(e/as.numeric(test)))*100; rmse <- sqrt(mean(e^2)); mae <- mean(abs(e))
    white <- (cr$p.value > 0.05) && (length(cross) == 0)
    rows[[length(rows)+1]] <- data.frame(
      lab = sprintf("(%d,1,%d)(%d,1,%d)[12]", p, q, P, Q),
      np = np, AIC = round(AIC(fit),2), LBp = round(cr$p.value,4),
      ACFx = paste(cross, collapse=","), white = white,
      RMSE = round(rmse,3), MAE = round(mae,3), MAPE = round(mape,2),
      stringsAsFactors = FALSE)
  }
  df <- do.call(rbind, rows)
  cat("\n  ALL candidates (sorted by AIC):\n")
  print(df[order(df$AIC), ], row.names = FALSE)
  w <- df[df$white, ]
  cat("\n  WHITE (LB>0.05 AND no ACF spike) — ranked by AIC:\n")
  if (nrow(w) == 0) cat("    (none)\n") else print(w[order(w$AIC), ], row.names = FALSE)
  cat("\n  WHITE — ranked by test MAPE:\n")
  if (nrow(w) == 0) cat("    (none)\n") else print(w[order(w$MAPE), ], row.names = FALSE)
  invisible(df)
}
scan(tfr_s12, 0,    tfr_test, "TFR (log)")
scan(tlb_s12, NULL, tlb_test, "TLB (orig)")
