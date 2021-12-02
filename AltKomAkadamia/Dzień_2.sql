USE SEZAM
GO 

--Zap01 - HAVING
SELECT LTRIM(NazwaTowaru) 'Nazwa towaru'
	,AVG(Ilosc*CenaSprzedazy) 'œrednia'
FROM tblTowary t JOIN tblOpisSprzedazy os
ON t.ID_Towar=os.Towar_ID
GROUP BY LTRIM(NazwaTowaru), ID_Towar
HAVING AVG(Ilosc*CenaSprzedazy) >= 200
ORDER BY [œrednia] DESC

--Zap02
SELECT Miasto
	,SUM(Ilosc*CenaSprzedazy) 'Suma sprzedarzy' 
FROM tblKlienci INNER JOIN tblSprzedaz 
	ON tblKlienci.ID_Klient = tblSprzedaz.Klient_ID INNER JOIN tblOpisSprzedazy 
	ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
WHERE YEAR(DataSprzedazy) = 2014
GROUP BY Miasto
HAVING SUM(Ilosc*CenaSprzedazy) >= 1000
GO

--Zap03 - Widoki
CREATE VIEW v_suma_miast_2014 AS	--ALTER VIEW - edycja widoku
	SELECT Miasto
		,SUM(Ilosc*CenaSprzedazy) 'Suma sprzedarzy' 
	FROM tblKlienci INNER JOIN tblSprzedaz 
		ON tblKlienci.ID_Klient = tblSprzedaz.Klient_ID INNER JOIN tblOpisSprzedazy 
		ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
	WHERE YEAR(DataSprzedazy) = 2015
	GROUP BY Miasto
	HAVING SUM(Ilosc*CenaSprzedazy) >= 1000
GO

SELECT *
FROM v_suma_miast_2014
GO

--Zap04 
CREATE VIEW v_klienci_pracownika_3 AS 
	SELECT NazwaFirmy
		,SUM(Ilosc*CenaSprzedazy) 'SUMA'
	FROM tblKlienci INNER JOIN tblSprzedaz 
	ON tblKlienci.ID_Klient = tblSprzedaz.Klient_ID INNER JOIN tblOpisSprzedazy 
	ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
	WHERE Pracownik_ID=3
	GROUP BY NazwaFirmy, ID_Klient
GO

--Zap05 - COUNT
SELECT NazwaFirmy
	,COUNT(ID_Klient)
FROM tblKlienci
GROUP BY NazwaFirmy,ID_Klient
	
--Zap06
--COUNT zlicza nie nullowe komórki
--COUNT najlepiej zliczaæ z kluczy(ID)
--COUNT zlicza ilosc wystapien z najliczniejszej tabeli
SELECT ID_Klient 
	,NazwaFirmy
	,COUNT(ID_Klient) 'Ilosc faktur klienta'
FROM tblKlienci JOIN tblSprzedaz 
	ON tblKlienci.ID_Klient=tblSprzedaz.Klient_ID
GROUP BY NazwaFirmy,ID_Klient

--Zap07
SELECT ID_Klient 
	,NazwaFirmy
	,COUNT(ID_Klient) AS 'Ilosc pozycji na fakturach klienta'
FROM tblKlienci JOIN tblSprzedaz
	ON tblKlienci.ID_Klient=tblSprzedaz.Klient_ID JOIN tblOpisSprzedazy
		ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
GROUP BY NazwaFirmy,ID_Klient

--Zap08 - Podzapytania
/*
SELECT 
FROM 
	(

	) AS nazwa1 ->obowiazkowa nazwa
JOIN
	(

	) AS nazwa2
ON nazwa1.klucz = nazwa2.klucz
*/
SELECT ilosc_faktur.NazwaFirmy
	, [Ilosc faktur klienta]
	, [Ilosc pozycji na fakturach klienta]
FROM
	(
		SELECT ID_Klient 
			,NazwaFirmy
			,COUNT(ID_Klient) 'Ilosc faktur klienta'
		FROM tblKlienci JOIN tblSprzedaz 
			ON tblKlienci.ID_Klient=tblSprzedaz.Klient_ID
		GROUP BY NazwaFirmy,ID_Klient							
	) AS ilosc_faktur
	JOIN
	(
		SELECT ID_Klient 
			,NazwaFirmy
			,COUNT(ID_Klient) AS 'Ilosc pozycji na fakturach klienta'
		FROM tblKlienci JOIN tblSprzedaz
			ON tblKlienci.ID_Klient=tblSprzedaz.Klient_ID JOIN tblOpisSprzedazy
				ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
		GROUP BY NazwaFirmy,ID_Klient	
	) AS ilosc_pozycji
