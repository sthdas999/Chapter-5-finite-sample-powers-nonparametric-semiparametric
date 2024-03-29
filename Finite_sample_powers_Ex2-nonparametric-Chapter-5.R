
## R version 4.0.5 ##

## Required libraries ##
library(MASS)
library(kedd)
library(mvtnorm)
library(Matrix)
library(truncnorm)
library(npmlda)
library(stats)
library(EnvStats)
library(lattice)
library(pracma)

## Chapter 5 ##
## Finite sample simulation powers of test statistics under nonparametric regression ##
## Ex - 2 : X~U(0,1) and e|X=x =D= {(W_x-p_x)/(10*sqrt(2*p_x))} with W_x ~ chi_square_{p_x}, p_x = (1/bx), b>0 ##
## third order difference of Y ##

## Under null hypothesis H0 ##

n = 100  ## sample size ##

B = 1000  ## number of replications ##

alpha = 0.05 ## level of significance of test ##

e = rnorm(n, mean = 0, sd = 0.1)  ## generation of 100 i.i.d. errors under H0 ##

x = runif(n, 0, 1)  ## generation of 100 i,i.d. covariate values under H0 ##

mx = 0.5*x^2 - x^3  ## regression function ##

y = mx + e  ## generation of responses under H0 ##

h = 0.9 * sd(x) * (n^(-1/5))  ## bandwidth for estimation of regression function ##

m.hat = kernel.fit(seq(min(x), max(x), (max(x)-min(x))/n), x, y, Kernel = "Ep", bw = h, Wt = 1)[1:n] ## estimation of regression function ##

m.hat ## If NaN's aree produced, run from the beginning again ##

e.hat = y - m.hat ## estimation of errors ##

e.cen = e.hat - mean(e.hat) ## estimation of centered errors ##

e.cen.boot<- sample(e.cen, n, replace = T) ## resamples of centered errors from the empirical distribution function of centered error ##

y.boot<- m.hat+e.cen.boot ## resampled responses ##

x.sort <- c() ## ordered X observations ##
e.sort<- c()  ## induced cenetered errors ##
y.sort<- c()  ## induced resampled responses ##
for(i in 1:n)
{
  x.sort[i]<- x[rank(x)==i]
  e.sort[i]<- e.cen.boot[which(x==x.sort[i])]
  y.sort[i]<- y.boot[which(x==x.sort[i])]
}

y3.boot<- c()  ## third difference of induced resampled responses ##
for(i in 1:n)
{
  if(i==1)
  {
    y3.boot[i] = -y.sort[2]
  }
  else if(i==2)
  {
    y3.boot[i] = -2*y.sort[1]+3*y.sort[2]-y.sort[3]
  }
  else if(i==n)
  {
    y3.boot[i] = y.sort[n-2]-3*y.sort[n-1]+2*y.sort[n]
  }
  else
  {
    y3.boot[i] = y.sort[i-2]-3*y.sort[i-1]+3*y.sort[i]-y.sort[i+1]
  }
}

u = ecdf(x.sort)(x.sort) ## empirical CDF values of X ##
v = ecdf(y3.boot)(y3.boot) ## empirical CDF values of induced Y ##

## Critical values of KS, CM & AD test statistics ##

u.vector<- vector("list",B)
v.vector<- vector("list", B)
for(j in 1:B) {
  u.vector[[j]]<- sample(u,n,T)
  v.vector[[j]]<- sample(v,n,T)
}

## Finding empirical CDFs ##
mecdf<-function(X1,X2,z1,z2) {
  return(mean((X1<=z1 & X2<=z2)))
}

Z0.uv<- vector("list",B)  ## generation of Wiener processes of size n in B(=1000) resamples ##
for(j in 1:B)
{
  for(i in 1:n) {Z0.uv[[j]][i]<- sqrt(n)*(mecdf(u,v,u.vector[[j]][i],v.vector[[j]][i])-u.vector[[j]][i]*v.vector[[j]][i]) }
}

