# =============================================================================
# Parsimony framing: high-order viable INITIAL -> parsimonious p=4 FINAL,
# within the seasonal-AR SARIMA(p,1,0)(1,1,0)[12] family.
#   TLB: initial (13,1,0)(1,1,0) -> final (4,1,0)(1,1,0)
#   TFR: initial (12,1,0)(1,1,0) -> final (4,1,0)(1,1,0)   [p=13 FAILS LB for TFR]
# Print exact stats; regenerate Fig 3 (initials' resid ACF), Fig 5 (TLB final
# checkresiduals), Fig 7 (TLB final forecast).
# =============================================================================
suppressPackageStartupMessages({ library(forecast); library(ggplot2) })
options(stringsAsFactors=FALSE, scipen=999); set.seed(42)
dir.create("methods", showWarnings = FALSE)

data  <- read.csv("cleaned_tlb_tfr_1960_2024.csv")
train <- subset(data, Year<=2012); test <- subset(data, Year>=2013)
ty<-test$Year; tyr<-train$Year
tfr_s12<-ts(train$TFR,start=1960,frequency=12); tlb_s12<-ts(train$TLB,start=1960,frequency=12)
tfr_test<-test$TFR; tlb_test<-test$TLB

rep1 <- function(series,p,lambda,test,lab){
  fit<-Arima(series,order=c(p,1,0),seasonal=list(order=c(1,1,0),period=12),lambda=lambda,method="ML")
  np<-length(fit$coef); se<-sqrt(diag(fit$var.coef)); tt<-coef(fit)/se
  png(tempfile(fileext=".png")); cr<-suppressWarnings(checkresiduals(fit,plot=FALSE)); dev.off()
  r<-as.numeric(residuals(fit)); n<-length(r); ci<-1.96/sqrt(n)
  cross<-which(abs(acf(r,lag.max=36,plot=FALSE)$acf[,1,1][-1])>ci)
  fc<-forecast(fit,h=length(test),biasadj=FALSE); e<-as.numeric(test)-as.numeric(fc$mean)
  sig<-names(tt)[abs(tt)>1.96]
  cat(sprintf("\n== %s ==\n npar=%d AIC=%.2f BIC=%.2f sigma2=%.6g  LB Q*=%.2f df=%d p=%.4f spike={%s}  MAPE=%.2f RMSE=%.0f  nsig=%d {%s}\n",
      lab,np,AIC(fit),BIC(fit),fit$sigma2,unname(cr$statistic),cr$parameter,cr$p.value,
      paste(cross,collapse=","),mean(abs(e/as.numeric(test)))*100,sqrt(mean(e^2)),length(sig),paste(sig,collapse=",")))
  invisible(fit)
}
cat("######## TLB ########")
tlb_init <- rep1(tlb_s12,13,NULL,tlb_test,"TLB INITIAL SARIMA(13,1,0)(1,1,0)[12]")
tlb_fin  <- rep1(tlb_s12, 4,NULL,tlb_test,"TLB FINAL   SARIMA(4,1,0)(1,1,0)[12]")
cat("\n######## TFR ########")
rep1(tfr_s12,13,0,tfr_test,"TFR (13,1,0)(1,1,0) [check viability]")
tfr_init <- rep1(tfr_s12,12,0,tfr_test,"TFR INITIAL SARIMA(12,1,0)(1,1,0)[12]")
tfr_fin  <- rep1(tfr_s12, 4,0,tfr_test,"TFR FINAL   SARIMA(4,1,0)(1,1,0)[12]")

# ---- Fig 3: residual ACFs of the two INITIAL (high-order) models ------------
png("methods/fr2_fig3_initial_resid_acf.png", width=1180, height=470, res=130, bg="white")
par(mfrow=c(1,2), mar=c(4.2,4.5,3.4,1))
acf(as.numeric(residuals(tfr_init)), lag.max=24, main="TFR initial: log-SARIMA(12,1,0)(1,1,0)[12]")
acf(as.numeric(residuals(tlb_init)), lag.max=24, main="TLB initial: SARIMA(13,1,0)(1,1,0)[12]")
dev.off(); cat("\nwrote methods/fr2_fig3_initial_resid_acf.png\n")

# ---- Fig 5: TLB FINAL (4,1,0)(1,1,0) checkresiduals -------------------------
png("methods/fr2_fig5_resid_tlb.png", width=980, height=720, res=120, bg="white")
suppressWarnings(checkresiduals(tlb_fin)); dev.off(); cat("wrote methods/fr2_fig5_resid_tlb.png\n")

# ---- Fig 7: TLB FINAL (4,1,0)(1,1,0) forecast ------------------------------
fc<-forecast(tlb_fin,h=length(tlb_test),biasadj=FALSE)
hist_df<-data.frame(Year=tyr,Value=train$TLB)
fc_df<-data.frame(Year=ty,Mean=as.numeric(fc$mean),
  Lo80=as.numeric(fc$lower[,1]),Hi80=as.numeric(fc$upper[,1]),
  Lo95=as.numeric(fc$lower[,2]),Hi95=as.numeric(fc$upper[,2]),Actual=tlb_test)
p<-ggplot()+
  geom_ribbon(data=fc_df,aes(Year,ymin=Lo95,ymax=Hi95),fill="steelblue",alpha=0.16)+
  geom_ribbon(data=fc_df,aes(Year,ymin=Lo80,ymax=Hi80),fill="steelblue",alpha=0.30)+
  geom_line(data=hist_df,aes(Year,Value),colour="black",linewidth=0.7)+
  geom_line(data=fc_df,aes(Year,Mean),colour="red",linetype="dashed",linewidth=0.8)+
  geom_line(data=fc_df,aes(Year,Actual),colour="blue",linewidth=0.8)+
  geom_point(data=fc_df,aes(Year,Actual),colour="blue",size=1.3)+
  geom_vline(xintercept=2012.5,linetype="dashed",colour="grey45")+
  annotate("text",x=2012.5,y=-Inf,label=" train | test",hjust=0,vjust=-0.6,colour="grey40",size=3)+
  annotate("point",x=2020,y=fc_df$Actual[fc_df$Year==2020],colour="darkorange2",size=2.4)+
  annotate("text",x=2020,y=fc_df$Actual[fc_df$Year==2020],label="2020 (COVID)",colour="darkorange2",size=2.9,hjust=1.1,vjust=-0.7)+
  annotate("point",x=2024,y=fc_df$Actual[fc_df$Year==2024],colour="forestgreen",size=2.4)+
  annotate("text",x=2024,y=fc_df$Actual[fc_df$Year==2024],label="2024 (Dragon)",colour="forestgreen",size=2.9,hjust=1.1,vjust=1.4)+
  labs(title="TLB forecast 2013-2024 - SARIMA(4,1,0)(1,1,0)[12]",x="Year",y="Total live births")+theme_bw()
ggsave("methods/fr2_fig7_forecast_tlb.png",p,width=9,height=5,dpi=130); cat("wrote methods/fr2_fig7_forecast_tlb.png\n")
