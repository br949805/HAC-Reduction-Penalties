setwd("~/GIT Repos/HAC Reduction Penalties")
library(RODBC)
library(seqinr)
library(gmodels)

#Connect to SQL Databases and read in data
con <- odbcConnect("AHA",uid="SASUser", pwd="EHI1301a")
aha <- sqlQuery(con,"select t1.ID,MNAME, MCRNUM, MAPP8, MAPP5, t2.HOSPBD  from AS12DEM t1 inner join as12svc1 t2 on t1.id = t2.id")
odbcClose(con)
rm(con)

con <- odbcConnect("MemberList",uid="SASUser", pwd="EHI1301a")
mem <- sqlQuery(con,"select * from AEH_Current_Members")
odbcClose(con)
rm(con)

con <- odbcConnect("IPPSData",uid="SASUser", pwd="EHI1301a")
cmi <- sqlQuery(con,"select PROVIDER_NUMBER, HOSPITAL, TACMIV31 from FY2014IMPACT")
odbcClose(con)
rm(con)

#Read in HAC_Data.csv; rename matching variables in data frames
names(aha) <- c("ID","MNAME","PROVIDER_NUMBER", "MAPP8", "MAPP5", "HOSPBD")
aha$bed.size <- ifelse(aha$HOSPBD >= 400,1,0)

hac <- read.csv("HAC_Data.csv")
names(hac) <- c("PROVIDER_NUMBER","PENALIZED", "SCORE")

mem <- as.data.frame(mem[,c("MCRNUM","MNAME")])
names(mem) <- c("PROVIDER_NUMBER","MNAME")


#Merge data frames
cmi_hac <- merge(hac, cmi, by="PROVIDER_NUMBER")
cmi_hac_aha <- merge(cmi_hac, aha, by="PROVIDER_NUMBER")


#Recode PENALIZED Variable

for(i in 1:nrow(cmi_hac_aha)) {
  if(cmi_hac_aha$PENALIZED[i] == "Y"){
    cmi_hac_aha$PENALIZED.BINARY[i] <- 1
  } else if(cmi_hac_aha$PENALIZED[i] == "N"){
    cmi_hac_aha$PENALIZED.BINARY[i] <- 0
  } else {
    cmi_hac_aha$PENALIZED.BINARY[i] <- NA
  }
}


#Recode MAPP8 and MAPP5
cmi_hac_aha$MAPP8.BINARY <- ifelse(cmi_hac_aha$MAPP8 == 2,0,1)

cmi_hac_aha$MAPP5.BINARY <- ifelse(cmi_hac_aha$MAPP5 == 2,0,1)


cmi_hac_aha$Test.Set <- sample(0:1,nrow(cmi_hac_aha), replace=TRUE)
#Combine as Teaching

cmi_hac_aha$TEACHING <- ifelse(cmi_hac_aha$MAPP8.BINARY == 1,1,0)


chisq.test(cmi_hac_aha$PENALIZED.BINARY, cmi_hac_aha$TEACHING)
table(cmi_hac_aha$PENALIZED.BINARY, cmi_hac_aha$TEACHING)

chisq.test(cmi_hac_aha$PENALIZED.BINARY, cmi_hac_aha$bed.size)
table(cmi_hac_aha$PENALIZED.BINARY, cmi_hac_aha$bed.size)

cmi_hac_aha$MEMBER <- ifelse(cmi_hac_aha$PROVIDER_NUMBER %in% mem$PROVIDER_NUMBER,"MEMBER","NON-MEMBER")
chisq.test(cmi_hac_aha$PENALIZED.BINARY, cmi_hac_aha$MEMBER)
table(cmi_hac_aha$PENALIZED.BINARY, cmi_hac_aha$MEMBER)

cmi_hac_aha$bed.size.text <- ifelse(cmi_hac_aha$bed.size == 1,">= 400 Beds","< 400 Beds")
boxplot(cmi_hac_aha$SCORE ~ cmi_hac_aha$bed.size.text, main="Hospitals Size vs Total HAC Score", ylab="Scores")
abline(h=7, col="red")
text(c(0,6.05),paste("Median: ",median(cmi_hac_aha$SCORE[cmi_hac_aha$bed.size == 1],)))
text(4.85,paste("Median: ",median(cmi_hac_aha$SCORE[cmi_hac_aha$bed.size == 0],)))
rect(0,7,4,11, col=col2alpha("red", alpha = 0.2))
text(1.5,9,"Penalized", cex=1.5)

