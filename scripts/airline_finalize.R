# =============================================================================
# Finalize: TFR final = SARIMA(4,1,0)(1,1,0)[12] (seasonal AR, log);
#           TLB final = SARIMA(4,1,0)(0,1,1)[12] (airline / seasonal MA).
# Print exact stats for the report and regenerate Figs 3, 5, 7.
#   Fig 3 = residual ACFs of the two ADOPTED models
#   Fig 5 = TLB airline checkresiduals (4-panel)
#   Fig 7 = TLB airline forecast
# Also print stats for the two viable ALTERNATIVE candidates (for the tables).
# =============================================================================
suppressPackageStartupMessages({ library(forecast); library(ggplot2) })
options(stringsAsFactors=FALSE, scipen=999); set.seed(42)
data  <- read.csv("cleaned_tlb_tfr_1960_2024.csv")
train <- subset(data, Year<=2012); test <- subset(data, Year>=2013)
ty<-test$Year; tyr<-train$Year
tfr_s12<-ts(train$TFR,start=1960,frequency=12); tlb_s12<-ts(train$TLB,start=1960,frequency=12)
tfr_test<-test$TFR; tlb_test<-test$TLB

full <- function(series,seas,lambda,test,lab){
  fit<-Arima(series,order=c(4,1,0),seasonal=list(order=seas,period=12),lambda=lambda,method="ML")
  se<-sqrt(diag(fit$var.coef)); tt<-coef(fit)/se
  png(tempfile(fileext=".png")); cr<-suppressWarnings(checkresiduals(fit,plot=FALSE)); dev.off()
  fc<-forecast(fit,h=length(test),biasadj=FALSE); m<-as.numeric(fc$mean); e<-as.numeric(test)-m
  cat("\n==",lab,"==\n"); print(round(rbind(coef=coef(fit),se=se,t=tt),3))
  cat(sprintf("AIC=%.2f BIC=%.2f loglik=%.2f sigma2=%.6g  LB Q*=%.2f df=%d p=%.4f  MSE=%.6g MAE=%.4g MAPE=%.2f  largest|e|=%.4g in %d  min95=%.4g\n",
      AIC(fit),BIC(fit),logLik(fit),fit$sigma2,unname(cr$statistic),cr$parameter,cr$p.value,
      mean(e^2),mean(abs(e)),mean(abs(e/as.numeric(test)))*100,max(abs(e)),ty[which.max(abs(e))],min(as.numeric(fc$lower[,2]))))
  fit
}
cat("######## ADOPTED ########")
tfr_fin <- full(tfr_s12,c(1,1,0),0,   tfr_test,"TFR FINAL SARIMA(4,1,0)(1,1,0)[12] (log, seasonal AR)")
tlb_fin <- full(tlb_s12,c(0,1,1),NULL,tlb_test,"TLB FINAL SARIMA(4,1,0)(0,1,1)[12] (airline)")
cat("\n######## VIABLE ALTERNATIVES (for tables) ########")
full(tfr_s12,c(0,1,1),0,   tfr_test,"TFR alt SARIMA(4,1,0)(0,1,1)[12] (airline)")
full(tlb_s12,c(1,1,0),NULL,tlb_test,"TLB alt SARIMA(4,1,0)(1,1,0)[12] (seasonal AR)")

# ---- Fig 3: residual ACFs of the two adopted models -------------------------
png("figures/fr2_fig3_initial_resid_acf.png", width=1180, height=470, res=130, bg="white")
par(mfrow=c(1,2), mar=c(4.2,4.5,3.4,1))
acf(as.numeric(residuals(tfr_fin)), lag.max=24, main="TFR final: log-SARIMA(4,1,0)(1,1,0)[12]")
acf(as.numeric(residuals(tlb_fin)), lag.max=24, main="TLB final: SARIMA(4,1,0)(0,1,1)[12]")
dev.off(); cat("\nwrote fr2_fig3_initial_resid_acf.png\n")

# ---- Fig 5: TLB airline checkresiduals --------------------------------------
png("figures/fr2_fig5_resid_tlb.png", width=980, height=720, res=120, bg="white")
suppressWarnings(checkresiduals(tlb_fin)); dev.off(); cat("wrote fr2_fig5_resid_tlb.png\n")

# ---- Fig 7: TLB airline forecast --------------------------------------------
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
  labs(title="TLB forecast 2013-2024 - SARIMA(4,1,0)(0,1,1)[12]",x="Year",y="Total live births")+theme_bw()
ggsave("figures/fr2_fig7_forecast_tlb.png",p,width=9,height=5,dpi=130); cat("wrote fr2_fig7_forecast_tlb.png\n")
