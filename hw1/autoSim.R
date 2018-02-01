# autoSim.R
rep<-50
seed<-280

nVals <- seq(100, 500, by=100)
dists <-c('gaussian', 't1', 't5')
for (n in nVals){ 
  for (dist in dists){
  oFile <- paste0("n", n, "dist", dist, ".txt")
  dist_i <-paste("dist=", "'", dist, "'", sep = "")
  arg <- paste("n=", n, sep=""," \"", dist_i, " \""," seed=280", " rep=50")
  sysCall = paste("nohup Rscript runSim.R ",arg, " > ", oFile)
  system(sysCall)
  print(paste("sysCall=", sysCall, sep=""))
}}



