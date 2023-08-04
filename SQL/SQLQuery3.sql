/*vrati sve podatke iz baze*/
SELECT * FROM data1.dbo.HorseFinall;

/*vrati broj trka po zemljama u kojima se trka odrzala*/
SELECT ["Country"], COUNT(*) as brTrkaPoZemlji
FROM data1.dbo.HorseFinall
GROUP BY ["Country"];

/*Najvise trka se odrzalo u Australiji, skoro duplo manje na NovomZelandu, skoro duplo manje u Irskoj*/
/*Dok se samo jedna trka odrzala u Danskoj i Cileu*/

/*jokeji koji su osvojili max nagradu*/
SELECT ["Jockey"], MAX(["Prize money"]) as maxNagradaPoJokejima
FROM data1.dbo.HorseFinall
GROUP BY ["Jockey"]
ORDER BY MAX(["Prize money"]) desc;

/*Jokeji koji su osvojili max nagradu*/

SELECT ["Jockey"], MAX(["Prize money"]) as maxNagradaPoJokejima
FROM data1.dbo.HorseFinall
GROUP BY ["Jockey"]
HAVING MAX(["Prize money"]) >= 28000000
ORDER BY MAX(["Prize money"]) desc;

/*max iznos nagrade je 28 miliona i 14 jokeja ju je osnojilo*/

SELECT ["Jockey"], ["Surface"], ["Track"], ["Starting position"], ["Odds"], ["Country"]
FROM data1.dbo.HorseFinall
WHERE ["Prize money"] >= 28000000;
/*Maksimalan iznos nagrade osvojen je na travantoj podlozi, ShiTin trkama u najvecem br. slucajeva u V.Britaniji*/
/*James Doyle koji je imao 59 verovatnocu pobede u VelikojBritaniji je osvojio veliku nagradu, sa startne osme pozicije */

/*Treneri koji su trenirali jokeje koji su osvojili max nagrade*/
SELECT ["TrainerName"],["Jockey"], MAX(["Prize money"]) as maxNagradaPoJokejima
FROM data1.dbo.HorseFinall
GROUP BY ["TrainerName"],["Jockey"]
HAVING MAX(["Prize money"]) >= 28000000
ORDER BY MAX(["Prize money"]) desc;

/*F C Lor i AS Crus su trenirali najveci broj najvise nagradjivanih jokeja*/

SELECT ["Horse age"],["Jockey weight"],["Distance"],["Jockey"], MAX(["Prize money"]) as maxNagradaPoJokejima
FROM data1.dbo.HorseFinall
GROUP BY ["Horse age"],["Jockey weight"],["Distance"],["Jockey"]
HAVING MAX(["Prize money"]) >= 28000000
ORDER BY MAX(["Prize money"]) desc;

/*Najvecu nagradu osvajaju jokeji koji su u najvecem br.slucajeva imaju 57kg, takmiceci se na 2000m, dok starost konja varira [3,7] godina; u najvecem broju slucajeva konji imaju 5godina*/

/*Pravljenje tabele sa with svi onih koji su osvojili max nagradu*/
/*tabela MAXNAGRADJENI-Jockey, Jockey weight,Distance,Horse age, Starting position, TrainerName, max iznos nagarde */
WITH MAXNAGRADJENI
AS
(
SELECT * FROM data1.dbo.HorseFinall
)
SELECT ["Jockey"],["Jockey weight"],["Distance"],["Horse age"], ["Starting position"], ["TrainerName"],MAX(["Prize money"]) as maxNagradaPoJokejima
FROM data1.dbo.HorseFinall
GROUP BY ["Jockey"],["Jockey weight"],["Distance"],["Horse age"], ["Starting position"], ["TrainerName"]
HAVING MAX(["Prize money"]) >= 28000000;

/*Ovako napravljena tabela se ne vidi u tables. Ovako napravljenja tabela moze da se dalje koristi u upitima*/

/*ZAKLJUCAK: Razlika izmedju VIEW i temporary tables sto je view rezultat vidljiv samo dok traje sesija, kad se ona prekine gubi se. Temp. tables se skladisti u cash memoriji i ona je duze vidljiva.*/

/*Iz tabele se moze videti da su K Teeten, Ryan Moore i Z Purton menjali trenere i osvajali max nagrade*/

/*Pravljenje tabele sa CASE*/
/*vrati Jockey, Distance, Race.time,Odds, i kolonu pobednik-ako je final place 1 'W' i 'NoW' neka druga vrednost*/

