# =============================================================================
# REPORT FIGURES + NUMBERS for the INITIAL->IMPROVED revision of
# final_report_revised.md.
#   Initial (clunky, high-order, non-seasonal): TFR log-ARIMA(15,1,0); TLB ARIMA(13,1,0)
#   Improved (parsimonious SARIMA, seasonal difference): both SARIMA(4,1,0)(1,1,0)[12]
# Re-uses the report figure filenames so existing image links keep working:
#   Fig 3 fr2_fig3_initial_resid_acf | Fig 4 fr2_fig4_resid_tfr |
#   Fig 5 fr2_fig5_resid_tlb | Fig 6 fr2_fig6_forecast_tfr | Fig 7 fr2_fig7_forecast_tlb
# Prints every number quoted in the report. Train 1960-2012 | test 2013-2024.
# =============================================================================
suppressPackageStartupMessages({ library(forecast); library(tseries); library(ggplot2) })
options(stringsAsFactors = FALSE, scipen = 999); set.seed(42)
dir.create("figures", showWarnings = FALSE)
rule <- function(s) cat("\n====", s, "====\n")

data  <- read.csv("cleaned_tlb_tfr_1960_2024.csv")
train <- subset(data, Year <= 2012); test <- subset(data, Year >= 2013)
ty <- test$Year; tyr <- train$Year
tfr_t1  <- ts(train$TFR, start = 1960, frequency = 1)
tlb_t1  <- ts(train$TLB, start = 1960, frequency = 1)
tfr_s12 <- ts(train$TFR, start = 1960, frequency = 12)
tlb_s12 <- ts(train$TLB, start = 1960, frequency = 12)
tfr_test <- test$TFR; tlb_test <- test$TLB

# ---- fits --------------------------------------------------------------------
tfr_init <- Arima(tfr_t1,  c(15,1,0),                               lambda = 0, method = "ML")
tfr_impr <- Arima(tfr_s12, c(4,1,0), list(order=c(1,1,0),period=12),lambda = 0, method = "ML")
tlb_init <- Arima(tlb_t1,  c(13,1,0),                                          method = "ML")
tlb_impr <- Arima(tlb_s12, c(4,1,0), list(order=c(1,1,0),period=12),           method = "ML")

# ---- numbers helper ----------------------------------------------------------
report_num <- function(fit, test, lab, expo=FALSE) {
  np <- length(fit$coef); se <- sqrt(diag(fit$var.coef)); tt <- coef(fit)/se
  png(tempfile(fileext=".png")); cr <- suppressWarnings(checkresiduals(fit, plot=FALSE)); dev.off()
  fc <- forecast(fit, h=length(test), biasadj=FALSE); m <- as.numeric(fc$mean)
  e  <- as.numeric(test) - m
  mse <- mean(e^2); mae <- mean(abs(e)); mape <- mean(abs(e/as.numeric(test)))*100
  rule(lab)
  print(round(rbind(coef=coef(fit), se=se, t=tt), 3))
  cat(sprintf("npar=%d  AIC=%.2f  BIC=%.2f  loglik=%.2f  sigma2=%.6g  sigma=%.4g\n",
              np, AIC(fit), BIC(fit), logLik(fit), fit$sigma2, sqrt(fit$sigma2)))
  cat(sprintf("Ljung-Box: Q*=%.2f  df=%d  p=%.4f\n", unname(cr$statistic), cr$parameter, cr$p.value))
  cat(sprintf("test MSE=%.6g  MAE=%.4g  MAPE=%.2f%%  | largest |err|=%.4g in %d | min95low=%.4f\n",
              mse, mae, mape, max(abs(e)), ty[which.max(abs(e))], min(as.numeric(fc$lower[,2]))))
  cat("forecast mean:", paste(round(m, ifelse(expo,3,0)), collapse=", "), "\n")
  invisible(list(fit=fit, fc=fc, mse=mse, mae=mae, mape=mape))
}
R1 <- report_num(tfr_init, tfr_test, "TFR INITIAL log-ARIMA(15,1,0)", expo=TRUE)
R2 <- report_num(tfr_impr, tfr_test, "TFR IMPROVED log-SARIMA(4,1,0)(1,1,0)[12]", expo=TRUE)
R3 <- report_num(tlb_init, tlb_test, "TLB INITIAL ARIMA(13,1,0)")
R4 <- report_num(tlb_impr, tlb_test, "TLB IMPROVED SARIMA(4,1,0)(1,1,0)[12]")

# significant-lag count for initials
sigc <- function(fit){ tt<-coef(fit)/sqrt(diag(fit$var.coef)); sprintf("%d/%d sig: %s",
        sum(abs(tt)>1.96), length(tt), paste(names(tt)[abs(tt)>1.96],collapse=",")) }
