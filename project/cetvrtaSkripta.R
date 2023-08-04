#######Satisticke tehnike za poredjenje grupa######

#Podaci nisu normalno rasporednjeni, pretpostavka o homogenosti varijanse
#kao sto je ranije pokazano nije zadovoljenam a podaci se su mereni na nominalnim(kategorijskim)
#i ordinalnim skalama(ciji iznosi se mogu rangirati) sto ih cini idealnim za neparametarske tehnike


### 1. Hi-kvadrat ###

#1.za ispitivanje kvaliteta podudaranja-istrazuje proporciju slucajeva koji spadaju u razne kategorije
#JEDNE prom. i poredi ih sa hipotetickim vrednostima tih proporcija,
#Ova metoda ne moze da se sprovede zato sto u podacima nema odgovarajuce hipoteticke proporcije
#(npr. promenljiva 3% koji su prvo mesto, 10%drugo mesto...41% je cetrnaesto mesto u trci)

#2.za testiranje nezavsnosti-je uradjena u trecaSkripta.R

###  2. Man-Vitnijev test###

#Upotrebljava se za ispitivanj dve nezavisne grupe na neprekidnoj skali

###Pr.istrazivackog pitanja: Da li se oni koji su prvi i onih koji su neko od preostalih mesta 
# na trci razlikuju po tezini jokeja koji upravlja konjem?

##Ovaj test je neparametrska alternativa t-testu, i umesto srednih vrednosti poredi medijane.
#Dobijene vrednosti neprekidne promenljive pretvara u rangove za obe grupe i potom izracunava 
#da li se rangovi tih grupa znacajno razlikuju


data1 <- read.csv('HorseRacingResultFinall.csv', header = TRUE, sep = ',', stringsAsFactors = T)
str(data1)

#Potrebna je jedna kategorijska prom, prvo mesto-Yes, ostala mesta No,
#jedna neprekidna Jockey.weight
data1$dependent <- ifelse(test = data1$Final.place!=1,
                          yes = 'No',
                          no='Yes')
data1$dependent <- as.factor(data1$dependent)
summary(data1$dependent)

res1 <- wilcox.test(Jockey.weight~ dependent,
                   data = data1,
                   exact = FALSE)
res1

##Dobijena vrednost p = 1.6e-12<0.05. Iznos verovatnoce p je manji,nulta hipoteza se odbacuje
##Moze se zakljuciti da distribucija tezine jokeja kod prvo plasinanih i onih koji to nisu nije ista.


###  3. Vilkoksonov test ranga ###

#Namenjen je za ponovljena merenja, tj. kada se subjekti mere u dav navrata ili pod dva razlicita uslova
##Neparametarska je alternativa t-testu ponovljenih merenja ali umesto mean, pretvara rezultate
## u rangove i poredi ih u trenutku 1 i u trenutku 2


#Analiza nece biti sprovedena zato sto podaci nisu odgovarajuci


### 4. Kruskal-Volsov test ###

##Neparam. alternativa jednofaktorskoj analizi varijanse razlcitih grupa. Sluzi za poredjenje
##rezultata neke neprekidne prom. za tri ili vise grupa. Rezultati se porede u rangove
##pa se porede srednji rangovi svake grupe

##Pr.i.p.: Ima li razlike u nivoima osvojene novcane nagrade menju konjuma koji pripadaju
##trima starosnim grupama?


##Potrebne su: jedna kategorijska prom. s tri ili vise grupa(Horse.age) i neprekidna(Prize.money)
data1$Horse.age <- as.numeric(data1$Horse.age)
data1$Prize.money <- as.numeric(data1$Prize.money)

to.descrete1 <- c("Horse.age","Prize.money")
library(bnlearn)
discretized1 <- discretize(data=data1[,to.descrete1],
                           method= 'quantile',
                           breaks= c(3,5))
summary(discretized1)
##Bice upotrebnjena kategorijska nezavisna prom. godine konjai neprekidna zavisna iznos novcane nagrade
discretized1
kruskal.test(Prize.money ~ Horse.age, data = discretized1)


##Kruskal-Volisov test je otkrio stat. znacajnu razliku nivoa osvojene novcane negrade medju tri
##starosne grupe konja(Gp1, n=9594, [2-4]; Gp2, n=11723, (4,6];Gp3, n=5671, (6,12)), p< 2.2e-16


### 5. Fridmanov test ###

##Neparametarska alternativa  jednofaktorkoj analizi varijanse ponovljenih merenja. Upotrebljava se 
##kada se uzme ISTI uzorak subjekata ili slucajeva i izmere u tri ili vise navrata ili pod tri razlicita uslova
#Analiza nece biti sprovedena zato sto podaci nisu odgovarajuci