KS.0<- c()  ## KS values under H0 ##
for(j in 1:B)
{
  KS.0[j] = max(abs(Z0.uv[[j]]))
}
Ks.critical = quantile(KS.0, probs = 1-alpha)  ## 5% critical value of Tn,KS ##
Ks.critical

CM.0<- c()  ## CM values under H0 ##
for(j in 1:B)
{
  CM.0[j] = mean((Z0.uv[[j]])^2)
}
CM.critical = quantile(CM.0, probs = 1-alpha)  ## 5% critical value of Tn,CM ##
CM.critical

Z0.dash.uv<- vector("list",B)  ## generation of Wiener processes of size n in B(=1000) resamples ##
for(j in 1:B)
{
  for(i in 1:n) {
    if(sqrt(u.vector[[j]][i]*v.vector[[j]][i]*(1-u.vector[[j]][i])*(1-v.vector[[j]][i]))==0)
    {
      Z0.dash.uv[[j]][i]<- sqrt(n)*(mecdf(u,v,u.vector[[j]][i],v.vector[[j]][i])-u.vector[[j]][i]*v.vector[[j]][i])
    }
    else
    {
      Z0.dash.uv[[j]][i]<- sqrt(n)*(mecdf(u,v,u.vector[[j]][i],v.vector[[j]][i])-u.vector[[j]][i]*v.vector[[j]][i])/sqrt(u.vector[[j]][i]*v.vector[[j]][i]*(1-u.vector[[j]][i])*(1-v.vector[[j]][i]))
    }
  }
}

AD.0<- c()  ## AD values under H0 ##
for(j in 1:B)
{
  AD.0[j] = mean((Z0.dash.uv[[j]])^2)
}

AD.critical = quantile(AD.0, probs = 1-alpha)  ## 5% critical value of Tn,AD ##
AD.critical

###################################################################################

x.sort.B = vector("list", B)  ## covariates under H0 in B steps ##
y3.boot.B = vector("list", B)  ## responses under H0 in B steps ##
for(j in 1:B)
{
  x.sort.B[[j]] = x.sort
  y3.boot.B[[j]] = sample(y3.boot,n,T)
}

## Critical values of Tn1, Tn2 and Tn3 ##

Tn1 = function(u, v)
{
  temp = 0
  for(i in 1:(n-1))
  {
    for(j in (i+1):n)
    {
      temp = temp + sign((u[i]-u[j])*(v[i]-v[j]))
    }
  }
  return(temp/choose(n, 2))
}
Tn1.0<- c()  ## Tn1 values under H0 ##
for(j in 1:B)
{
  Tn1.0[j] = Tn1(x.sort.B[[j]],y3.boot.B[[j]])
}
Tn1.critical = quantile(Tn1.0, probs = 1-alpha)  ## 5% critical value of Tn1 ##
Tn1.critical
Tn2<-function(u,v)
{
  x<-0
  n<- length(u)
  for(i in 1:(n-3))
  {
    for(j in (i+1):(n-2))
    {
      for(k in (j+1):(n-1))
      {
        for(l in (k+1):n)
        {
          x<-x+(sign(abs(u[i]-u[j])+abs(u[k]-u[l])-abs(u[i]-u[k])-abs(u[j]-u[l]))*sign(abs(v[i]-v[j])+abs(v[k]-v[l])-abs(v[i]-v[k])-abs(v[j]-v[l])))
        }
      }
    }
  }
  return(x/choose(n,4))
}
Tn2.0<- c()  ## Tn2 values under H0 ##
for(j in 1:B)
{
  Tn2.0[j] = Tn2(x.sort.B[[j]],y3.boot.B[[j]])
}
Tn2.critical = quantile(Tn2.0, probs = 1-alpha)  ## 5% critical value of Tn2 ##
Tn2.critical
Tn3<-function(u,v)
{
  x<-0
  n<- length(u)
  for(i in 1:(n-3))
  {
    for(j in (i+1):(n-2))
    {
      for(k in (j+1):(n-1))
      {
        for(l in (k+1):n)
        {
          x<-x+(1/4)*((abs(u[i]-u[j])+abs(u[k]-u[l])-abs(u[i]-u[k])-abs(u[j]-u[l]))*(abs(v[i]-v[j])+abs(v[k]-v[l])-abs(v[i]-v[k])-abs(v[j]-v[l])))
        }
      }
    }
  }
  return(x/choose(n,4))
}  
Tn3.0<- c()  ## Tn2 values under H0 ##
for(j in 1:B)
{
  Tn3.0[j] = Tn3(x.sort.B[[j]],y3.boot.B[[j]])
}
Tn3.critical = quantile(Tn3.0, probs = 1-alpha)  ## 5% critical value of Tn3 ##
Tn3.critical

