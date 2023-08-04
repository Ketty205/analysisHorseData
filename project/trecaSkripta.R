data1 <- read.csv('HorseRacingResultFinall.csv', header = TRUE, sep = ',', stringsAsFactors = T)
str(data1)

##Statisticke tehnike za istrazivanje veza izmedju promenljivih

###### 1.Hi-kvadrat test nezavisnosti ######

## koristi se za analizu tabele ucestalosti(tj.tabele kontigencije)koju cine dve nezavisne prom.
##Procenjuje da li postoji znacajna povezanost izmedju dve kategorijske prom. (Preuzeto sa: http://www.sthda.com/english/wiki/chi-square-test-of-independence-in-r#google_vignette)

#Ho: redovi i kolone u tabeli kontigencije su nezavisni
#H1: redovi i kolone u tabeli kontigencije su zavisni

#Primer istrazivackog pitanja: Da je tip trke koji se odrzava nezavistan od jokeja koji na njoj ucestvuje?
#Zanima nas broj osoba u svakoj kategoriji(ne vrednosti na nekoj skali)

#Pravljenje dataframe-a od originalnih podataka

dataframe1 = data.frame(data1$Jockey, data1$RaceType)

#Kreiranje tabele kontigencije od odabranih promenljivih

dataframe1 = table(data1$Jockey, data1$RaceType)
print(dataframe1)

#Primena funkcije chisq.test() na tabelu kontigencije dataframe1
print(chisq.test(dataframe1))
#Dobijena vrednost p-value je manja od 0.05(odbacuje se nulta hipoteza), tako da se moze zakljuciti da su Jokej i tip trke
##zavisne promenljive- da je jokeju itekako vazno na kojem tipu trke ucestvuje, tj. da postoji korelacija izmedju ove dve promenljive.


###### 2.Korelacija ######

#Pr.istrazivackog pitanja: Postoji li veza izmedju starosti konja i nagrade koju je osvojio?
#Da li se sa povecanjem strarosti povecava i nagrada koju konj osvoji?
#Potrebne su nam dve neprekidne promenljive: trajanje trke i duzine iste

#Dijagram rasturanja se crta kao deo preliminarne analize
#On se nalazi u drugaSkripta.R
library(car)
scatterplot(Race.time ~ Distance, data = data1)
#Netipicne tacke su ispravno unete, ne treba ih izbaciti iz skupa podataka zato sto one predstsvljaju velike dobitke
#Korelacija je mala zato sto tacke su tacke lepo rasporedjene; 
# moze se povuci prava linija kroz podatke tako da pirsonovu korelaciju  treba razmatrati
#buduci na pociva na pretpostavci o linearnoj vezi izmedju promenljivih
#Smer veze je veoma tesko odrediti, buduci da grafik pokazuje zajedno rastu do odredjene vrednosti, a zatim starost kako se starost konja povecava nagrade se smanjuju
##Ne treba ignorisati i tacke koje su posvuda rasporenjene, njih cemo pripisati velicini uzorka

install.packages("ggpubr")
library("ggpubr")
res <- cor.test(data1$Race.time, data1$Distance, 
                method = "pearson")
res
#Dobijena p- vrednost < 2.2e-16, sto je manje od stat. nivoa alpha=0.05. 
#Moze se zakljuciti da su prom. Final.place i Odds znacajno korelisane sa 
#koeficijentom korelacije od . Pozitivan znak pokazuje pozitivnu korelaciju.
#Jacina veze je velika, buduci da je u opsegu [0.50,1.00]
####Predstavljanje rezultat korelacije:
#Veza izmedju  duzine i trajanja trke je istrazena pomocu Pirsonove linearne korelacije.
#Izracunata je velika pozitivna korelacija izmedju ove dve promenljive, r= 0.9976, n=26988, p< 0.05,
#pri cemu visoke vrednosti trajanjatrke prate i visoke distance.


######## 3.Linearna regresija ######
lm1 <- lm(Race.time ~ Distance, data= data1)
summary(lm1)
##Na osnovu koeficijenata(u ovom slucaju varijabla Odds) ako se poveca za jednu jedinicu verovatnoca pobede
#konja mediana vrednosti finalnogmesta ce se povecati za 0.06576 jedinica
#Na osnovu vrednosti R-squared(R2)model objasnjava 99.53% varijabiliteta vrednosti medijane finalnog plasmana
#Na osnovu povezayanosti F2 statistike i p-value vrednosti postoji znacajna linearna povezanost izmedju verovatnoce pobede i finalnogplasmana

