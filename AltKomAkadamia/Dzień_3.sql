USE SEZAM

--Zap01
SELECT Miasto 
	,COUNT(ID_Klient) 'Iloœæ klijentów z miasta'
FROM tblKlienci
GROUP BY Miasto

--Zap02
SELECT Miasto
	, SUM(Ilosc*CenaSprzedazy) 'suma sprzedarzy z miasta'     
FROM        tblKlienci INNER JOIN
                  tblSprzedaz ON tblKlienci.ID_Klient = tblSprzedaz.Klient_ID INNER JOIN
                  tblOpisSprzedazy ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
GROUP BY Miasto

--Zap03
SELECT suma_sprzedazy.Miasto
	,[Iloœæ klijentów z miasta]
	,[suma sprzedarzy z miasta]
FROM 
	(
		SELECT Miasto 
			,COUNT(ID_Klient) 'Iloœæ klijentów z miasta'
		FROM tblKlienci
		GROUP BY Miasto
	) AS ilosc_klientow
JOIN
	(
		SELECT Miasto
			, SUM(Ilosc*CenaSprzedazy) 'suma sprzedarzy z miasta'     
		FROM        tblKlienci INNER JOIN
						  tblSprzedaz ON tblKlienci.ID_Klient = tblSprzedaz.Klient_ID INNER JOIN
						  tblOpisSprzedazy ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
		GROUP BY Miasto
	) AS suma_sprzedazy
ON ilosc_klientow.Miasto=suma_sprzedazy.Miasto

--Zap04 - funkcje rankingowe
--Wszystkie funkcje rankingowe wymagaj¹ zastosowania funkcji OVER - funkcja okna
--Dwa cele OVER(podzielenie danych na grupy i wskazanie kierunku u³o¿enia danych do numerowania)
SELECT NazwaTowaru
	,SUM(Ilosc) 'Suma iloœci'
	,ROW_NUMBER() OVER(ORDER BY SUM(Ilosc) DESC) 'Ranking towarów'
FROM tblTowary INNER JOIN tblOpisSprzedazy 
	ON tblTowary.ID_Towar = tblOpisSprzedazy.Towar_ID
GROUP BY NazwaTowaru, ID_Towar

--Zap05
--Numerowanie z uwzglêdnianiem takich samych wartoœci. Numeracja z dziurami
SELECT NazwaTowaru
	,SUM(Ilosc) 'Suma iloœci'
	,RANK() OVER(ORDER BY SUM(Ilosc) DESC) 'Ranking towarów'
FROM tblTowary INNER JOIN tblOpisSprzedazy 
	ON tblTowary.ID_Towar = tblOpisSprzedazy.Towar_ID
GROUP BY NazwaTowaru, ID_Towar

--Zap06
--Numerowanie z uwzglêdnianiem takich samych wartoœci. Numeracja bez dziurami
SELECT NazwaTowaru
	,SUM(Ilosc) 'Suma iloœci'
	,DENSE_RANK() OVER(ORDER BY SUM(Ilosc) DESC) 'Ranking towarów'
FROM tblTowary INNER JOIN tblOpisSprzedazy 
	ON tblTowary.ID_Towar = tblOpisSprzedazy.Towar_ID
GROUP BY NazwaTowaru, ID_Towar

--Zap07
SELECT ID_Towar
	,NazwaTowaru
	,NTILE(5) OVER(ORDER BY ID_Towar) 'Grupy'
FROM tblTowary

--Zap08
--Ranking cen towarów z podzia³em na kategorie
SELECT NazwaKategorii
	,NazwaTowaru
	,Cena_Katalogowa
	,DENSE_RANK() OVER(PARTITION BY NazwaKategorii ORDER BY Cena_Katalogowa DESC) 'Ranking'
FROM tblKategorie INNER JOIN tblTowary 
	ON tblKategorie.ID_Kategoria = tblTowary.Kategoria_ID

