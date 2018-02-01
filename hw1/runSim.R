## parsing command arguments
for (arg in commandArgs(TRUE)) {
  eval(parse(text=arg))
}

## check if a given integer is prime
isPrime = function(n) {
  if (n <= 3) {
    return (TRUE)
  }
  if (any((n %% 2:floor(sqrt(n))) == 0)) {
    return (FALSE)
  }
  return (TRUE)
}

## estimate mean only using observation with prime indices
estMeanPrimes = function (x) {
  n = length(x)
  ind = sapply(1:n, isPrime)
  return (mean(x[ind]))
}

# simulate data
x = rnorm(n)

# estimate mean
y = estMeanPrimes(x)

#seed, n, dist, rep

data_s<-list(length = rep)
est<-matrix(NA, 50,3)


for (i in 1:rep){
  if (dist == 'gaussian'){
    data_s[[i]]<-rnorm(n)
    est[i,1]<-estMeanPrimes(data_s[[i]])
    est[i,2]<-mean(data_s[[i]])
  }
  else if (dist == 't1'){
    data_s[[i]]<-rt(n,df = 1)
    est[i,1]<-estMeanPrimes(data_s[[i]])
    est[i,2]<-mean(data_s[[i]])
  }
  else if (dist == 't5'){
    data_s[[i]]<-rt(n,df = 5)
    est[i,1]<-estMeanPrimes(data_s[[i]])
    est[i,2]<-mean(data_s[[i]])
  }
}

MSE1<-(sum(est[1]^2))/50 #mean primes
MSE2<-(sum(est[2]^2))/50 #classical
allMSE<-data.frame(MSE1,MSE2) 
allMSE

