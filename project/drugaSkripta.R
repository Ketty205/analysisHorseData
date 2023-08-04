data1 <- read.csv('HorseRacingResultProcessed.csv', header = TRUE, sep = ',', stringsAsFactors = T)
str(data1)
summary(data1)

##Za sad se brise promenljiva X-redni broj reda, prom Odds ce iako ima veliki broj
##nedostajucih vrednosti 8428 za sad da se sacuva, zbog opisa podataka da je bitna
##zato sto nize kvote odgovaraju boljoj zavrsnici
new_data1 <- data1[,c(2:22)]
head(new_data1)

##Provera frekvencija, tj. broja obzervacija po kategorijama 
cat_new_data1 <- new_data1[,c(1:7)]
summary(cat_new_data1)
## Moglo se ocekivati da imamo veliki broj razlicitih datuma, jokeja, zemalja i imena trenera
##Ono na sta treba obratiti paznju su: trke ShaTin(17169) u odnosu na Happy Valley(9839)
##Znacajno veci broj trka na travi kao podlozi(23682), u odosu na zemljanu 3316
##Tip trke Handicap(26284), Non-handicap(601); najvise trka se odrzalo u Australiji(13179)
num_new_data1 <- new_data1[,c(8:21)]
summary(num_new_data1)

##Broj trke uzima vrednost iz opsega 1-11, startne pozicije takmicara mogu biti 1-14,samim tim i finalni plasman
##Duzina trke 1000m, najduza 2000, medijana 1400, srednja vrednost 1402
##Prize money(ukupan iznos novcane nagrade u trci)min=6.6e+4, max=2.8e+7, median=9.67e+5, mean=1.479445e+6
##Tezina dzokeja(Jockey.weight) min=47, max=63, mean=55.87, mediana=56 kg
##Starost konja(Horse.age) min=2, max= 12, mediana=5, srednja vredsnost=5.246 godina
##Trajanje trke(Race.time) min=54.69, max=153.09, medijana=82.08, srednja vrednsot=83.59
##FGrating(nacin da se normalizuje vreme trke, tako sto se vreme meri bez obzira na stazu, udaljenost ili uslove na dan trke)
##min=-5, max=157, medijana=114.0, mean=113.4
##Odds(verovatnoca pobede) min=1, max=639, median=27, mean=49.66
##HorseID, JOckeyID, TrainerID= id redom konja, jokeja i trenera nema smisla analizirati ih kao prethodne promenljive
##mean-srenja vrednost, median-medijana(vrednost obelezja koja stat. skup deli na dva jednaka dela)

varPrize <- var(num_new_data1$Prize.money)
varPrize
##Varijansa(aritmeticka sredin a kvadrata odstupanja vrednsoti obelezja od njihove srednje vrednosti) za iznos novcane nagrade iznosi 4.674717e+12
varRaceTime <- var(num_new_data1$Race.time)
varRaceTime
##Varijansa za vreme trajanja trke iznosi 331.1441

#Da bi se testirala normalna rapodela 1. Crtanje histograma
library(ggplot2)
# Basic histogram

##h_price <- ggplot(num_new_data1, aes(x=Prize.money)) + geom_histogram(color="black", fill="red")
##h_price
##h_raceTime <- ggplot(num_new_data1, aes(x=Race.time)) + geom_histogram(color="black", fill="blue")
##h_raceTime
##Ovo bi imalo smisla raditi da uzorak sadrzi manje od 200 slucajeva, pa analizirajuci asimetriju i spljostenost steci uvid u normalnost odnosno odsustvo normalne raspodele. 
##Pa onda uz pomoc nekih transformacija normalizovati raspodelu. O raspodelama ce biti kasnije reci kad bude testiranje hipoteza.

##Crtanje boxplota(pravouganog grafika) da bi se detektovali outlijeri
ggplot(new_data1, aes(x=Prize.money, y= Track)) + geom_boxplot()
ggplot(new_data1, aes(x=Race.time, y= Track)) + geom_boxplot()

##Veci broj outlijea(netipicnih tacaka) ima vrednost novca u kategoriji trke ShaTin(sto ukazuje da je iznos dobitka veci kod ovog tipa trke)
##Trajanje trke netipicne tacke ima samo kod Sha Tin(sto znaci da su duze treke Sha Tin,u odnosu na Happy Valley)
##Objasnjenje pravougaonih grafika- pravougaonik predstavlja 50%izmerenih vrednosti, 
##srednja linija je medijana, dok su linije koje izlaze iz pravouganika min i max vrednsot
##Kasnije ce biti jos reci o outlijerima, sada se prelazi na ekplorativnu analizu(EDA-Exploratory data analysis)po knjizi R foe DataScience.

library(tidyverse)
#Promenljiva je neprekida ako moze da uzme bilo koju vrednost iz bezskonacnog skupa uredjenih vrednosti
#Bojevi i date-time su dva primera neprekidnih promenljivih. Da bi se ispitala ditribucija
#kontinualne prom koristice se dijagram:
ggplot(data = new_data1) +
  geom_histogram(mapping = aes(x = Horse.age), binwidth = 0.5)