##Jednacina linearnog modela bi bila: Y= 0.06576X + 8.591
par(mfrow=c(2,2))
plot(lm1)
##Prvi plot(Residuals vs Fitted)koristi se za proveru pretpostavke linearne zavisnosti 
#Postoji ne linearni odnos izmedju finalne pozicije i pretpostavke o verovtnoci pobede
#Drugi(Q-Q plot) govori da li su reziduali normalno rasporedjeni; vidi se odstupanje od dijagonale
#samim tim i od normalne raspodele
##Treci(Scale-Location) za proveru pretpostavke jednake varijanse reziduala(homoskedasticnosti);
##U ovom slucaju varijansa se menja, pretpostavka nije zadovoljena
##Cetvrti(Residuals vs Leverage) za uocavenje veoma visokih vrednosti, to su veoma visoke vrednosti predikcion evarijable
#Nalaze  se iznad Kukove distance (znaci da imaju viskok Cook's skore)
 
lm1.leverage <- hatvalues(lm1)
plot(lm1.leverage)
#Leverage statistika je izmedju 1/ni 1(n broj obzervacija);
#obzervacije koje su high leverage point su one cija je statistika iznad 2*(p+1)/n

n <- nrow(data1) 
p <- 1
cutoff <- 2*(p+1)/n
length(which(lm1.leverage>cutoff))
##Rezultat pokazuje da imamo 1234 'high leverage point'

######## 3.Logisticka regresija ######

##Bice sprovedena nakon malih izmena nad podacima
##Primer istrazivackog pitanja : Koji faktori predvidjaju verovatnocu da je konj pobediti u trci?
##Za to bi nam bila potrebna jedna kategorijka(dihotomna) zavisna prom. (pobeda DA/NE
#ona bi mogla da se napravi od promenljice final.place-gde bi oni redovi koji imaju vrednost jedan bili kategorija Da, a ostali kategorija NE)
##dve ili vise neprekidnih ili kategorijskuh prediktorksih(nezavisnih) prom. sifrovanih sa 0 ili 1
##U tu svrhu bice upotrebljenje promenljive Surface i Track
##Pretpostavke-veoma je osetljiva na visoke korelacije izmedju prediktrorskih prom


##Pravljenje zavisne promenljive

data1$dependent <- ifelse(test = data1$Final.place!=1,
                            yes = 'No',
                            no='Yes')
data1$dependent <- as.factor(data1$dependent)
summary(data1$dependent)
##Vrednost Yes su prva mesta i njih ima 2225 , ostalih 24783 slucajeva(sva mesta osim prvog)
summary(data1$Surface)
summary(data1$Track)
#Kreiranje dihotomniih nezavisnih prom.
#(Surface_d vrednost 1-ako je zemljana podloga, 0 za travnatu-Gress)
#Track_d vrednost 1-ako je Happy Valley trka, 0 za Sha Tin
data1$Surface_d <- ifelse(data1$Surface=='Dirt',1,0)
data1$Track_d <- ifelse(data1$Track=='Happy Valley',1,0)

#Ispitivanje pretpostavke o korelaciji izmedju prediktorskih prom

res2 <- cor.test(data1$Surface_d, data1$Track_d, 
                method = "pearson")
res2
#Dobijena p- vrednost < 2.2e-16, sto je manje od stat. nivoa alpha=0.05. 
#Moze se zakljuciti da su dihotomne prom. Surface i Track znacajno korelisane 
# Pozitivan znak pokazuje pozitivnu korelaciju.

#Kako pretpostavka nije ispunjena nema smisla dalje razmatrati analizu


######## 4.Faktorska analiza######

data2 <- data.frame(data1[,-c(1,20:22)])
datamatrix1 <- cor(data2[sapply(data2, function(x) !is.factor(x))])
library(corrplot)
corrplot(datamatrix1, method="number")
#Grafik pokazuje da je veoma mali broj promenljivih korelisan
##Race.time i Distance su korelisane 1.0(jaka korelaci)
#Kajzer-Majer-Olkinsov kriterijum opravdanosti primene faktorske analize
#install.packages("EFAtools")
library(psych)
X <- data1[,c(9:19)]
y <- data1[,22]
KMO(X)
##Pokazatelj adekvatnosti uzorka poprima vrednosti izmedju 0 i 1, pa se 0.6 preporucuje kao najmanje prihvatljiv za dobru faktorsku analiyu
##U rom slucaju bi to bili factrori: Horse.age i Odds
bartlett.test(list(data1$Horse.age, data1$Odds))
##Pretpostavka o homogemosti varijanse se odbacuje, samim tim upotreba faktorske analize nije opravdana. 