--Zap09
--Wybieramy najdroszcze produkty w swojej kategorii
SELECT *
FROM (
	SELECT NazwaKategorii
		,NazwaTowaru
		,Cena_Katalogowa
		,DENSE_RANK() OVER(PARTITION BY NazwaKategorii ORDER BY Cena_Katalogowa DESC) 'Ranking'
	FROM tblKategorie INNER JOIN tblTowary 
		ON tblKategorie.ID_Kategoria = tblTowary.Kategoria_ID
) podzapytanie
WHERE Ranking=1

--Zap10
SELECT YEAR(DataSprzedazy) 'Rok'
	,SUM(Ilosc*CenaSprzedazy) 'Suma sprzedarzy rocznej'
	,SUM(SUM(Ilosc*CenaSprzedazy)) OVER (ORDER BY YEAR(DataSprzedazy)) 'Suma narastaj¹ca'
FROM tblSprzedaz INNER JOIN tblOpisSprzedazy 
	ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
GROUP BY YEAR(DataSprzedazy)

--Zap11
--ROLLUP - rozszerza funkcjonalnoœæ klauzuli GROUP BY, o mo¿liwoœæ tworzenia tzw. kostek analitycznych po³ówkowych
SELECT Miasto 
	,YEAR(DataSprzedazy) 'Rok'
	,SUM(Ilosc*CenaSprzedazy) 'Suma sprzedarzy'
FROM tblKlienci INNER JOIN tblSprzedaz 
	ON tblKlienci.ID_Klient = tblSprzedaz.Klient_ID INNER JOIN tblOpisSprzedazy 
	ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
GROUP BY ROLLUP( Miasto, YEAR(DataSprzedazy))

--Zap12
SELECT NazwaKategorii
	,ISNULL(NazwaTowaru, NazwaKategorii+' suma: ') 'Nazwa towaru'
	,SUM(Ilosc*CenaSprzedazy) 'Suma sprzedarzy'
FROM tblKategorie INNER JOIN tblTowary 
	ON tblKategorie.ID_Kategoria = tblTowary.Kategoria_ID INNER JOIN tblOpisSprzedazy 
	ON tblTowary.ID_Towar = tblOpisSprzedazy.Towar_ID
GROUP BY ROLLUP (NazwaKategorii ,NazwaTowaru)

--Zap13
SELECT NazwaKategorii
	,NazwaTowaru
	,SUM(Ilosc*CenaSprzedazy) 'Suma sprzedarzy'
FROM tblKategorie INNER JOIN tblTowary 
	ON tblKategorie.ID_Kategoria = tblTowary.Kategoria_ID INNER JOIN tblOpisSprzedazy 
	ON tblTowary.ID_Towar = tblOpisSprzedazy.Towar_ID
GROUP BY CUBE(NazwaKategorii ,NazwaTowaru)

--Zap14
SELECT SUM(Ilosc*CenaSprzedazy) 'Suma calosci'
FROM tblOpisSprzedazy

--Zap15
--Udzia³ % miast klientów w ca³ej sprzeda¿y
SELECT Miasto
	, SUM(Ilosc*CenaSprzedazy) 'suma sprzedarzy z miasta'
	, SUM(Ilosc*CenaSprzedazy) / (
		SELECT SUM(Ilosc*CenaSprzedazy) 'Suma calosci'
		FROM tblOpisSprzedazy
	) 'udzia³ procentowy' 
FROM        tblKlienci INNER JOIN
                  tblSprzedaz ON tblKlienci.ID_Klient = tblSprzedaz.Klient_ID INNER JOIN
                  tblOpisSprzedazy ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
GROUP BY Miasto

--Zap16
--ROUND(co zaokr¹glamy, do ilu miejsc zaogr¹glamy)
SELECT  Miasto
		,SUM(Ilosc*CenaSprzedazy) AS 'Suma miast'  
		,CAST(CAST((SUM(Ilosc*CenaSprzedazy)  / (
										SELECT	SUM(Ilosc*CenaSprzedazy) AS 'Suma calosci'
										FROM tblOpisSprzedazy		
									) )*100 AS numeric(5,2)  ) AS nvarchar(7)) +'%' AS Udzial_proc   