CREATE TABLE data1.dbo.CaseTable(
Jockey varchar(50),
Distance int,
Race_time numeric,
Odds int,
[Winner] varchar(50)
)

INSERT INTO data1.dbo.CaseTable(Jockey, Distance, Race_time, Odds, Winner)

SELECT ["Jockey"], ["Distance"], ["Race time"], ["Odds"],
CASE ["Final place"]
	WHEN 1 THEN 'W' 
	ELSE 'NoW'
	END

FROM data1.dbo.HorseFinall as hf;

/* kako izgleda tabela*/
SELECT * FROM data1.dbo.CaseTable;

/*Vrati sve jokeje koji su pobedili, duzinu trke, a cija trka je imala min trajanje;uslov Odds>0 kad je radjeno sifrovanje podatak u R-u sa 0 su zamenjene one vrednosti koje su nedostajele */
SELECT Jockey, Distance, MIN(Race_time) AS minRaceTime
FROM data1.dbo.CaseTable
WHERE Winner = 'W' AND Odds > 0
GROUP BY Jockey, Distance;

/*    PROCEDURE     

 1. kreirati proceduru koja selektuje jokeje i vraca njiv broj pobeda

USE data1
GO
CREATE PROC brPobedaIzCaseTabelePoJokeju1
AS
SELECT Jockey, COUNT(*) AS brPobeda
FROM data1.dbo.CaseTable
WHERE Winner = 'W' 
GROUP BY Jockey;

EXEC brPobedaIzCaseTabelePoJokeju1;

/*Ubedljivo najvise pobeda ima Z Purton cak 397*/



USE data1
GO
CREATE PROC spFindPortionName
	@InicialsForSearch varchar(40) = '%'
AS
BEGIN
	SELECT ["Country"], ["Jockey"]
	FROM dbo.HorseFinall
	WHERE ["Jockey"] LIKE @InicialsForSearch
END  

GO
EXEC spFindPortionName '%Purton';
*/

/*    TRIGERI   */

/* Kreiranje test tabele


/*Koloni "" tabele HoreFinall promenjeno je ime u Id*/
/*
USE data1
SELECT Id, ["Jockey"],["Country"] INTO Jokei
FROM dbo.HorseFinall;

/*Kreiranje tabele jokejski dnevnik
*/
CREATE TABLE JokeyLogs(
	brJokeja nchar(5),
	status varchar(30)
);




/*Prvi triger koji ce biti kreiran je za INSERT-da se kreira rekord svaki put kad se doda podatak u tabelu Jokei*/

CREATE TRIGGER Test_Jokeys_INSERT ON Jokei
	AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @id nchar(5)
	SELECT @id = inserted.Id
	FROM inserted

	INSERT INTO JokeyLogs
	VALUES (@id, 'Inserted')
END
/*Dodavanje rekorda u tabelu Jokei, aktivirace triger Jokei*/

INSERT INTO Jokei(Id,["Jockey"],["Country"]) VALUES (50000, 'Serbian Jokey1', 'Serbia');
INSERT INTO Jokei(Id,["Jockey"],["Country"]) VALUES (50001, 'Serbian Jokey2', 'Serbia-Sombor');

SELECT * FROM JokeyLogs;

/*Kodom ispod kreira se trigger za update*/
/*
CREATE TRIGGER Test_Jokeys_UPDATE ON Jokei
	AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @id nchar(5)
	SELECT @id = deleted.Id
	FROM deleted

	INSERT INTO JokeyLogs
	VALUES (@id, 'Deleted')
END


DELETE FROM Jokei WHERE Id='50000';

SELECT * FROM JokeyLogs;

*/

/*trigeri za update; podaci za update i insert se skladiste u INSERTED

CREATE TRIGGER TestJokei_UPDATE ON Jokei
	AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @id nchar(5)
	DECLARE @Action varchar(50)

	SELECT @id = inserted.Id
	FROM inserted

	IF UPDATE(Id)
		SET @Action = 'Updated ID'
	IF UPDATE(["Jockey"])
		SET @Action = 'Updated Jockey'
	IF UPDATE(["Country"])
		SET @Action = 'Updated Country'

	INSERT INTO JokeyLogs
	VALUES (@id, @Action)
END

*/

UPDATE Jokei SET Id='50011' WHERE Id='50001';
UPDATE Jokei SET ["Jockey"]='Djordje Perovic' WHERE Id='50011';
UPDATE Jokei SET ["Country"]='Serbia' WHERE Id='50011';

SELECT * FROM JokeyLogs;
SELECT * FROM Jokei;

*/


