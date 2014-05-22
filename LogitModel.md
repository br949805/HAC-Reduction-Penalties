Analyzing HAC Reduction Penalty Likelihood Using Logistic Regression
========================================================




## Background

As an addition to the hospital readmissions reduction program (HRRP) and the value-based purchasing program (VBP), the third of the Affordable Care Act's quality incentive programs, the hospital acquired-condition (HAC) reduction program, is set to hit hospitals beginning in FY 2015...

Recently released preliminary data from CMS' FY2015 Inpatient Prospective Payment Proposed rule indicate that 772 hospitals will be penalized under the program with a one percent reduction in hospital payments from the Centers for Medicare & Medicaid Services...

## Analysis

The Essential Hospitals Institute... 


```r
table(cmi_hac_aha$PENALIZED.BINARY, cmi_hac_aha$MAPP8.BINARY)
```

```
##    
##        0    1
##   0 2442  118
##   1  609  134
```

```r
chisq.test(cmi_hac_aha$PENALIZED.BINARY, cmi_hac_aha$MAPP8.BINARY)
```

```
## 
## 	Pearson's Chi-squared test with Yates' continuity correction
## 
## data:  cmi_hac_aha$PENALIZED.BINARY and cmi_hac_aha$MAPP8.BINARY
## X-squared = 145.4, df = 1, p-value < 2.2e-16
```

```r

cmi_hac_aha$MEMBER <- ifelse(cmi_hac_aha$PROVIDER_NUMBER %in% mem$PROVIDER_NUMBER, 
    1, 0)
chisq.test(cmi_hac_aha$PENALIZED.BINARY, cmi_hac_aha$MEMBER)
```

```
## 
## 	Pearson's Chi-squared test with Yates' continuity correction
## 
## data:  cmi_hac_aha$PENALIZED.BINARY and cmi_hac_aha$MEMBER
## X-squared = 52.41, df = 1, p-value = 4.504e-13
```

```r
table(cmi_hac_aha$PENALIZED.BINARY, cmi_hac_aha$MEMBER)
```

```
##    
##        0    1
##   0 2500   60
##   1  683   60
```






```r
logit.model <- glm(PENALIZED.BINARY ~ ADC + MCR_PCT + DSHPCT + MAPP8.BINARY + 
    MAPP5.BINARY, family = binomial(logit), data = cmi_hac_aha)
summary(logit.model)
```

```
## 
## Call:
## glm(formula = PENALIZED.BINARY ~ ADC + MCR_PCT + DSHPCT + MAPP8.BINARY + 
##     MAPP5.BINARY, family = binomial(logit), data = cmi_hac_aha)
## 
## Deviance Residuals: 
##    Min      1Q  Median      3Q     Max  
## -1.566  -0.696  -0.621  -0.504   2.159  
## 
## Coefficients:
##               Estimate Std. Error z value Pr(>|z|)    
## (Intercept)  -0.805492   0.189832   -4.24  2.2e-05 ***
## ADC           0.000603   0.000380    1.59     0.11    
## MCR_PCT      -1.855832   0.342948   -5.41  6.3e-08 ***
## DSHPCT        0.262160   0.260025    1.01     0.31    
## MAPP8.BINARY  1.010679   0.174341    5.80  6.7e-09 ***
## MAPP5.BINARY  0.137411   0.106871    1.29     0.20    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 3436.3  on 3222  degrees of freedom
## Residual deviance: 3263.0  on 3217  degrees of freedom
##   (80 observations deleted due to missingness)
## AIC: 3275
## 
## Number of Fisher Scoring iterations: 4
```

```r

x <- with(logit.model, null.deviance - deviance)

plot(logit.model$fitted)
```

![plot of chunk Regression Model](figure/Regression_Model1.png) 

```r

round(1 - pchisq(173.3525, df = 5), 4)
```

```
## [1] 0
```

```r

library(popbio)
```

```
## Loading required package: quadprog
```

```r
logi.hist.plot(cmi_hac_aha$DSHPCT, cmi_hac_aha$PENALIZED.BINARY, boxp = FALSE, 
    type = "hist", col = "gray")
```

![plot of chunk Regression Model](figure/Regression_Model2.png) 