rule("significant coefficients (initials)")
cat("TFR log-ARIMA(15,1,0):", sigc(tfr_init), "\n")
cat("TLB ARIMA(13,1,0)    :", sigc(tlb_init), "\n")

# =============================================================================
# FIG 3 — residual ACF of the two INITIAL high-order ARIMA models (clean band,
#         formal LB marginal). 2 panels.
# =============================================================================
png("plots/fr2_fig3_initial_resid_acf.png", width = 1180, height = 470, res = 130, bg = "white")
par(mfrow = c(1,2), mar = c(4.2,4.5,3.4,1))
r1 <- as.numeric(residuals(tfr_init)); r3 <- as.numeric(residuals(tlb_init))
acf(r1[is.finite(r1)], lag.max = 24, main = "Initial TFR: log-ARIMA(15,1,0)")
acf(r3[is.finite(r3)], lag.max = 24, main = "Initial TLB: ARIMA(13,1,0)")
dev.off(); cat("\nwrote plots/fr2_fig3_initial_resid_acf.png\n")

# =============================================================================
# FIG 4 & 5 — checkresiduals 4-panel for the IMPROVED models
# =============================================================================
png("plots/fr2_fig4_resid_tfr.png", width = 980, height = 720, res = 120, bg = "white")
suppressWarnings(checkresiduals(tfr_impr)); dev.off(); cat("wrote plots/fr2_fig4_resid_tfr.png\n")
png("plots/fr2_fig5_resid_tlb.png", width = 980, height = 720, res = 120, bg = "white")
suppressWarnings(checkresiduals(tlb_impr)); dev.off(); cat("wrote plots/fr2_fig5_resid_tlb.png\n")

# =============================================================================
# FIG 6 & 7 — forecasts (ggplot; back-transform automatic for TFR via lambda)
# =============================================================================
fc_gg <- function(fit, hist_vals, obs, title, ylab, fname, dragon2024=TRUE) {
  fc <- forecast(fit, h = length(obs), biasadj = FALSE)
  hist_df <- data.frame(Year = tyr, Value = as.numeric(hist_vals))
  fc_df <- data.frame(Year = ty, Mean = as.numeric(fc$mean),
                      Lo80 = as.numeric(fc$lower[,1]), Hi80 = as.numeric(fc$upper[,1]),
                      Lo95 = as.numeric(fc$lower[,2]), Hi95 = as.numeric(fc$upper[,2]),
                      Actual = as.numeric(obs))
  p <- ggplot() +
    geom_ribbon(data=fc_df, aes(Year, ymin=Lo95, ymax=Hi95), fill="steelblue", alpha=0.16) +
    geom_ribbon(data=fc_df, aes(Year, ymin=Lo80, ymax=Hi80), fill="steelblue", alpha=0.30) +
    geom_line(data=hist_df, aes(Year, Value), colour="black", linewidth=0.7) +
    geom_line(data=fc_df, aes(Year, Mean), colour="red", linetype="dashed", linewidth=0.8) +
    geom_line(data=fc_df, aes(Year, Actual), colour="blue", linewidth=0.8) +
    geom_point(data=fc_df, aes(Year, Actual), colour="blue", size=1.3) +
    geom_vline(xintercept=2012.5, linetype="dashed", colour="grey45") +
    annotate("text", x=2012.5, y=-Inf, label=" train | test", hjust=0, vjust=-0.6, colour="grey40", size=3) +
    annotate("point", x=2020, y=fc_df$Actual[fc_df$Year==2020], colour="darkorange2", size=2.4) +
    annotate("text", x=2020, y=fc_df$Actual[fc_df$Year==2020], label="2020 (COVID)",
             colour="darkorange2", size=2.9, hjust=1.1, vjust=-0.7) +
    labs(title=title, x="Year", y=ylab) + theme_bw()
  if (dragon2024)
    p <- p + annotate("point", x=2024, y=fc_df$Actual[fc_df$Year==2024], colour="forestgreen", size=2.4) +
             annotate("text", x=2024, y=fc_df$Actual[fc_df$Year==2024], label="2024 (Dragon)",
                      colour="forestgreen", size=2.9, hjust=1.1, vjust=1.4)
  ggsave(fname, p, width=9, height=5, dpi=130)
  cat("wrote", fname, "\n")
}
fc_gg(tfr_impr, train$TFR, tfr_test, "TFR forecast 2013-2024 - log-SARIMA(4,1,0)(1,1,0)[12]",
      "TFR (children per woman)", "plots/fr2_fig6_forecast_tfr.png")
fc_gg(tlb_impr, train$TLB, tlb_test, "TLB forecast 2013-2024 - SARIMA(4,1,0)(1,1,0)[12]",
      "Total live births", "plots/fr2_fig7_forecast_tlb.png")

cat("\nDONE\n")