FROM            tblKlienci INNER JOIN
                         tblSprzedaz ON tblKlienci.ID_Klient = tblSprzedaz.Klient_ID INNER JOIN
                         tblOpisSprzedazy ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
GROUP BY Miasto
GO

USE HM
GO

--Zap17 - PIVOT
/*
SELECT naglowki wierszy, naglowek1, naglowek2....
FROM 
	(
		wszystkie dane wchodzace do pivota(nag³ówki kolumn,nag³ówki wierszy,dane do agregacji)
	) AS Dane
PIVOT
	(
		f.agr.(dane do agregacji) FOR naglowki_kolumn IN(naglowek1, naglowek2,....)
	) AS ustawienia_pivota

*/

--DANE DO PIVOTA
SELECT wykonawca,nosnik,Ilosc
FROM tbPozycjeFaktur INNER JOIN tbTowary 
	ON tbPozycjeFaktur.TowarID = tbTowary.IDTowaru

--UNIKALNE NAZWY KOLUMN(nosnik)
SELECT DISTINCT nosnik
FROM tbTowary

--Analog, CD, DVD, MC, VHS

--PIVOT
SELECT wykonawca, Analog, CD, DVD, MC, VHS
FROM (
	SELECT wykonawca,nosnik,Ilosc
	FROM tbPozycjeFaktur INNER JOIN tbTowary 
		ON tbPozycjeFaktur.TowarID = tbTowary.IDTowaru
) AS Dane
PIVOT (
	SUM(ilosc) FOR nosnik IN (Analog, CD, DVD, MC, VHS)
) AS tb_Pivot

SELECT wykonawca
		--zastepowanie NULLi ->zerami
		,ISNULL(Analog,0) AS 'Analog'
		,ISNULL(CD,0) AS 'CD'
		,ISNULL(DVD,0) AS 'DVD'
		,ISNULL(MC,0) AS 'MC'
		,ISNULL(VHS,0) AS 'VHS'
FROM 
	(
			SELECT     wykonawca,nosnik,Ilosc   
			FROM            tbTowary INNER JOIN
									 tbPozycjeFaktur ON tbTowary.IDTowaru = tbPozycjeFaktur.TowarID
	) AS Dane
PIVOT
	(
		SUM(Ilosc) FOR nosnik IN (Analog,CD,DVD,MC,VHS)
	) AS tb_Pivot

--Zap18
SELECT nazwa
	,YEAR(DataSprzed) AS 'ROK'
	,Ilosc*CenaSprz AS 'Suma sprzedazy'
FROM tbKlienci INNER JOIN tbFaktury 
	ON tbKlienci.IDKlienta = tbFaktury.KlientID INNER JOIN tbPozycjeFaktur 
	ON tbFaktury.IDFaktury = tbPozycjeFaktur.FakturaID

SELECT DISTINCT YEAR(DataSprzed)
FROM tbFaktury

--PIVOT
SELECT nazwa, [2004], [2005], [2013]
FROM (
	SELECT nazwa
		,YEAR(DataSprzed) AS 'ROK'
		,Ilosc*CenaSprz AS 'Suma sprzedazy'
	FROM tbKlienci INNER JOIN tbFaktury 
		ON tbKlienci.IDKlienta = tbFaktury.KlientID INNER JOIN tbPozycjeFaktur 
		ON tbFaktury.IDFaktury = tbPozycjeFaktur.FakturaID
) AS tb_Dane
PIVOT (
	SUM([Suma sprzedazy]) FOR Rok IN ([2004], [2005], [2013])
) AS tb_Pivot

--Zap19
	SELECT miasto
	FROM tbKlienci
UNION
	SELECT Miasto
	FROM SEZAM.dbo.tblKlienci
GO

USE SEZAM
GO