ON ilosc_faktur.ID_Klient=ilosc_pozycji.ID_Klient
GO

--Zap09 - CTE
--common table expression
WITH 
	cte_liczba_faktur AS (
		SELECT ID_Klient 
			,NazwaFirmy
			,COUNT(ID_Klient) 'Ilosc faktur klienta'
		FROM tblKlienci JOIN tblSprzedaz 
			ON tblKlienci.ID_Klient=tblSprzedaz.Klient_ID
		GROUP BY NazwaFirmy,ID_Klient	
	)
	,
	cte_pozycje_faktur AS (
		SELECT ID_Klient 
			,NazwaFirmy
			,COUNT(ID_Klient) AS 'Ilosc pozycji na fakturach klienta'
		FROM tblKlienci JOIN tblSprzedaz
			ON tblKlienci.ID_Klient=tblSprzedaz.Klient_ID JOIN tblOpisSprzedazy
				ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
		GROUP BY NazwaFirmy,ID_Klient	
	)

SELECT f.NazwaFirmy
	,[Ilosc faktur klienta]
	,[Ilosc pozycji na fakturach klienta]
FROM cte_liczba_faktur AS f JOIN cte_pozycje_faktur AS p
	ON f.ID_Klient=p.ID_Klient
GO

--Zap10
CREATE VIEW v_faktury AS 
	SELECT ID_Klient 
		,NazwaFirmy
		,COUNT(ID_Klient) 'Ilosc faktur klienta'
	FROM tblKlienci JOIN tblSprzedaz 
		ON tblKlienci.ID_Klient=tblSprzedaz.Klient_ID
	GROUP BY NazwaFirmy,ID_Klient
GO

CREATE VIEW v_pozycje_faktur AS
	SELECT ID_Klient 
		,NazwaFirmy
		,COUNT(ID_Klient) AS 'Ilosc pozycji na fakturach klienta'
	FROM tblKlienci JOIN tblSprzedaz
		ON tblKlienci.ID_Klient=tblSprzedaz.Klient_ID JOIN tblOpisSprzedazy
			ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
	GROUP BY NazwaFirmy,ID_Klient
GO

SELECT v_faktury.NazwaFirmy
	,[Ilosc faktur klienta]
	,[Ilosc pozycji na fakturach klienta]
FROM v_faktury JOIN v_pozycje_faktur
	ON v_faktury.ID_Klient=v_pozycje_faktur.ID_Klient


--Zap11
SELECT   Imie+' '+Nazwisko 'Imie i nazwisko'
	,COUNT(ID_Sprzedaz) 'ILOSC WYSTAWINYCH FAKTUR'
FROM tblPracownicy INNER JOIN tblSprzedaz 
	ON tblPracownicy.IDPracownika = tblSprzedaz.Pracownik_ID
GROUP BY Imie+' '+Nazwisko, IDPracownika

--Zap12
INSERT INTO tblPracownicy VALUES 
	(12, 'Jan', 'Paliwoda', 'Prezes', 'ul. Jana Paw³a 12' ,'Poznañ', '12-345')

SELECT *
FROM tblPracownicy

SELECT   Imie+' '+Nazwisko 'Imie i nazwisko'
	,COUNT(ID_Sprzedaz) 'ILOSC WYSTAWINYCH FAKTUR'
FROM tblPracownicy LEFT JOIN tblSprzedaz 
	ON tblPracownicy.IDPracownika = tblSprzedaz.Pracownik_ID
GROUP BY Imie+' '+Nazwisko, IDPracownika

--Zap13
-- lista towarów sprzedawanych z ostatnich 5 lat
-- DISTINCT -> usuñ duplikaty
SELECT DISTINCT ID_Towar
	,NazwaTowaru
FROM        tblSprzedaz INNER JOIN
                  tblOpisSprzedazy ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID INNER JOIN
                  tblTowary ON tblOpisSprzedazy.Towar_ID = tblTowary.ID_Towar
WHERE YEAR(DataSprzedazy)>=YEAR(GETDATE())-5

