# =============================================================================
# FINAL initial->improved models: diagnostics + forecast figures.
#   TFR initial : log-ARIMA(15,1,0)            (clean resid ACF; LB marginal)
#   TFR improved: log-SARIMA(4,1,0)(1,1,0)[12] (white; MAPE 8.89; pure AR)
#   TLB initial : ARIMA(13,1,0)                (clean resid ACF; LB marginal)
#   TLB improved: SARIMA(4,1,0)(1,1,0)[12]     (white; MAPE 12.1; prof template)
#                 SARIMA(4,1,0)(0,1,1)[12]     (white; MAPE 8.89; airline, low AIC)
# Figures -> plots/fin_*.png
# =============================================================================
suppressPackageStartupMessages({ library(forecast) })
options(stringsAsFactors=FALSE, scipen=999)
dir.create("figures", showWarnings = FALSE)
data  <- read.csv("cleaned_tlb_tfr_1960_2024.csv")
train <- subset(data, Year<=2012); test <- subset(data, Year>=2013)
tfr_s12 <- ts(train$TFR, start=1960, frequency=12)
tlb_s12 <- ts(train$TLB, start=1960, frequency=12)
tfr_t1  <- ts(train$TFR, start=1960, frequency=1)
tlb_t1  <- ts(train$TLB, start=1960, frequency=1)
tfr_test<-test$TFR; tlb_test<-test$TLB; ty<-test$Year

fits <- list(
  tfr_init = Arima(tfr_t1,  c(15,1,0),                               lambda=0, method="ML"),
  tfr_impr = Arima(tfr_s12, c(4,1,0), list(order=c(1,1,0),period=12),lambda=0, method="ML"),
  tlb_init = Arima(tlb_t1,  c(13,1,0),                                        method="ML"),
  tlb_impr = Arima(tlb_s12, c(4,1,0), list(order=c(1,1,0),period=12),         method="ML"),
  tlb_air  = Arima(tlb_s12, c(4,1,0), list(order=c(0,1,1),period=12),         method="ML")
)
labs <- c(tfr_init="log-ARIMA(15,1,0)", tfr_impr="log-SARIMA(4,1,0)(1,1,0)[12]",
          tlb_init="ARIMA(13,1,0)", tlb_impr="SARIMA(4,1,0)(1,1,0)[12]",
          tlb_air="SARIMA(4,1,0)(0,1,1)[12]")

# residual ACF/PACF panels
for (k in names(fits)) {
  r <- as.numeric(residuals(fits[[k]])); r <- r[is.finite(r)]
  png(sprintf("plots/fin_%s_resid.png", k), width=1000, height=440, res=110, bg="white")
  par(mfrow=c(1,2), mar=c(4,4.5,3.2,1))
  acf(r,  lag.max=36, main=paste("Residual ACF -", labs[k]))
  pacf(r, lag.max=36, main=paste("Residual PACF -", labs[k]))
  dev.off()
}
# checkresiduals 4-panel for the improved models
for (k in c("tfr_impr","tlb_impr","tlb_air")) {
  png(sprintf("plots/fin_%s_check.png", k), width=950, height=720, res=110, bg="white")
  suppressWarnings(checkresiduals(fits[[k]])); dev.off()
}

# forecast plots
fc_plot <- function(k, hist_years, hist_vals, obs, ylab, title) {
  fit <- fits[[k]]; fc <- forecast(fit, h=length(obs), biasadj=FALSE)
  png(sprintf("plots/fin_%s_forecast.png", k), width=1000, height=520, res=110, bg="white")
  par(mar=c(4,4.7,3.2,1))
  yr <- c(hist_years, ty)
  yl <- range(c(hist_vals, obs, as.numeric(fc$lower[,2]), as.numeric(fc$upper[,2])), na.rm=TRUE)
  plot(hist_years, as.numeric(hist_vals), type="l", lwd=2, xlim=range(yr), ylim=yl,
       xlab="Year", ylab=ylab, main=title)
  polygon(c(ty,rev(ty)), c(as.numeric(fc$lower[,2]), rev(as.numeric(fc$upper[,2]))),
          col=adjustcolor("steelblue",0.16), border=NA)
  polygon(c(ty,rev(ty)), c(as.numeric(fc$lower[,1]), rev(as.numeric(fc$upper[,1]))),
          col=adjustcolor("steelblue",0.28), border=NA)
  lines(ty, as.numeric(fc$mean), col="red", lwd=2, lty=2)
  lines(ty, obs, col="blue", lwd=2); points(ty, obs, col="blue", pch=16, cex=0.8)
  abline(v=2012.5, lty=3, col="grey50")
  legend("topright", c("train","forecast","actual","80/95% PI"),
         col=c("black","red","blue",adjustcolor("steelblue",0.5)),
         lwd=c(2,2,2,8), lty=c(1,2,1,1), bty="n", cex=0.85)
  dev.off()
}
fc_plot("tfr_init", train$Year, train$TFR, tfr_test, "TFR", paste0("TFR initial - ", labs["tfr_init"]))
fc_plot("tfr_impr", train$Year, train$TFR, tfr_test, "TFR", paste0("TFR improved - ", labs["tfr_impr"]))
fc_plot("tlb_init", train$Year, train$TLB, tlb_test, "TLB", paste0("TLB initial - ", labs["tlb_init"]))
fc_plot("tlb_impr", train$Year, train$TLB, tlb_test, "TLB", paste0("TLB improved - ", labs["tlb_impr"]))
fc_plot("tlb_air",  train$Year, train$TLB, tlb_test, "TLB", paste0("TLB improved (airline) - ", labs["tlb_air"]))
cat("Wrote plots/fin_*.png\n")
