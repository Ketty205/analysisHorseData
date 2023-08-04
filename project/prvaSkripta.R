data <- read.csv(file = 'Horse Racing Results.CSV', header = TRUE, sep = ";", stringsAsFactors = F)

##podaci su preuzeti sa sajta Kaggle, 28.07.2023, dostupni su na linku: https://www.kaggle.com/datasets/bogdandoicin/horse-racing-results-2017-2020

head(data)
str(data)

##Kategorijske promenljive su:Dato(pretpostavljam greska u unosu, sadrzi datum trke)
##Track(staza na kojoj se trka vodila, u Hong Kobgu je to: 'Sha Tin or Happy Valley.')
##Surface(podloga na kojoj je trka vodjena) 'Grass or AW-All Weather'trava ili zemljana podloga na bazi peska
##JOckey-osoba koja je jahala konja, Country-zemlja odakle je konj, TrainerName, RaceType.
##Dakle ukupno sedam kategorijskih promenljivih.
##preostalih 14 su numericke.

##Izdvajanje kategorijskih prom.
cat.vars <- data[,c(2,5,8,10,12,18)]
cat.vars
str(cat.vars)
#Sadrze karakterni tip podatka(chr) to treba promeniti da bude factor
data1 <- as.data.frame(unclass(cat.vars),                     # Convert all columns to factor
                       stringsAsFactors = TRUE)
str(data1)
##Provera da nema na vredsnosti
apply(is.na(data1), 2, which)
num.vars <- data[,c(3,4,6,7,9,11,13,14,15,16,17,19,20,21)]
str(num.vars)
##Race time-ce biti transformisana iz karakterene u numericku sa zarezom, odnosno u sekunde
##Odds-verovatnoca pobede, sadrzi karakterni tip koji ce biti takodje transformisan u numericki

num.vars$Race.time <- as.numeric(sub(",", ".", num.vars$Race.time, fixed = TRUE))
num.vars$Odds <- as.numeric(num.vars$Odds)
str(num.vars)                                
##Promena imena kolone Dato u Date
names(data)[names(data) == "Dato"] <- "Date"
names(data)

#konvertovanje karakterne prom u datum
data$Date <- as.factor(data$Date)
str(data$Date)
tail(data$Date)

#Pravljenje novog dataframe-a sa sredjenim promenljivim

new_data <- cbind(data$Date, cat.vars, num.vars)
str(new_data)

##Ovako formiran dataframe moze se sacuvati kao dataset
write.csv(new_data, "C:/Users/pc/Desktop/mozzart/project/HorseRacingResultProcessed.csv", row.names = TRUE)