#Uz pomoc lambda izraza, u nastavku promenila sam sirinu intervala za godine
new_data1 %>%
  count(cut_width(Horse.age, 3))
#Histogram deli x-osu na jednake intervale-'bins' i onda visina grafika pokazuje broj obzervacija u svakom intervalu
#Tumacenje grafika: najveci br obzervacija je u grupi (4.5,7.5] skoro 15134, takodje znacajan broj u intervalu [1.5,4.5]  9595.

#Sada cu isto uraditi i za prom. Race.time
ggplot(data = new_data1) +
  geom_histogram(mapping = aes(x = Race.time), binwidth = 3)

new_data1 %>%
  count(cut_width(Race.time, 3))
##Izdvojila su se tri pika:(67.5,70.5] 5721,(70.5,73.5] 3960,(82.5,85.5] 2852
##Ako se sabere broj trka cije trajanje je (67.5,85.5] njih 14435 se nalazi u ovom intervalu, sto bi bilo 53.4471%uzorka.

ggplot(data = new_data1) +
  geom_histogram(mapping = aes(x = Prize.money), binwidth = 500000)
new_data1 %>%
  count(cut_width(Prize.money, 500000))
##Opet su se izdvojila tri pika: iznosi dobitaka u intervalima od:[2.5e+05,7.5e+05],(7.5e+05,1.25e+06],(1.25e+06,1.75e+06] broj dobitnika redom: 3398, 10801,8957
##Raspodela je pomerena u levo sto znaci da ima veci broj izmerenih manjih vrednosti, stiti se da su netipicne tacke bili veliki iznosi dobitaka

smaller <- new_data1 %>%
  filter(Jockey.weight < 56)
ggplot(data = smaller, mapping = aes(Jockey.weight)) +
  geom_histogram(binwidth = 2)
##Crtanje visestrukih histograma na istom plotu
ggplot(data = smaller, mapping = aes(x = Jockey.weight, color = Track)) +
  geom_freqpoly(binwidth = 2)
##Broj odrzanih trka Sha Tin je skoro duplo veci od odrzanih Happy Valley, samim tim i ne cudi ovaj pik oko 54kg tezine dokeja
smaller1 <- new_data1 %>%
  filter(Prize.money < 1750000)
ggplot(data = smaller1, mapping = aes(x = Prize.money)) +
  geom_histogram(binwidth = 500000)
ggplot(data = smaller1, mapping = aes(x = Prize.money, color = Surface)) +
  geom_freqpoly(binwidth = 500000)
##Mnogo veci dobici su na travi, nego na zemljanoj podlozi
ggplot(data = smaller1, mapping = aes(x = Prize.money, color = Country)) +
  geom_freqpoly(binwidth = 500000)
##Najveci dr. dobitaka je na trkama u Australiji i Novom Zelandu
ggplot(data = smaller1, mapping = aes(x = Prize.money, color = RaceType)) +
  geom_freqpoly(binwidth = 500000)
##Handicap trke, gde konji ne nose istu jokejsku tezinu su mnogo brojnije i donose vece dobitke
ggplot(data = smaller1, mapping = aes(x = Prize.money, color = Jockey)) +
  geom_freqpoly(binwidth = 500000)
##Kao Jokej koji je osvojio najvise novca izdvojio se Yutaka Take, legendarni Japanski jokej koji ima 114 pobeda u osam zemalja(po Wikipediji)
##ukljucujuci Australiju sto se u potpunosti poklapa sa predjasnim rezultatima
##Odmah za njim se izdvojio K Teetan(Karis Teetan po podacima sa wikipedije se opet uklapa u dobijene rezultate)

smaller2 <- new_data1 %>%
  filter(Race.time < 86)
ggplot(data = smaller2, mapping = aes(x = Race.time, color=RaceType)) +
  geom_freqpoly(binwidth = 3)
ggplot(data = smaller2, mapping = aes(x = Race.time, color=Country)) +
  geom_freqpoly(binwidth = 3)
ggplot(data = smaller2, mapping = aes(x = Race.time, color=Surface)) +
  geom_freqpoly(binwidth = 3)
##Imamo ocekivana tri pika u ovom intervalu trajanja trka, rezultati su isti kao kod promenljive Prize.money
ggplot(data = smaller2, mapping = aes(x = Race.time, color=TrainerName)) +
  geom_freqpoly(binwidth = 3)
##Za trke cije trajanje je u intervalu od (67.5,70.5] izdvojio se trener A Lee
##U drugom piku (70.5,73.5] izdvojio se J Size
##Dok se u trecem piku (82.5,85.5] sekundi trajanjatrka su se izdvojili C Fownes, AS Crus

##Prikazati broj prvih mesta po zemlji
smaller3 <- new_data1 %>%
  filter(Final.place ==1) %>%
  group_by(Jockey)
ggplot(data = smaller3, mapping = aes(x = Race.time, color=Country)) +
  geom_freqpoly(binwidth = 3)
