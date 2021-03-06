library(SmoothHazard)
library(lava)
set.seed(17)
u <- idmModel(K=10,schedule=15,punctuality=1/20)
distribution(u,"lifetime") <- coxWeibull.lvm(scale=1/120,shape=1)
regression(u,from="X",to="lifetime") <- log(2)
regression(u,from="X",to="waittime") <- log(2)
testdat1 <- sim(u,500)
plot(prodlim(Hist(lifetime,event)~1,data=testdat1),xlim=c(0,200))
u <- idmModel(K=10,schedule=15,punctuality=1/20)
distribution(u,"lifetime") <- coxWeibull.lvm(scale=1/120000,shape=2.5)
## distribution(u,"waittime") <- coxWeibull.lvm(scale=1/120000,shape=2.5)

## distribution(u,"waittime") <- coxExponential.lvm(scale=1/120)
distribution(u,"waittime") <- coxWeibull.lvm(scale=1/120,shape=1.5)
distribution(u,"illtime") <- coxWeibull.lvm(scale=1/120,shape=1.5)
regression(u,from="X",to="illtime") <- 1
regression(u,from="X",to="lifetime") <- log(2)
regression(u,from="X",to="waittime") <- -log(2)

plot(prodlim(Hist(lifetime,event)~1,data=testdat1),col=2,add=TRUE)

set.seed(173)
testdat1 <- sim(u,500)
system.time(tmp <- idm(formula02=Hist(time=lifetime,event=status)~X,
           formula01=Hist(time=list(L,R),event=ill)~X,
           data=testdat1,
           conf.int=FALSE,
           intensities="Weib"))
system.time(tmp1 <- idm(formula02=Hist(time=lifetime,event=status)~X,
           formula01=Hist(time=illtime,event=ill)~X,
           data=testdat1,
           conf.int=FALSE,
           intensities="Weib"))


set.seed(173)
testdat1 <- sim(u,200)
system.time(tmp <- idm(formula02=Hist(time=lifetime,event=status)~X,
           formula01=Hist(time=list(L,R),event=ill)~X,
           data=testdat1,
           conf.int=FALSE,
           intensities="Splines"))

write.csv(testdat1,file="~/tmp/testdat1.csv")
system.time(tmp1 <- idm(formula02=Hist(time=lifetime,event=status)~X,
                        formula01=Hist(time=illtime,event=ill)~X,
                        data=testdat1,
                        conf.int=FALSE,
                        n.knots=c(7,7,7),
                        kappa=c(100,100,100),
                        intensities="Splines"))
system.time(tmp2 <- idm(formula02=Hist(time=lifetime,event=status)~X,
                        formula01=Hist(time=list(L,R),event=ill)~X,
                        data=testdat1,
                        conf.int=FALSE,
                        n.knots=c(7,7,7),
                        kappa=c(100,100,100),
                        intensities="Splines"))


set.seed(17)
u <- idmModel(K=10,schedule=15,punctuality=1/20)
distribution(u,"lifetime") <- coxWeibull.lvm(scale=1/120000,shape=2.5)
distribution(u,"waittime") <- coxWeibull.lvm(scale=1/120000,shape=2.5)
regression(u,from="X",to="lifetime") <- log(2)
regression(u,from="X",to="waittime") <- log(2)
testdat1 <- sim(u,50)

system.time(stmp1 <- idm(formula02=Hist(time=lifetime,event=status)~X,
                         formula01=Hist(time=illtime,event=ill)~X,
                         data=testdat1,
                         CV=TRUE,
                         maxiter=200,
                         n.knots=c(7,7,7),
                         intensities="Splines"))

system.time(stmp2 <- idm(formula02=Hist(time=lifetime,event=status)~X,
                         formula01=Hist(time=illtime,event=ill)~X,
                         data=testdat1,
                         knots="quantiles",
                         n.knots=c(2,2,2),
                         intensities="Splines"))

Rprof()
testdat1 <- sim(u,50)

## testdat1$ill[!is.na(testdat1$illtime)]
## testdat1$illtime[testdat1$ill==0] <- 200
system.time(tmp <- idm(formula02=Hist(time=lifetime,event=event!=0)~X,
                       formula01=Hist(time=illtime,event=ill)~X,
                       data=testdat1,
                       igraph=0,
           intensities="Weib"))

## testdat1$illtime[is.na(testdat1$illtime)] <- NA
system.time(tmp <- idm(formula02=Hist(time=lifetime,event=event!=0)~X,
           formula01=Hist(time=illtime,event=ill)~X,
           data=testdat1,
           intensities="Splines"))

Rprof(NULL)
summaryRprof()

testdat1$L <- testdat1$illtime
testdat1$R <- testdat1$illtime
tmp <- idm(formula02=Hist(time=lifetime,event=event!=0)~X,
           formula01=Hist(time=list(L,R),event=ill)~X,
           data=testdat1,
           intensities="Weib")


data(Paq1000)
Paq1000$X <- rnorm(NROW(Paq1000))
fit.weib <- idm(formula02=Hist(time=t,event=death,entry=t0)~X,
                formula01=Hist(time=list(l,r),event=dementia)~X,
                data=Paq1000)

mod <- idmModel(K=5,schedule=10,punctuality=5)
regression(mod,from="X",to="lifetime") <- p$b02
regression(mod,from="X",to="waittime") <- p$b02
regression(mod,from="X",to="illtime") <- p$b01
dat <- sim(mod,1000)
summary(dat[dat$ill==1,"R"]-dat[dat$ill==1,"L"])

scenario <- expand.grid(N=c(50,250,500),b01=c(log(2)),b02=c(0,log(2)),K=c(5,10),schedule=c(5,35),punctuality=1/20)
do.call("rbind",lapply(1:NROW(scenario),function(i){
    p <- scenario[i,,drop=FALSE]
    mod <- idmModel(K=p$K,schedule=p$schedule,punctuality=p$punctuality)
    regression(mod,from="X",to="lifetime") <- p$b02
    regression(mod,from="X",to="waittime") <- p$b02
    regression(mod,from="X",to="illtime") <- p$b01
    dat <- sim(mod,p$N)
    summary(dat[dat$ill==1,"R"]-dat[dat$ill==1,"L"])
}))



f <- function(x,N){
    tic()
    inner <- foreach(s = 1:N) %dopar% {
        setwd("~/research/SoftWare/SmoothHazard/manuscript/avakas/")
        source("R/tictoc.R")
        toc()
    }
    inner
}
f(1,3)
