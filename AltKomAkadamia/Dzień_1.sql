/*Kolejnoœæ operatorów
()
* / %(modulo)
+ -
= > < >= <= <> != !> !< (operatory porównania)
NOT
AND
BETWEEN, IN, LIKE, OR
= (przypisanie)
*/


USE SEZAM

-- GO - separator Batcha
-- GO - wystêpujê wy³¹cznie w SSMS i SQLCMD

--Zap01
	SELECT TOP 10 *
	FROM tblKlienci

--Zap02
	SELECT ID_Klient
		, NazwaFirmy
		, Miasto
	FROM tblKlienci

--Zap03
	/*
	LTRIM/RTRIM usuwa puste znaki
	Od SQL 2017 - TRIM 
	*/
	SELECT LTRIM(NazwaTowaru)
		, Cena_Katalogowa
	FROM tblTowary
	ORDER BY LTRIM(NazwaTowaru)

--Zap04
	/*Tworzenie aliasów*/
	SELECT LTRIM(NazwaTowaru) 'Nazwa towaru'
		, Cena_Katalogowa
	FROM tblTowary
	ORDER BY [Nazwa towaru]
	/*sortowanie ASC - domyœlne, DESC - malej¹co (Z-A)*/

--Zap05
	/*WHERE - wielkoœæ liter nie ma znaczenia*/
	SELECT NazwaFirmy
	, Miasto
	FROM tblKlienci
	WHERE Miasto = 'warszawa'

	SELECT NazwaFirmy
	, Miasto
	FROM tblKlienci
	WHERE Miasto <> 'warszawa'

	SELECT NazwaFirmy
	, Miasto
	FROM tblKlienci
	WHERE Miasto != 'warszawa'

	SELECT NazwaFirmy
	, Miasto
	FROM tblKlienci
	WHERE Miasto = 'warszawa' OR Miasto = 'zielonka'

--Zap06
	/*IN*/
	SELECT NazwaFirmy
	, Miasto
	FROM tblKlienci
	WHERE Miasto IN ('warszawa','zielonka')

	SELECT NazwaFirmy
	, Miasto
	FROM tblKlienci
	WHERE Miasto NOT IN ('warszawa','zielonka')

--Zap07
	SELECT ID_Towar
	, NazwaTowaru
	,Cena_Katalogowa
	FROM tblTowary
	WHERE Cena_Katalogowa>=5 AND Cena_Katalogowa<=10

	SELECT ID_Towar
	, NazwaTowaru
	,Cena_Katalogowa
	FROM tblTowary
	WHERE Cena_Katalogowa BETWEEN 5 AND 10

--Zap08 - LIKE (najwolniejsze wykonywane polecenie)
	SELECT * 
	FROM tblKlienci
	WHERE NazwaFirmy LIKE 'd%'

	SELECT * 
	FROM tblKlienci
	WHERE NazwaFirmy LIKE '%A'

	SELECT * 
	FROM tblKlienci
	WHERE NazwaFirmy LIKE '_R%'

	SELECT * 
	FROM tblKlienci
	WHERE NazwaFirmy LIKE '[a-k,s]%'

	SELECT * 
	FROM tblKlienci
	WHERE Kod LIKE '[0-5][^5]%'

--Zap09 - Data na serwerze
	SELECT GETDATE()
	PRINT GETDATE()

--Zap10
	/*	CAST(wartoœæ AS typ_danych) jest standardem ANSI,
	zapewnia kodowi mo¿liwe wysoki poziom standaryzacji.
	*/
	SELECT CAST(GETDATE() AS DATE)

	--data dla excela
	SELECT CAST(GETDATE() AS INT)+1

--Zap11
	SELECT ID_Sprzedaz
		,CAST(DataSprzedazy AS DATE) 'Data'
	FROM tblSprzedaz

Zap12
	--Zmiana pocz¹tku dnia tygodnia
	SET DATEFIRST 1 -- PN=1 ... ND=7

	SELECT DataSprzedazy
		,YEAR(DataSprzedazy) 'Rok'
		,DATEPART(YEAR, DataSprzedazy) 'Rok 2'
		,DATEPART(QUARTER, DataSprzedazy) 'Kwarta³'
		,MONTH(DataSprzedazy) 'Miesi¹c'
		,DATEPART(WEEK, DataSprzedazy) 'Tydzieñ roku'
		,DATEPART(MONTH, DataSprzedazy) 'Miesi¹c 2'
		,DATEPART(WEEKDAY, DataSprzedazy) 'Dzieñ tygodnia'
		,DATEPART(DAY, DataSprzedazy) 'Dzieñ miesi¹ca'
		,DATEPART(DAYOFYEAR, DataSprzedazy) 'Dzieñ roku'
	FROM tblSprzedaz