##Najveci broj prvih mesta osvojen je na trkama u Australiji, cije trajanje je (70.5,73.5]sekundi

summary(cat_new_data1)
##Neke analize su osetljive na nejednak broj opservacija po kategorijama
##tako da cu Ikke klassifisert:   20, RaceType ukloniti
new_data2 <- new_data1 %>% filter(RaceType != 'Ikke klassifisert')
summary(new_data2)

#Dijagram koji ce da pokaze dogodak u odnosu na kategorije zaposlenja
ggplot(data = new_data2, mapping = aes(x = RaceType, y = Prize.money)) +
  geom_boxplot()
#Da bi se trend lakse pratio promenice se redosled klasa u zavisnosti od vrednosti medijane
ggplot(data = new_data2) +
  geom_boxplot(
    mapping = aes(
      x = reorder(RaceType, Prize.money, FUN = median),
      y = Prize.money
    )
  )
##Ima nekoliko(oko sedam) outlijera- crne tacke van pravougaonika, kod trka tipa: Griffinl?p i Handicap 
##Sada to isto treba proveriti i sa promenljivom Race.time
ggplot(data = new_data2) +
  geom_boxplot(
    mapping = aes(
      x = reorder(RaceType, Race.time, FUN = median),
      y = Race.time
    )
  )
##Nekoliko njih kod kategorije Handicap, dok ih kod ostala dva tipa trke nema

##Dijagrame rasturanja u nastavku crtam da bi se videla zavisnost izmedju dve neprekidne promenljive
#Preporucuje se nacrtati ih pre racunanja korelacije. Predocava da li je odnos izmedju prom. linearalan ili krivolinijski.
#Za nalizu korelacije prikladni su samo linearni odnosi.

scatterplot(Horse.age ~ Prize.money, data = new_data2)
##Korelacija je jaka tacke cine prepoznatljiv valjkast oblik
scatterplot(Jockey.weight ~ Prize.money, data = new_data2)
##Identicna je situacija, samo sto promenljiva Jockey.weight ima manje outlijera
#Ovaj dijagram ne daje konacne odgovore treba izracunati odgovarajuce stat pokazatelje
#(npr. koeficijent Pirsonove korelacije  ili njegovu alterantivu Spirmanov koef.)
#Transformisanje promenljivih
##Sredjivanje nedostajucih vrednosti prom. Odds
##Jedan od nacina je da se vidi raspodela, ako je normalna popuniti sa mean, u suptrotnom sa median
which(is.na(new_data2$Odds))
#7425 redova je nedostajuce, njihovo popunjavanje u ovom slucaju kad nedostaje skoro trecina podataka moze znacajno iskriviti rapodelu
#dok bi njihovo brisanje dovvelo do gubitka velike kolicine podataka, tako da ce nedostajuce vrednosti biti popunjene sa 0
library("tidyr")
library("dplyr")
new_data2 <- new_data2 %>% 
  mutate_at(18, ~replace_na(.,0))
head(new_data2)
#Anderson-Darling normality test, zato sto shapiro_test ne radi za uzorak velicine preko 5000
##install.packages('nortest')
library(nortest)
num.vars <- c(8:18)
apply(X=new_data2[,num.vars], MARGIN = 2, FUN=ad.test)
#Pa osnovu dobijenih prednosti za p, pretpostavka o normalnosti raspodele se odvbacuje



#Provera prisustv netipicnih vrednosti:
apply(X=new_data2[,num.vars], #selektovanje numerickih kolona
      MARGIN = 2, #primeniti funkciju samo na kolone
      FUN = function(x) length(boxplot.stats(x)$out))
#Skoro sve promenljive imaju netipicne vrednosti, osim: Race.number,Final.place, Starting.Position
#Koristice se tehnika Winsorizing, koja predstavlja zamenu ekstremnih vrednosti sa odredjenim percentilom, obicno 90 ili 95im.

#Sredjivanje prom Distance
sort(boxplot.stats(new_data2$Distance)$out)
#Ovo zapravo i nisu outlijeri vec samo najduza trka,tako da se nece dalje procesirati
sort(boxplot.stats(new_data2$Prize.money)$out)
#Ovo su opet najvece nagrade i nema smisla ni njih dirati
sort(boxplot.stats(new_data2$Jockey.weight)$out)
sort(boxplot.stats(new_data2$Horse.age)$out)
sort(boxplot.stats(new_data2$Race.time)$out)
sort(boxplot.stats(new_data2$Path)$out)
sort(boxplot.stats(new_data2$FGrating)$out)
sort(boxplot.stats(new_data2$Odds)$out)
#Prethodno izlistane promeljive su samo potvrdile ono sto su pokazale prve dve, da ove prom. ne sadrze netipicne
#vrednosti
cat.varsF <- c(1:7)
finaldata <- cbind(new_data2[,cat.varsF], new_data2[,num.vars])
str(finaldata)
##Ovako formiran dataframe moze se sacuvati kao dataset
write.csv(finaldata, "C:/Users/pc/Desktop/mozzart/project/HorseRacingResultFinall.csv", row.names = TRUE)