--Zap20 - FETCH, OFFSET
--OFFSET -> ile wierszy pomin¹c
--FETCH -> ile wierszy zwracamy
SELECT NazwaTowaru 
	,Cena_Katalogowa
FROM tblTowary
ORDER BY Cena_Katalogowa DESC
OFFSET 4 ROWS
FETCH NEXT 2 ROWS ONLY

--Zap21 - Tabele tymczasowe
-- Tabela tymczasowa lokalna
-- TT dzia³aj¹ w odrêbie danej sesji.
-- Tabela tymczasowa lokalna -> mo¿e z nich korzystaæ tylko i wy³¹cznie u¿ytkownik, który utworzy³ dan¹tabelê.
-- Tabele tymczasow¹ lokaln¹ tworzy sie poprzez dodanie na pocz¹tku nazwy (#)
CREATE TABLE #Tabela_lokalna (
	ID int PRIMARY KEY IDENTITY(1,1)
	, Miasto nvarchar(40) 
)

INSERT INTO #Tabela_lokalna VALUES 
	('Warszawa')
	,('New York')
	,('Kraków')
GO 20

SELECT *
FROM #Tabela_lokalna

--UPDATE/DELETE/ - piszemy w jednym wierszu
UPDATE #Tabela_lokalna SET Miasto = 'Sydney' WHERE ID=3

DELETE FROM #Tabela_lokalna WHERE ID=2

DROP TABLE #Tabela_lokalna

--Zap22
--Globalna tabela tymczasowa
--dostêp do niej maj¹ wszyscy u¿ytkownicy posiadaj¹cy przynajmniej rolê Public
CREATE TABLE ##Tabela_globalna (
	ID int PRIMARY KEY IDENTITY(1,1)
	, Miasto nvarchar(40) 
)

INSERT INTO ##Tabela_globalna VALUES 
	('Warszawa')
	,('New York')
	,('Kraków')
GO 20

SELECT *
FROM ##Tabela_globalna

--Zap23
--Tworzenie tabeli z zapytania
SELECT *
INTO #pracownicy
FROM (
	SELECT Nazwisko
	FROM tblPracownicy
) AS podzapytanie

SELECT *
FROM #pracownicy

--Zap24
CREATE TABLE #klienci (
	ID int 
	, nazwa_firmy nvarchar(40) 
)

--wstawianie do istniej¹cej tabeli danych z zapytania
INSERT INTO #klienci (
	ID, nazwa_firmy
) SELECT ID_Klient, NazwaFirmy
FROM tblKlienci

SELECT *
FROM #klienci

--Zap25 - IMPORT DANYCH - BULK INSERT
create table #test6
(
   ID numeric IDENTITY(1,1),
   Nazwisko nvarchar(40),
   Stan nvarchar(40),
   Miasto nvarchar(40),
   [Data] date,
   Produkt nvarchar(50),
   Ilosc numeric,
   Cena_Jednostkowa money,
   Razem money
)
GO

BULK INSERT #test6 
	FROM 'C:\Dane4.txt'
	WITH (
		FIRSTROW=2
		,FIELDTERMINATOR = ';'	--SEPARATOR KOLUMN
		,ROWTERMINATOR = '\n'	--SEPARATOR WIERSZY
		,CODEPAGE = ''			-- 'code_page' a ANSI jest okreœlone jako ACP
		,KEEPIDENTITY			--zachowujê oryginaln¹ numeracjê 
	)

SELECT *
FROM #test6

--Zap26
SELECT Miasto
	, SUM(Ilosc*CenaSprzedazy) 'suma sprzedarzy z miasta'
	, IIF(SUM(Ilosc*CenaSprzedazy) > 5000, 'Promocja', 'Brak promocji') 'Promocja'
FROM        tblKlienci INNER JOIN
                  tblSprzedaz ON tblKlienci.ID_Klient = tblSprzedaz.Klient_ID INNER JOIN
                  tblOpisSprzedazy ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
GROUP BY Miasto