--Zap13
	SELECT Imie+' '+Nazwisko 'Imie i nazwisko'
	, CONCAT(Imie, ' ', Nazwisko) 'CONCAT'
	--LEFT/RIGHT
	,LEFT(Nazwisko,3) '3 PIERWSZE LITERY NAZWISKA'
	--SUBSTRING(string, miejsce_startu,wyciagana_dlugosc)
	, SUBSTRING(Nazwisko,2,3) 'Wyci¹gany tekst'
	--CHARINDEX(szukany_kod, przeszukiwany_obiekt, start_lokation)
	, CHARINDEX('ul.', Adres, 1) 'SZUKANY ZNAK UL.'
	, LEN(Nazwisko) 'Iloœæ znaków'
	--REPLACE(string, co_zatepujemy, czym_zastepujemy)
	, REPLACE (Adres, 'ul.', 'UL.') 'Zastêpowanie ul. na UL.'
	--LOWER/UPPER
	,UPPER(Nazwisko) 'Duze litery'
	FROM tblPracownicy

--Zap14 - agregacje (SUM/AVG/MAX/MIN/COUNT)
	SELECT Sprzedaz_ID
		,SUM(Ilosc) 'Suma z iloœci'
	FROM tblOpisSprzedazy
	GROUP BY Sprzedaz_ID

--Zap15
	SELECT Sprzedaz_ID
		,SUM(Ilosc*CenaSprzedazy) 'Suma faktury'
	FROM tblOpisSprzedazy
	GROUP BY Sprzedaz_ID

--Zap16 - JOIN=INNER JOIN
	/*
	SELECT
	FROM tabela1 JOIN tabela2
		ON tabela1.klucz = tabela2.klucz
	*/
	SELECT ID_Towar
		,NazwaTowaru
		,SUM(Ilosc) 'Suma ilosci'
	FROM tblOpisSprzedazy JOIN tblTowary
		ON tblOpisSprzedazy.Towar_ID=tblTowary.ID_Towar
	GROUP BY ID_Towar, NazwaTowaru

--Zap17 - JOIN + Alisy
	SELECT Imie+' '+Nazwisko 'Imie i nazwisko'
		,SUM(Ilosc*CenaSprzedazy) 'Suma sprzeda¿y pracownika'
	FROM tblPracownicy p JOIN tblSprzedaz s
		ON p.IDPracownika=s.Pracownik_ID JOIN tblOpisSprzedazy os
			ON s.ID_Sprzedaz = os.Sprzedaz_ID
	GROUP BY Imie+' '+Nazwisko, IDPracownika

--Zap18
	SELECT k.NazwaFirmy
		,kat.NazwaKategorii
		,SUM(os.Ilosc*os.CenaSprzedazy) 'Suma sprzedarzy'
	FROM tblKlienci k JOIN tblSprzedaz s 
		ON k.ID_Klient=s.Klient_ID JOIN tblOpisSprzedazy os
			ON s.ID_Sprzedaz=os.Sprzedaz_ID JOIN tblTowary t 
				ON os.Towar_ID=t.ID_Towar JOIN tblKategorie kat
					ON t.Kategoria_ID=kat.ID_Kategoria
	GROUP BY  k.NazwaFirmy
		,kat.NazwaKategorii
		,ID_Klient
		,ID_Kategoria

--Zap19 - QUERY DESIGNER
	SELECT NazwaKategorii
		,NazwaTowaru
		,SUM(Ilosc*CenaSprzedazy) 'Suma sprzedarzy'
	FROM tblOpisSprzedazy INNER JOIN
    tblTowary ON tblOpisSprzedazy.Towar_ID = tblTowary.ID_Towar INNER JOIN
    tblKategorie ON tblTowary.Kategoria_ID = tblKategorie.ID_Kategoria
	GROUP BY NazwaKategorii
		,NazwaTowaru
		,ID_Kategoria
		,ID_Towar