--Zap14
SELECT tblTowary.NazwaTowaru
FROM tblTowary LEFT JOIN (
	SELECT DISTINCT ID_Towar
		,NazwaTowaru
	FROM        tblSprzedaz INNER JOIN
					  tblOpisSprzedazy ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID INNER JOIN
					  tblTowary ON tblOpisSprzedazy.Towar_ID = tblTowary.ID_Towar
	WHERE YEAR(DataSprzedazy)>=YEAR(GETDATE())-5
) AS podzapytanie
	ON tblTowary.ID_Towar=podzapytanie.ID_Towar
WHERE podzapytanie.ID_Towar IS NULL
GO

--Zap15 - procedura sk³adowana
-- @->zmienna, @@->zmienne systemowe
CREATE PROCEDURE p_pracownik(@nr_pracownika AS int) AS 
	SELECT *
	FROM tblSprzedaz
	WHERE Pracownik_ID=@nr_pracownika

--Wywo³anie procedury:
--Nazwa/EXECUTE Nazwa/EXEC Nazwa
EXEC p_pracownik 6

--Zap16
--nr pracownika z zapytania
DECLARE @nr AS int=(
	SELECT IDPracownika
	FROM tblPracownicy
	WHERE Imie='Joanna' AND Nazwisko='kowalska'
)

EXEC p_pracownik @nr
GO


--Zap17
CREATE PROCEDURE p_niesprzedawane_towary (@ilosc_lat AS int) AS
	SELECT *
	FROM tblTowary LEFT JOIN (
		SELECT DISTINCT ID_Towar
			,NazwaTowaru
		FROM        tblSprzedaz INNER JOIN
						  tblOpisSprzedazy ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID INNER JOIN
						  tblTowary ON tblOpisSprzedazy.Towar_ID = tblTowary.ID_Towar
		WHERE YEAR(DataSprzedazy)>=YEAR(GETDATE())-@ilosc_lat
	) AS podzapytanie
		ON tblTowary.ID_Towar=podzapytanie.ID_Towar
	WHERE podzapytanie.ID_Towar IS NULL

EXEC p_niesprzedawane_towary 4
GO

--Zap18
CREATE PROCEDURE p_suma (@nr AS int, @suma AS money OUTPUT) AS
	SELECT @suma=SUM(Ilosc*CenaSprzedazy) 
	FROM tblOpisSprzedazy
	WHERE Sprzedaz_ID=@nr

DECLARE @sum_faktury AS money
EXEC p_suma 5, @sum_faktury OUTPUT 

PRINT 'Suma faktury: '+CAST(@sum_faktury AS nvarchar)

--Zap19
--DELETE s³u¿y do usuwania rekordów tabeli
--DROP s³u¿y do usuwania obiektów np procedura/tabela/widoki itp
DROP PROCEDURE p_suma

--Zap20
--UNION ³¹czy ze sob¹ ¿ród³a danych i ma wbudowan¹ klauzulê DISTINCT
	SELECT Miasto
	FROM tblPracownicy
UNION
	SELECT Miasto
	FROM tblKlienci

	SELECT Miasto
	FROM tblPracownicy
UNION ALL
	SELECT Miasto
	FROM tblKlienci

	SELECT Miasto, REPLACE(KodPocztowy, '-','')
	FROM tblPracownicy
UNION 
	SELECT Miasto, REPLACE(Kod, '-','')
	FROM tblKlienci

--Zap21
--INTERSECT - zwraca dane , je¿eli przynajmniej raz wystêpuj¹ we wszystkich tabelach
SELECT Miasto
	FROM tblPracownicy
INTERSECT
	SELECT Miasto
	FROM tblKlienci

--Zap22
--EXCEPT - od pierwszego zapytania odejmujê wyniki drugiego
SELECT Miasto
	FROM tblPracownicy
EXCEPT
	SELECT Miasto
	FROM tblKlienci

	SELECT Miasto
	FROM  tblKlienci
EXCEPT
	SELECT Miasto
	FROM tblPracownicy

--Zap23
--Konstrukcja warunkowa CASE
SELECT 
	CASE
		WHEN Imie='Anna' AND Nazwisko='Donat' THEN 'Szanowna Pani prezes '
		WHEN RIGHT(Imie,1)='A' THEN 'Pani ' 
		ELSE 'Pan '
	END
	+Imie+' '+Nazwisko 'IMIE I NAZWISKO'
FROM tblPracownicy

