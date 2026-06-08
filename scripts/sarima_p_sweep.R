# =============================================================================
# HIGH-p vs LOW-p sweep for the IMPROVED seasonal form SARIMA(p,1,0)(1,1,0)[12].
# Vary p = 1..15 for both series (d=1, D=1, seasonal AR(1) fixed). Because every
# candidate has the SAME differencing (D=1) and seasonal structure, their AIC IS
# comparable here. Report npar, AIC, Ljung-Box p (checkresiduals), residual-ACF
# spikes to lag 36, test MAPE, and the white verdict. Goal: confirm whether a
# high-p SARIMA beats the parsimonious p=4 pick. Train 1960-2012 | test 2013-2024.
# =============================================================================
suppressPackageStartupMessages({ library(forecast) })
options(stringsAsFactors = FALSE, scipen = 999)
data  <- read.csv("cleaned_tlb_tfr_1960_2024.csv")
train <- subset(data, Year <= 2012); test <- subset(data, Year >= 2013)
tfr_s12 <- ts(train$TFR, start = 1960, frequency = 12)
tlb_s12 <- ts(train$TLB, start = 1960, frequency = 12)
tfr_test <- test$TFR; tlb_test <- test$TLB

sweep <- function(series, lambda, test, tag) {
  cat("\n==========", tag, "— SARIMA(p,1,0)(1,1,0)[12], p = 1..15 (AIC comparable) ==========\n")
  rows <- list()
  for (p in 1:15) {
    fit <- tryCatch(Arima(series, order = c(p,1,0),
                          seasonal = list(order = c(1,1,0), period = 12),
                          lambda = lambda, method = "ML"), error = function(e) NULL)
    if (is.null(fit)) { cat(sprintf("  p=%2d : did not converge\n", p)); next }
    np <- length(fit$coef)
    cr <- tryCatch({ png(tempfile(fileext=".png"))
      v <- suppressWarnings(checkresiduals(fit, plot=FALSE)); dev.off(); v }, error=function(e) NULL)
    if (is.null(cr)) next
    r <- as.numeric(residuals(fit)); r <- r[is.finite(r)]; n <- length(r); ci <- 1.96/sqrt(n)
    cross <- which(abs(acf(r, lag.max=36, plot=FALSE)$acf[,1,1][-1]) > ci)
    fc <- forecast(fit, h=length(test), biasadj=FALSE); e <- as.numeric(test) - as.numeric(fc$mean)
    mape <- mean(abs(e/as.numeric(test)))*100
    white <- (cr$p.value > 0.05) && (length(cross)==0)
    rows[[length(rows)+1]] <- data.frame(p=p, npar=np, AIC=round(AIC(fit),2),
      LBp=round(cr$p.value,4), spike=paste(cross,collapse=","), MAPE=round(mape,2),
      white=white, stringsAsFactors=FALSE)
  }
  df <- do.call(rbind, rows)
  cat("\n  all p (in order):\n"); print(df, row.names=FALSE)
  w <- df[df$white,]
  cat("\n  WHITE only, ranked by AIC (lower=better; comparable across these):\n")
  if (nrow(w)==0) cat("   (none)\n") else print(w[order(w$AIC),], row.names=FALSE)
  cat("\n  WHITE only, ranked by test MAPE:\n")
  if (nrow(w)==0) cat("   (none)\n") else print(w[order(w$MAPE),], row.names=FALSE)
  invisible(df)
}
sweep(tfr_s12, 0,    tfr_test, "TFR (log)")
sweep(tlb_s12, NULL, tlb_test, "TLB (orig)")
