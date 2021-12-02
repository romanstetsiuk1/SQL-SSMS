USE SEZAM

--Zap01
SELECT Miasto
		,COUNT(ID_Klient) AS 'Ilosc klientów z danego miasta'
FROM tblKlienci
GROUP BY Miasto

--Zap02
--Suma sprzedazy miast klientów
SELECT  Miasto
		,SUM(Ilosc*CenaSprzedazy) AS 'Suma miast'      
FROM            tblKlienci INNER JOIN
                         tblSprzedaz ON tblKlienci.ID_Klient = tblSprzedaz.Klient_ID INNER JOIN
                         tblOpisSprzedazy ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
GROUP BY Miasto

--Zap03SELECT Ilosc_miast.Miasto		,[Ilosc klientów z danego miasta]		,[Suma miast]FROM 	(			SELECT Miasto
					,COUNT(ID_Klient) AS 'Ilosc klientów z danego miasta'
			FROM tblKlienci
			GROUP BY Miasto	) AS Ilosc_miastJOIN	(			SELECT  Miasto
					,SUM(Ilosc*CenaSprzedazy) AS 'Suma miast'      
			FROM            tblKlienci INNER JOIN
									 tblSprzedaz ON tblKlienci.ID_Klient = tblSprzedaz.Klient_ID INNER JOIN
									 tblOpisSprzedazy ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
			GROUP BY Miasto	) AS suma_miastON Ilosc_miast.Miasto =  suma_miast.Miasto

--Zap04 Funkcje Rankingowe
--Wszystkie funkcje rankingowe wymagaj¹ zastosowania funkcji OVER-funkcja okna
--Dwa cele OVER(podzielenie danych na grupy i wskazanie kierunku u³o¿enia danych do numerowania)

SELECT   NazwaTowaru
		,SUM(Ilosc) AS Suma_ilosci    
		,ROW_NUMBER() OVER(ORDER BY SUM(Ilosc) DESC) AS 'Ranking towarów'
FROM            tblTowary INNER JOIN
                         tblOpisSprzedazy ON tblTowary.ID_Towar = tblOpisSprzedazy.Towar_ID
GROUP BY NazwaTowaru, ID_Towar

--Zap05
--Numerowanie z uwzglêdnianiem takich samych wartoœci. Numeracja z dziurami
SELECT   NazwaTowaru
		,SUM(Ilosc) AS Suma_ilosci    
		,RANK() OVER(ORDER BY SUM(Ilosc) DESC) AS 'Ranking towarów'
FROM            tblTowary INNER JOIN
                         tblOpisSprzedazy ON tblTowary.ID_Towar = tblOpisSprzedazy.Towar_ID
GROUP BY NazwaTowaru, ID_Towar

--Zap06
--Numerowanie z uwzglêdnianiem takich samych wartoœci. Numeracja bez dziur
SELECT   NazwaTowaru
		,SUM(Ilosc) AS Suma_ilosci    
		,DENSE_RANK() OVER(ORDER BY SUM(Ilosc) DESC) AS 'Ranking towarów'
FROM            tblTowary INNER JOIN
                         tblOpisSprzedazy ON tblTowary.ID_Towar = tblOpisSprzedazy.Towar_ID
GROUP BY NazwaTowaru, ID_Towar

--Zap07
SELECT ID_Towar
		,NazwaTowaru
		,NTILE(5) OVER(ORDER BY id_towar) AS 'Grupy'
FROM tblTowary

--Zap08
--Ranking cen towarów z podzia³em na kategorie
SELECT  NazwaKategorii
		,NazwaTowaru
		,Cena_Katalogowa 
		,DENSE_RANK() OVER(PARTITION BY NazwaKategorii ORDER BY Cena_Katalogowa DESC) AS 'Ranking cen w kategoriach'
FROM            tblKategorie INNER JOIN
                         tblTowary ON tblKategorie.ID_Kategoria = tblTowary.Kategoria_ID

--Zap09
--Wybieramy najdro¿sze produkty w swojej kategorii
SELECT *
FROM (
		SELECT  NazwaKategorii
				,NazwaTowaru
				,Cena_Katalogowa 
				,DENSE_RANK() OVER(PARTITION BY NazwaKategorii ORDER BY Cena_Katalogowa DESC) AS 'Ranking cen w kategoriach'
		FROM            tblKategorie INNER JOIN
								 tblTowary ON tblKategorie.ID_Kategoria = tblTowary.Kategoria_ID
	) AS podzapytanie
WHERE [Ranking cen w kategoriach] = 1


--Zap10
--Suma narastaj¹ca
SELECT   YEAR(DataSprzedazy) AS Rok     
		,SUM(Ilosc*CenaSprzedazy) AS 'Suma lat'
		,SUM(SUM(Ilosc*CenaSprzedazy)) OVER(ORDER BY YEAR(DataSprzedazy)) AS 'Suma narastaj¹ca'
FROM            tblSprzedaz INNER JOIN
                         tblOpisSprzedazy ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
GROUP BY YEAR(DataSprzedazy)

--Zap11
--ROLLUP rozszerza funkcjonalnoœæ klauzuli GROUP BY, o mo¿liwoœæ tworzenia tzw. kostek analitycznych po³ówkowych
SELECT     Miasto
			,YEAR(DataSprzedazy) AS 'Rok'
			, SUM(Ilosc*CenaSprzedazy) AS 'Suma sprzedazy'  
FROM            tblKlienci INNER JOIN
                         tblSprzedaz ON tblKlienci.ID_Klient = tblSprzedaz.Klient_ID INNER JOIN
                         tblOpisSprzedazy ON tblSprzedaz.ID_Sprzedaz = tblOpisSprzedazy.Sprzedaz_ID
GROUP BY Miasto, ROLLUP(YEAR(DataSprzedazy))

--Zap12
SELECT     NazwaKategorii
			,ISNULL(NazwaTowaru,NazwaKategorii + ' Suma:') AS 'Nazwa Towaru'
			,SUM(Ilosc*CenaSprzedazy) AS 'Suma sprzedazy'  
FROM            tblKategorie INNER JOIN
                         tblTowary ON tblKategorie.ID_Kategoria = tblTowary.Kategoria_ID INNER JOIN
                         tblOpisSprzedazy ON tblTowary.ID_Towar = tblOpisSprzedazy.Towar_ID
GROUP BY ROLLUP(NazwaKategorii,NazwaTowaru)

--Zap13
SELECT     NazwaKategorii
			,NazwaTowaru
			,SUM(Ilosc*CenaSprzedazy) AS 'Suma sprzedazy'  
FROM            tblKategorie INNER JOIN
                         tblTowary ON tblKategorie.ID_Kategoria = tblTowary.Kategoria_ID INNER JOIN
                         tblOpisSprzedazy ON tblTowary.ID_Towar = tblOpisSprzedazy.Towar_ID
GROUP BY CUBE(NazwaKategorii,NazwaTowaru)

--Zap14
SELECT	SUM(Ilosc*CenaSprzedazy) AS 'Suma calosci'
FROM tblOpisSprzedazy

--Zap15
--Udzia³ % miast klientów w ca³ej sprzeda¿y
SELECT  Miasto
		,SUM(Ilosc*CenaSprzedazy) AS 'Suma miast'  
		,SUM(Ilosc*CenaSprzedazy)  / (
										SELECT	SUM(Ilosc*CenaSprzedazy) AS 'Suma calosci'
										FROM tblOpisSprzedazy		
									) AS Udzial_proc   
FROM            tblKlienci INNER JOIN
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
