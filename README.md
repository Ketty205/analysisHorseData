# analysisHorseData
Skup podataka o trkama konja preuzet je sa sajta kaggle, nalazi se na adresi: https://www.kaggle.com/datasets/bogdandoicin/horse-racing-results-2017-2020.
   STRUKTURA PROJEKTA
   
Folder project sadrzi analize u R-u. 
U skripti prvaSkripta.R uradjenje su osnovne transformacije promenljivih, izmene su sacunane u HorseRacingResultProcessed.csv, ovaj skup podatak je upotrebljen u narednoj skripti. 
U drugaSkripta.R uradjeno je ciscenje podataka i eksplorativna analiza. Ovako pripremljeni podaci sacuvani su u HorseRacingResultFinall.csv, za dalje analize.
trecSkripta.R sadrzi statisticke tehnike za istrazivanje razlika izmedju promenljivih.
cetvrtaSkripta.R sadrzi statisticke tehnike za istrazivanje razlika izmedju grupa.
Rplot01-04 predstavljaju exportovane R plotove; zbog kolicine podataka nisu bili bas najcitljivi u R-u, pa je ovim omoguceno zumiranje pojedinih delova plotova radi bolje analize.

SQL- najpre je u Microsoft SQL Management Studiu napravljena baza data1, i u nju importovani podaci HorseFinall.csv. Ovipodaci su  preimenovani HorseRacingResultFinall.csv, radi lakse upotrebe. 
Prilikom ucitavanja podatak dobijena je kolona "", ona zapravo predstavlja redni broj obzervacije, u jednom momentu u SQL skripti pomenuto je njeno preimenovanje, ono je uradjeno jednostavno desnim klikom na nju izborom opcije Rename. 

SQLQuery3 sadryi sql upite; procedure koje su u komentarima pa ih je potrebno prvo odkomentarisati(skloniti znak /**/) i pokrenuti; trigeri koji su takodje u komentarima.
Ovako organizovan file je pruzio mogucnost da se sve stavi na jedno mesto, kako bi se izbeglo kreiranje posebnih fajlova za svaku proceduru.

Tabelau- je upotrebljen za vizuelizaciju SQL upita i procedura; grafici su sacuvani kao image 1-6. Dobijeni grafikoni su stavljeni u GoogleSlides, sacuvani u folderu: Vizuelna reprezentacija rezultat SQL-a, kao pdf u kojem se nalazi objasnjenje dobijenih rezultat ispod svakog grafika
