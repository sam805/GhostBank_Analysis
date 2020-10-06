# Tyler Moore
# R code for analyzing closed bank domains
# Paper http://lyle.smu.edu/~tylerm/fc14ghosts.pdf
# Last modified 2014-05-20


#data for manual classification of bank websites based on screenshots
bankclass <-read.table('dbclass2.csv',sep = ',',header=T)

#data on domain creation date parsed from WHOIS records
credate <- read.table('creationdate.csv',sep = ',',header=T)

credate$bank<-paste("www.",credate$bank,sep="")
bankclasscre<-merge(bankclass,credate,by = "bank",all.x=T)

#data from FDIC on banks, manually cleaned to only include closed banks
fdic<-read.table('fdic-closed.csv',sep = ',',header=T)

#data on domain creation, update and expiration dates parsed from WHOIS records
expiry <- read.table('expirydates.csv',sep = ',',header=T)
expiry$domain <- paste("www.",expiry$domain,sep="")

#merge imported datasetsdatasets
deadclass1<-merge(fdic,bankclasscre,by.x="WEBADDR",by.y="bank")
deadclass<-merge(deadclass1,expiry,by.x="WEBADDR",by.y="domain",all.x=T)

#Construct derivative attributes
deadclass$closedate <- as.Date(deadclass$ENDEFYMD,"%m/%d/%Y")
deadclass$domcreatedate <- as.Date(deadclass$creationdate,"%m/%d/%Y")
deadclass$update <- as.Date(deadclass$update,"%Y-%m-%d")
deadclass$expire <- as.Date(deadclass$expire,"%Y-%m-%d")

deadclass$dt<-as.character(deadclass$deadtype)
deadclass$dt<-rep("DEAD",length(deadclass$deadtype))
deadclass$dt[deadclass$deadtype=='parked']<-'PARK'
deadclass$dt[deadclass$deadtype=='parked-ads']<-'PARK'
deadclass$dt[deadclass$deadtype=='malware']<-'MALWARE'
deadclass$dt[deadclass$deadtype=='bank']<-'BANK'
deadclass$dt[deadclass$deadtype=='bank-interstitial']<-'BANK'
deadclass$dt[deadclass$deadtype=='redir2alive']<-'BANK'
deadclass$dt[deadclass$deadtype=='reuse']<-'REUSE'
deadclass$dt<-as.factor(deadclass$dt)

deadclass$why<-as.character(deadclass$CHANGEC1)
deadclass$why<-rep("Merged w/o\nAssistance",length(deadclass$why))
deadclass$why[deadclass$CHANGEC1=='230']<-'Collapsed'
deadclass$why[deadclass$CHANGEC1=='240']<-'Collapsed'
deadclass$why[deadclass$CHANGEC1=='211']<-'Merged w/\nAssistance'
deadclass$why[deadclass$CHANGEC1=='215']<-'Merged w/\nAssistance'
deadclass$why<-as.factor(deadclass$why)

deadclass$closedate <- as.Date(deadclass$ENDEFYMD,"%m/%d/%Y")
deadclass$daysclosed <- (as.Date("2013-05-31")-deadclass$closedate)
deadclass$yrsclosed <- (as.Date("2013-05-31")-deadclass$closedate)/365.
deadclass$yrsclosedn<-as.numeric(deadclass$yrsclosed)

deadclass$closeyr <- cut(deadclass$closedate,breaks="year")
deadclass$bankowned <- deadclass$bankwhois|deadclass$bankredir|deadclass$dt=="BANK"

deadclass$pc<-as.character(deadclass$deadtype)
deadclass$pc<-rep("Inoperable (non-bank)",length(deadclass$deadtype))
#the bank classification isn't quite right because of the imposter banks are included, will have to deal with this
deadclass$pc[deadclass$bankowned&deadclass$dt=="BANK"]<-'Operable (bank-held)'
deadclass$pc[deadclass$bankowned&deadclass$dt!="BANK"]<-'Inoperable (bank-held)'
deadclass$pc[deadclass$deadtype=='parked-ads']<-'Parking ads'
deadclass$pc[deadclass$deadtype=='malware']<-'Malware'
deadclass$pc[deadclass$deadtype=='reuse']<-'Other reuse'
deadclass$pc[!deadclass$registered]<-'Unregistered'
deadclass$pc<-factor(deadclass$pc,ordered=T,levels=rev(c("Operable (bank-held)",'Inoperable (bank-held)',"Inoperable (non-bank)","Parking ads","Other reuse","Malware",'Unregistered')))
deadclass$bankgrp<-as.factor(ifelse(deadclass$pc=="Operable (bank-held)"|deadclass$pc=="Inoperable (bank-held)","bankheld","notbankheld"))
dw <- unique(deadclass[,c('WEBADDR','pc','bankgrp')])