cmi_hac_aha$TEACHING <- ifelse(cmi_hac_aha$MAPP8.BINARY == 1 ,"Teaching","Other")
boxplot(cmi_hac_aha$SCORE ~ cmi_hac_aha$TEACHING,  main="Teaching Status vs Total HAC Score", ylab="Scores")
abline(h=7, col="red")
text(c(0,6.7),paste("Median: ",median(cmi_hac_aha$SCORE[cmi_hac_aha$TEACHING == "Teaching"],)))
text(4.85,paste("Median: ",median(cmi_hac_aha$SCORE[cmi_hac_aha$TEACHING ==  "Other"],)))
rect(0,7,4,11, col=col2alpha("red", alpha = 0.2))
text(1.5,9,"Penalized", cex=1.5)

boxplot(cmi_hac_aha$SCORE ~ cmi_hac_aha$MEMBER, main="Member vs Non-Member Total HAC Score", ylab="Scores")
abline(h=7, col="red")
text(c(0,5),paste("Median: ",median(cmi_hac_aha$SCORE[cmi_hac_aha$MEMBER == "NON-MEMBER"],)))
text(6.7,paste("Median: ",median(cmi_hac_aha$SCORE[cmi_hac_aha$MEMBER == "MEMBER"],)))
rect(0,7,4,11, col=col2alpha("red", alpha = 0.2))
text(1.5,9,"Penalized", cex=1.5)

for(i in 1:nrow(cmi_hac_aha)) {
  if(cmi_hac_aha$TACMIV31[i] >= 1.664){
    cmi_hac_aha$CMI.TIER[i] <- 4
  } else if(cmi_hac_aha$TACMIV31[i] >= 1.460){
    cmi_hac_aha$CMI.TIER[i] <- 3
  } else if(cmi_hac_aha$TACMIV31[i] >= 1.269){
    cmi_hac_aha$CMI.TIER[i] <- 2
  } else {
    cmi_hac_aha$CMI.TIER[i] <- 1
  }
}


for(i in 1:nrow(cmi_hac_aha)) {
  if(cmi_hac_aha$TACMIV31[i] >= 1.664){
    cmi_hac_aha$CMI.TIER.TOP[i] <- 1
  }  else {
    cmi_hac_aha$CMI.TIER.TOP[i] <- 0
  }
}


oddsratioWald.proc <- function(n00, n01, n10, n11, alpha = 0.05){
  #
  #  Compute the odds ratio between two binary variables, x and y,
  #  as defined by the four numbers nij:
  #
  #    n00 = number of cases where x = 0 and y = 0
  #    n01 = number of cases where x = 0 and y = 1
  #    n10 = number of cases where x = 1 and y = 0
  #    n11 = number of cases where x = 1 and y = 1
  #
  OR <- (n00 * n11)/(n01 * n10)
  #
  #  Compute the Wald confidence intervals:
  #
  siglog <- sqrt((1/n00) + (1/n01) + (1/n10) + (1/n11))
  zalph <- qnorm(1 - alpha/2)
  logOR <- log(OR)
  loglo <- logOR - zalph * siglog
  loghi <- logOR + zalph * siglog
  #
  ORlo <- exp(loglo)
  ORhi <- exp(loghi)
  #
  oframe <- data.frame(LowerCI = ORlo, OR = OR, UpperCI = ORhi, alpha = alpha)
  oframe
}


TableOR.proc <- function(x,y,alpha=0.05){
  #
  xtab <- table(x,y)
  n00 <- xtab[1,1]
  n01 <- xtab[1,2]
  n10 <- xtab[2,1]
  n11 <- xtab[2,2]
  #
  outList <- vector("list",2)
  outList[[1]] <- paste("Odds ratio between the level [",dimnames(xtab)[[1]][1],"] of the first variable and the level [",dimnames(xtab)[[2]][1],"] of the second variable:",sep=" ")
  outList[[2]] <- oddsratioWald.proc(n00,n01,n10,n11,alpha)
  outList
}



table(cmi_hac_aha$CMI.TIER.TOP,cmi_hac_aha$PENALIZED.BINARY)
TableOR.proc(cmi_hac_aha$PENALIZED.BINARY,cmi_hac_aha$CMI.TIER.TOP)

library(sqldf)

TOP <- sqldf("select * from cmi_hac_aha where [CMI_TIER_TOP] = 1")

table(TOP$PENALIZED_BINARY, TOP$bed_size_text)


TopTEACH <- sqldf("select * from cmi_hac_aha where [MAPP8] = 1")

table(TopTEACH$PENALIZED_BINARY, TopTEACH$CMI_TIER)
