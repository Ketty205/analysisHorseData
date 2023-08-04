dataset <- read.csv(file = 'Horse Racing Results.CSV', header = TRUE, sep = ";", stringsAsFactors = F)
##Promena imena kolone Dato u Date
names(dataset)[names(dataset) == "Dato"] <- "Date"
names(dataset)


#konvertovanje karakterne prom u datum
dataset$Date <- as.factor(dataset$Date)
str(dataset$Date)
head(dataset$Date)
library(lubridate)
dataset$Date <- ymd(dataset$Date, format='%y-%m-%d')