###############################################################################

e.x.b = function(b)
{ 
  if(b==0) {return(e.cen.boot)}
  else {
    df = ceiling(1/(b*x.sort))
    ch = rchisq(n, df, 0)
    den = 10*sqrt(2*df)
    l1 = ch-df
    return(l1/den)
  }
}

Power_of_test_statistics = function(b)
{
  y.boot.b = c()
  for(i in 1:n)
  {
    if(b==0) {y.boot.b[i] = m.hat+e.cen.boot}  ## For b = 0, e|X=x ~ Normal (0,0.1^2) ##
    else {y.boot.b[i] = m.hat+e.x.b(b)}
  }
  y.boot.b<- m.hat+sqrt(1+b*x)*e.cen.boot ## resampled responses ##
  y.b.sort<- c()  ## induced resampled responses ##
  for(i in 1:n)
  {
    y.b.sort[i]<- y.boot.b[which(x==x.sort[i])]
  }
  y3.boot.b<- c()  ## third difference of induced resampled responses ##
  for(i in 1:n)
  {
    if(i==1)
    {
      y3.boot.b[i] = -y.b.sort[2]
    }
    else if(i==2)
    {
      y3.boot.b[i] = -2*y.b.sort[1]+3*y.b.sort[2]-y.b.sort[3]
    }
    else if(i==n)
    {
      y3.boot.b[i] = y.b.sort[n-2]-3*y.b.sort[n-1]+2*y.b.sort[n]
    }
    else
    {
      y3.boot.b[i] = y.b.sort[i-2]-3*y.b.sort[i-1]+3*y.b.sort[i]-y.b.sort[i+1]
    }
  }
  ## Power of Kolmogorov Smirnov test statistic ##
  v.b = ecdf(y3.boot.b)(y3.boot.b) ## empirical CDF values of induced Y ##
  v.b.vector<- vector("list", B)
  for(j in 1:B) {
    v.b.vector[[j]]<- sample(v.b,n,T)
  }
  Z1.uv<- vector("list",B)  ## generation of Wiener processes of size n in B(=1000) resamples ##
  for(j in 1:B)
  {
    for(i in 1:n) {Z1.uv[[j]][i]<- sqrt(n)*(mecdf(u,v.b,u.vector[[j]][i],v.b.vector[[j]][i])-u.vector[[j]][i]*v.b.vector[[j]][i]) }
  }
  KS.alt = c()
  for(j in 1:B)
  {
    KS.alt[j] = max(abs(Z1.uv[[j]]))
  }
  Power.KS = mean(KS.alt>Ks.critical)
  ## Power of Cramer von Mises test statistic ##
  Z1.uv<- vector("list",B)  ## generation of Wiener processes of size n in B(=1000) resamples ##
  for(j in 1:B)
  {
    for(i in 1:n) {Z1.uv[[j]][i]<- sqrt(n)*(mecdf(u,v.b,u.vector[[j]][i],v.b.vector[[j]][i])-u.vector[[j]][i]*v.b.vector[[j]][i]) }
  }
  CM.alt = c()
  for(j in 1:B)
  {
    CM.alt[j] = mean((Z1.uv[[j]])^2)
  }
  Power.CM = mean(CM.alt>CM.critical)
  ## Power of Anderson Darling test statistic ##
  Z1.dash.uv = vector("list", B)
  for(j in 1:B)
  {
    for(i in 1:n) {
      if(sqrt(u.vector[[j]][i]*v.b.vector[[j]][i]*(1-u.vector[[j]][i])*(1-v.b.vector[[j]][i]))==0)
      {
        Z1.dash.uv[[j]][i]<- sqrt(n)*(mecdf(u,v.b,u.vector[[j]][i],v.b.vector[[j]][i])-u.vector[[j]][i]*v.b.vector[[j]][i])
      }
      else
      {
        Z1.dash.uv[[j]][i]<- sqrt(n)*(mecdf(u,v.b,u.vector[[j]][i],v.b.vector[[j]][i])-u.vector[[j]][i]*v.b.vector[[j]][i])/sqrt(u.vector[[j]][i]*v.b.vector[[j]][i]*(1-u.vector[[j]][i])*(1-v.b.vector[[j]][i]))
      }
    }
  }
  AD.alt = c()
  for(j in 1:B)
  {
    AD.alt[j] = mean((Z1.dash.uv[[j]])^2)
  }
  Power.AD = mean(AD.alt>AD.critical)
  #############################################################
  y3.boot.B.b = vector("list", B)
  for(j in 1:B)
  {
    y3.boot.B.b[[j]] = sample(y3.boot.b,n,replace = T)
  }
  ## Power of Tn1 ##
  Tn1.alt<- c()  ## Tn1 values under H0 ##
  for(j in 1:B)
  {
    Tn1.alt[j] = Tn1(x.sort.B[[j]],y3.boot.B.b[[j]])
  }
  Power.Tn1 = mean(Tn1.alt>Tn1.critical)
  ## Power of Tn2 ##
  Tn2.alt<- c()  ## Tn1 values under H0 ##
  for(j in 1:B)
  {
    Tn2.alt[j] = Tn2(x.sort.B[[j]],y3.boot.B.b[[j]])
  }
  Power.Tn2 = mean(Tn2.alt>Tn2.critical)
  ## Power of Tn3 ##
  Tn3.alt<- c()  ## Tn1 values under H0 ##
  for(j in 1:B)
  {
    Tn3.alt[j] = Tn3(x.sort.B[[j]],y3.boot.B.b[[j]])
  }
  Power.Tn3 = mean(Tn3.alt>Tn3.critical)
  return(cbind(Power.KS,Power.CM,Power.AD,Power.Tn1,Power.Tn2,Power.Tn3))
}

