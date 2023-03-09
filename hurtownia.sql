/*Wyświetl imię i nazwisko klienta jako jedną kolumnę „Klient” oraz MiastoKlienta dla klientów z województw śląskiego*/

SELECT CONCAT(SUBSTRING(K1.ImieKlienta, 1, 1), SUBSTRING(K1.NazwiskoKlienta, 1, 1)) AS 'Inicjaly', K1.MiastoKlienta
FROM Klienci AS K1
    JOIN Wojewodztwa
        ON K1.IDwojewodztwa = Wojewodztwa.IDwojewodztwa AND Wojewodztwa.IDwojewodztwa = 12;

/*Wyświetl informację o rowerach w postaci : Nazwa roweru, Opis roweru, Cena jednostkowa, Nazwa producenta i Nazwa kategorii, dla rowerów z kategorii „Rower górski” */

SELECT R1.NazwaRoweru, R1.OpisRoweru, R1.CenaJednostkowa, P1.NazwaProducenta, KR.NazwaKategorii
FROM Rowery AS R1
    JOIN Producenci AS P1
        ON R1.IDproducenta = P1.IDproducenta
    JOIN KategorieRowerow KR
        ON R1.IDkategorii = KR.IDkategorii
WHERE KR.NazwaKategorii = 'Rower górski';

/*Wyświetl indormację ilo rowerów należy do danej kategorii*/

SELECT KR2.NazwaKategorii, COUNT(R.NazwaRoweru) AS 'Ilosc'
FROM Rowery AS R
    JOIN KategorieRowerow AS KR2
        ON R.IDkategorii = KR2.IDkategorii
GROUP BY KR2.NazwaKategorii
HAVING COUNT(R.NazwaRoweru) >= 2;

/*Wyświetl informację o sprzedażach: DataSprzedaży, WartośćSprzedaży (jako obliczona wartość na podstawie ilości i ceny jednostkowej), NazwaRoweru dla klientów z województwa śląskiego. */

SELECT S.DataSprzedazy, (SS.Ilosc * SS.CenaJednostkowa) AS 'Wartosc', R2.NazwaRoweru, K2.IDwojewodztwa
FROM Sprzedaze AS S
    JOIN SzczegolySprzedazy SS
        ON S.IDsprzedazy = SS.IDsprzedazy
    JOIN Rowery R2 on
        SS.IDroweru = R2.IDroweru
    JOIN Klienci AS K2
        ON S.IDklienta = K2.IDklienta AND K2.IDwojewodztwa = '12';

/*Laczna kwota sprzedazy dla danej kategorii rowerow*/

SELECT KR.NazwaKategorii, SUM(SzczegolySprzedazy.Ilosc * SzczegolySprzedazy.CenaJednostkowa) AS 'Suma sprzedazy'
FROM Rowery
    JOIN KategorieRowerow KR on Rowery.IDkategorii = KR.IDkategorii
    JOIN SzczegolySprzedazy ON Rowery.IDroweru = SzczegolySprzedazy.IDroweru
GROUP BY KR.NazwaKategorii;

/*Wyświetl 2 najsłabszych pracowników, czyli takich którzy dokonali sprzedaży na najmniejsze  kwoty. Zapytanie powinno zwrócić Imie i nazwisko pracownika oraz całkowitą kwotę na jaką sprzedał rowery */

SELECT TOP 2 P.ImiePracownika, P.NazwiskoPracownika,  SUM(SS.Ilosc * SS.CenaJednostkowa) AS "Suma dokananych sprzedazy"
FROM Pracownicy AS P
    JOIN Sprzedaze S
        on P.IDpracownika = S.IDpracownika
    JOIN SzczegolySprzedazy SS
        on S.IDsprzedazy = SS.IDsprzedazy
GROUP BY P.ImiePracownika, P.NazwiskoPracownika
ORDER BY SUM(SS.Ilosc * SS.CenaJednostkowa) ASC;



CREATE TABLE dbo.info_sprzedaze (
  id int NOT NULL IDENTITY (1,1),
  dataSprzedazy date DEFAULT NULL,
  nazwaRoweru varchar(30) DEFAULT NULL,
  wartosc decimal(8,2) DEFAULT NULL,
  klient varchar(50) DEFAULT NULL,
  pracownik varchar(50) DEFAULT NULL
);

INSERT INTO info_sprzedaze (dataSprzedazy, nazwaRoweru, wartosc, klient, pracownik)
(SELECT dbo.Sprzedaze.DataSprzedazy, dbo.Rowery.NazwaRoweru, dbo.SzczegolySprzedazy.CenaJednostkowa*dbo.SzczegolySprzedazy.Ilosc, CONCAT(dbo.Klienci.ImieKlienta, ' ', dbo.Klienci.NazwiskoKlienta), CONCAT(dbo.Pracownicy.ImiePracownika, ' ', dbo.Pracownicy.NazwiskoPracownika)
 FROM Sprzedaze
 JOIN SzczegolySprzedazy
 ON Sprzedaze.IDsprzedazy = SzczegolySprzedazy.IDsprzedazy
JOIN Klienci
on Sprzedaze.IDklienta = klienci.IDklienta
JOIN Pracownicy
    ON Sprzedaze.IDpracownika = Pracownicy.IDpracownika
 JOIN Rowery
     on Rowery.IDroweru = SzczegolySprzedazy.IDroweru
);

ALTER TABLE dbo.KategorieRowerow
ADD RoznicaCen DECIMAL(10,2) NULL;

UPDATE dbo.KategorieRowerow
SET dbo.KategorieRowerow.RoznicaCen = (SELECT MAX(dbo.Rowery.CenaJednostkowa) - MIN(dbo.Rowery.CenaJednostkowa)
FROM dbo.Rowery
WHERE dbo.Rowery.IDkategorii = dbo.KategorieRowerow.IDkategorii
GROUP BY Rowery.IDkategorii)
;

/*Ćwiczenie2: Wyświetl nazwę roweru i jego cenę jednostkową, ale dla tych rowerów których cena jednostkowa jest powyżej średniej ceny wszystkich rowerów w hurtowni.*/
SELECT R2.NazwaRoweru, R2.CenaJednostkowa
FROM Rowery R2
WHERE R2.CenaJednostkowa > (SELECT AVG(R1.CenaJednostkowa)
                  FROM Rowery R1)
