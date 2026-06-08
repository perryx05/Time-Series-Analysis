# =============================================================================
# TLB (and TFR) investigation:
#  (1) Find VIABLE (white: LB>0.05 AND no residual-ACF spike to lag 36) models so
#      BOTH an initial and a final can be white.
#  (2) Compare low-p vs high-p honestly across seasonal structures.
#  (3) Diagnose WHY the low-p (4,1,0)(1,1,0)[12] TLB forecast is poor.
# Train 1960-2012 | test 2013-2024.
# =============================================================================
suppressPackageStartupMessages({ library(forecast) })
options(stringsAsFactors = FALSE, scipen = 999)
data  <- read.csv("cleaned_tlb_tfr_1960_2024.csv")
train <- subset(data, Year<=2012); test <- subset(data, Year>=2013)
ty <- test$Year
tfr_s12 <- ts(train$TFR, start=1960, frequency=12)
tlb_s12 <- ts(train$TLB, start=1960, frequency=12)
tfr_test<-test$TFR; tlb_test<-test$TLB

eval1 <- function(series, p, seas, lambda, test){
  fit <- tryCatch(Arima(series, order=c(p,1,0), seasonal=list(order=seas,period=12),
                        lambda=lambda, method="ML"), error=function(e) NULL)
  if (is.null(fit)) return(NULL)
  np<-length(fit$coef); se<-sqrt(diag(fit$var.coef)); tt<-coef(fit)/se
  png(tempfile(fileext=".png")); cr<-tryCatch(suppressWarnings(checkresiduals(fit,plot=FALSE)),error=function(e)NULL); dev.off()
  if (is.null(cr)) return(NULL)
  r<-as.numeric(residuals(fit)); r<-r[is.finite(r)]; n<-length(r); ci<-1.96/sqrt(n)
  cross<-which(abs(acf(r,lag.max=36,plot=FALSE)$acf[,1,1][-1])>ci)
  fc<-forecast(fit,h=length(test),biasadj=FALSE); e<-as.numeric(test)-as.numeric(fc$mean)
  mar <- if(length(fit$model$theta)) min(Mod(polyroot(c(1,fit$model$theta)))) else NA
  data.frame(model=sprintf("(%d,1,0)(%d,%d,%d)",p,seas[1],seas[2],seas[3]),
    np=np, AIC=round(AIC(fit),1), LBp=round(cr$p.value,3), spike=paste(cross,collapse=","),
    white=(cr$p.value>0.05 && length(cross)==0),
    MAPE=round(mean(abs(e/as.numeric(test)))*100,2), RMSE=round(sqrt(mean(e^2)),0),
    nsig=sum(abs(tt)>1.96), minMAroot=ifelse(is.na(mar),NA,round(mar,2)), stringsAsFactors=FALSE)
}
scan <- function(series,lambda,test,tag){
  cat("\n==========",tag,"==========\n")
  rows<-list()
  for (seas in list(c(1,1,0),c(0,1,1),c(1,1,1),c(1,0,0)))
    for (p in 1:13){ r<-eval1(series,p,seas,lambda,test); if(!is.null(r)) rows[[length(rows)+1]]<-r }
  df<-do.call(rbind,rows)
  w<-df[df$white,]
  cat("-- ALL viable (white) models, sorted by test MAPE --\n")
  print(w[order(w$MAPE),], row.names=FALSE)
}
scan(tlb_s12, NULL, tlb_test, "TLB")
scan(tfr_s12, 0,    tfr_test, "TFR (log)")

# ---- (3) forecast-path diagnosis for TLB ------------------------------------
cat("\n========== TLB forecast paths vs ACTUAL ==========\n")
paths <- function(seas,p,lab){
  fit<-Arima(tlb_s12,order=c(p,1,0),seasonal=list(order=seas,period=12),method="ML")
  m<-round(as.numeric(forecast(fit,h=12,biasadj=FALSE)$mean))
  cat(sprintf("%-26s: %s\n",lab,paste(m,collapse=" ")))
}
cat(sprintf("%-26s: %s\n","YEAR", paste(ty,collapse=" ")))
cat(sprintf("%-26s: %s\n","ACTUAL", paste(tlb_test,collapse=" ")))
paths(c(1,1,0),4,"(4,1,0)(1,1,0) low-p")
paths(c(1,1,0),13,"(13,1,0)(1,1,0) high-p")
paths(c(0,1,1),4,"(4,1,0)(0,1,1) airline")
cat("\nNote: training TLB 2001-2012 (what D=1 forecasts inherit, lag 12):\n")
print(setNames(train$TLB[train$Year>=2001], train$Year[train$Year>=2001]))
