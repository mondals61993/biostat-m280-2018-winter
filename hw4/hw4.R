library(sparklyr)
library(ggplot2)
library(dplyr)
Sys.setenv(SPARK_HOME="/usr/lib/spark")
config <- spark_config()
sc <- spark_connect(master = "yarn-client", config = config)
sc

flights_tbl <- tbl(sc, 'flights')
airlines_tbl <- tbl(sc, 'airlines')
airports_tbl <- tbl(sc, 'airports')