#Figure 1
setEPS()
postscript("domuse.eps",height=3.7,width=9)
par(mar=c(4,10,0,2))
barplot(table(dw$pc)/length(dw$pc)*100,horiz=T,angle=rev(c(45,45,135,135,135,135,135)),density=rev(c(6,6,3,3,3,3,3)),col=c('red','red','red','red','red','blue','blue'),border=T,las=1,xlim=c(0,30),xlab="% of all closed bank websites",cex.lab=1.2,cex.axis=1.2)
legend("bottomright",col=c("blue","red"),legend=c("Bank-held","Not bank-held"),lty="solid")
dev.off()

#find those bank-held sites that have not changed since after closure but still expire in the future.
bankheld<-deadclass[deadclass$bankgrp=="bankheld",]
length(bankheld$dt[bankheld$update<bankheld$closed])
length(bankheld$dt[bankheld$update>bankheld$closed])

#Figure 2
postscript("bankown.eps",height=3.5,width=9)
par(mar=c(4,4,1.5,0))
barplot(100*prop.table(table(deadclass$bankowned,deadclass$closeyr),2)[2,],names.arg=seq(2003,2013),ylim=c(0,100),xlab="Year of bank closure",ylab="% of websites held by banks",cex.lab=1.2,cex.axis=1.2)
dev.off()

#Figure 3
postscript("domage.eps",height=3.7,width=9)
par(mar=c(4,12,0.5,2))
boxplot(yrsclosedn~pc,data=deadclass,horizontal=T,las=T,col=c('red','red','red','red','red','blue','blue'),xlab="Years since bank closed",cex.lab=1.2,cex.axis=1.2)
dev.off()

#Figure 4
postscript("atrisk.eps",height=3.5,width=9)
par(mar=c(4,4,1,0))
bankheld$expireyr <- cut(bankheld$expire,breaks="year")
barplot(table(bankheld$expireyr[bankheld$update<bankheld$closed]),border=T,las=2,names.arg=seq(2013,2023),xlab='# at-risk bank domains',ylab='Year of expiration')
dev.off()

# Use bank deposits as a proxy for bank size
deadclass$deposits<-as.numeric(gsub(",","", as.character(deadclass$DEP)))+1
deadclass$depf<-cut(deadclass$deposits,breaks=c(1,100000,1000000,999999999999),labels=c("Dep.<$100M","$100M<Dep.<$1B","Dep.>$1B"))

#consolidate to unregistered, non-bank reg and bank reg
deadclass$pc2<-as.character(deadclass$pc)
deadclass$pc2[deadclass$bankowned]<-'Bank-held'
deadclass$pc2[deadclass$pc=='Parking ads'|deadclass$pc=='Malware'|deadclass$pc=='Inoperable (non-bank)'|deadclass$pc=='Other reuse']<-'Not\nbank-held'
deadclass$pc2[!deadclass$registered]<-'Unreg.'
deadclass$pc2<-factor(deadclass$pc2,ordered=T,levels=rev(c("Bank-held",'Not\nbank-held','Unreg.')))

deadclass$resurrected<-ifelse(deadclass$domcreatedate>deadclass$closedate&!is.na(deadclass$domcreatedate),"Domain\nresurrected","Domain not\nresurrected")


# Kruskal-Wallis Test and Wilcoxon Test for Table 1
library(coin)
attach(deadclass)
kruskal_test(yrsclosedn ~ factor(pc,ordered=F), data = deadclass, distribution=approximate(B=999))
detach(deadclass)
# Table 1
pairwise.wilcox.test(deadclass$yrsclosedn,deadclass$pc)


#Table 2
rtbl<-table(deadclass$pc2,deadclass$resurrected)
t(rtbl)
100*prop.table(t(rtbl),2)
rtbl.depf<-table(deadclass$pc2,deadclass$depf)
t(rtbl.depf)
100*prop.table(t(rtbl.depf),2)
rtbl.why<-table(deadclass$pc2,deadclass$why)
t(rtbl.why)
100*prop.table(t(rtbl.why),2)

#Logistic regressions
deadclass$abandoned<-ifelse(deadclass$pc2!="Bank-held",1,0)
deadclass$failed<-ifelse(deadclass$why!="Merged w/o\nAssistance",T,F)
banklogita<-glm(abandoned~log(deposits)+failed+yrsclosedn,data=deadclass,family = binomial(link="logit"))
summary(banklogita)
cbind(coef(banklogita),exp(cbind(OR = coef(banklogita), confint(banklogita))))
with(banklogita, null.deviance - deviance)
with(banklogita, pchisq(null.deviance - deviance, df.null - df.residual, lower.tail = FALSE))

ab<-deadclass[deadclass$abandoned==1,]
ab$reg<-ifelse(ab$pc2!="Unreg.",T,F)
banklogitr<-glm(reg~log(deposits)+failed+yrsclosedn,data=ab,family = binomial(link="logit"))
summary(banklogitr)
cbind(coef(banklogitr),exp(cbind(OR = coef(banklogitr), confint(banklogitr))))
with(banklogitr, null.deviance - deviance)
with(banklogitr, pchisq(null.deviance - deviance, df.null - df.residual, lower.tail = FALSE))