a = readline()  ## give the value of a in console ##
a = scan()  ## value of a is fixed ##

Power_of_test_statistics(a)  ## powers of test statistics for a = 0,...,10 ##

## b = seq(0,10,1)
## KS = vector Power.KS for a = 0,1,...,10
## CM = vector Power.CM for a = 0,1,...,10
## AD = vector Power.AD for a = 0,1,...,10
## T1 = vector Power.Tn1 for a = 0,1,...,10
## T2 = vector Power.Tn2 for a = 0,1,...,10
## T3 = vector Power.Tn3 for a = 0,1,...,10

## graphical representation of the power curves of T1, T2 and T3 ##


#plot(b, KS, xlim=c(0,10), ylim=c(0,1), type="l", pch=10, col="red", xlab=expression(b), ylab=expression("Finite sample powers"))
# Add a line
#lines(b, CM, xlim=c(0,10), ylim=c(0,1), pch=10, col="purple", type="l")
# Add a line
#lines(b, AD, xlim=c(0,10), ylim=c(0,1), pch=10, col="violet", type="l")
# Add a line
#lines(b, T1, xlim=c(0,10), ylim=c(0,1), pch=10, col="black", type="l")
# Add a line
#lines(b, T2, xlim=c(0,10), ylim=c(0,1), pch=10, col="green", type="l")
# Add a line
#lines(b, T3, xlim=c(0,10), ylim=c(0,1), pch=10, col="blue", type="l")
# Add a legend
#legend("bottomright",
#c(expression(paste('T'['n,KS']),paste('T'['n,CM']),paste('T'['n,AD']),paste('T'['n1']),paste('T'['n2']),paste('T'['n3']))),
#fill=c("red","purple","violet","black","green","blue"))

