--ZAD1
CREATE TYPE SAMOCHOD
AS OBJECT 
(
    MARKA VARCHAR2(20),
    MODEL   VARCHAR2(20),
    KILOMETRY     NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10,2)
);
    
CREATE TABLE SAMOCHODY OF SAMOCHOD;

INSERT INTO SAMOCHODY 
VALUES (NEW SAMOCHOD('FIAT', 'BRAVA', 60000, TO_DATE('30-11-1999','DD-MM-YYYY'), 25000));

INSERT INTO SAMOCHODY 
VALUES (NEW SAMOCHOD('FORD', 'MONDEO', 80000, TO_DATE('31-05-1997','DD-MM-YYYY'), 45000));

INSERT INTO SAMOCHODY 
VALUES (NEW SAMOCHOD('MAZDA', '323', 12000, TO_DATE('22-09-1999','DD-MM-YYYY'), 52000));
2
SELECT * FROM samochody;
--ZAD2
CREATE TABLE WLASCICIELE
(
    IMIE VARCHAR2(100), 
    NAZWISKO   VARCHAR2(100), 
    AUTO     SAMOCHOD
);

INSERT INTO WLASCICIELE VALUES ('JAN', 'KOWALSKI', NEW SAMOCHOD('FIAT', 'SEICENTO', 30000, TO_DATE('02-12-0010','DD-MM-YYYY'), 19500));

INSERT INTO WLASCICIELE VALUES ('ADAM', 'NOWAK',NEW SAMOCHOD('OPEL', 'ASTRA', 34000, TO_DATE('01-06-0009','DD-MM-YYYY'), 33700));

select * from wlasciciele;
--ZAD3
ALTER TYPE SAMOCHOD ADD MEMBER FUNCTION WARTOSC RETURN NUMBER CASCADE;

CREATE OR REPLACE TYPE BODY SAMOCHOD AS 
    MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        BEGIN
            RETURN POWER(0.9, EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM DATA_PRODUKCJI)) * CENA;
        END WARTOSC;
END;

--ZAD4
ALTER TYPE SAMOCHOD ADD MAP MEMBER FUNCTION odwzoruj RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN POWER(0.9,EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_PRODUKCJI))*CENA;
    END wartosc;
    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS 
    BEGIN
        RETURN CEIL(KILOMETRY / 10000) + EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_PRODUKCJI);
    END odwzoruj;
END;
SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);
--ZAD5
CREATE TYPE TWLASCICIEL AS OBJECT (
    IMIE VARCHAR2(100),
    NAZWISKO VARCHAR2(100)
);

ALTER TYPE SAMOCHOD ADD ATTRIBUTE WLASCICIEL REF TWLASCICIEL CASCADE;

CREATE TABLE WLASCICIELE_NAMES OF TWLASCICIEL;

INSERT INTO WLASCICIELE_NAMES VALUES(NEW TWLASCICIEL('JAN', 'KOWALSKI'));
INSERT INTO WLASCICIELE_NAMES VALUES(NEW TWLASCICIEL('PIOTR', 'NOWAK'));
INSERT INTO WLASCICIELE_NAMES VALUES(NEW TWLASCICIEL('ADAM', 'KOS'));

UPDATE SAMOCHODY s
SET s.wlasciciel = (SELECT REF(w) FROM WLASCICIELE_NAMES w WHERE w.nazwisko = 'NOWAK');
SELECT * FROM SAMOCHODY;
--ZAD7
DECLARE
    TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(20);
    moje_ksiazki t_ksiazki := t_ksiazki('');
BEGIN
    moje_ksiazki(1) := 'Harry Potter';
    moje_ksiazki.EXTEND(9);
    FOR i IN 2..10 LOOP
    moje_ksiazki(i) := 'Ksiazka_' || i;
    END LOOP;
    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
    DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
    END LOOP;
    moje_ksiazki.TRIM(2);
    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
    DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
    moje_ksiazki.EXTEND();
    moje_ksiazki(9) := 9;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
    moje_ksiazki.DELETE();
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
END;

--ZAD9
DECLARE
    TYPE t_miesiace IS TABLE OF VARCHAR2(20);
    miesiace t_miesiace := t_miesiace();
BEGIN
    miesiace.EXTEND(2);
    miesiace(1) := 'Styczen';
    miesiace(2) := 'Luty';
    miesiace.EXTEND(10);
    miesiace(3) := 'Marzec';
    miesiace(4) := 'Kwiecien';
    miesiace(5) := 'Maj';
    miesiace(6) := 'Czerwiec';
    miesiace(7) := 'Lipiec';
    miesiace(8) := 'Sierpien';
    miesiace(9) := 'Wrzesien';
    miesiace(10) := 'Pazdziernik';
    miesiace(11) := 'Listopad';
    miesiace(12) := 'Grudzien';
    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
    DBMS_OUTPUT.PUT_LINE(miesiace(i));
    END LOOP;
    miesiace.TRIM(2);
    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
    DBMS_OUTPUT.PUT_LINE(miesiace(i));
    END LOOP;
    miesiace.DELETE(5,7);
    DBMS_OUTPUT.PUT_LINE('Limit: ' || miesiace.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || miesiace.COUNT());
    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
    IF miesiace.EXISTS(i) THEN
    DBMS_OUTPUT.PUT_LINE(miesiace(i));
    END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Limit: ' || miesiace.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || miesiace.COUNT());
END;

--ZAD11
CREATE TYPE t_koszyk_t AS TABLE OF VARCHAR2(20);

CREATE TYPE t_zakupy_t AS OBJECT (
 KLIENT VARCHAR2(50),
 KOSZYK_PRODUKTOW t_koszyk_t );

CREATE TABLE ZAKUPY OF t_zakupy_t
NESTED TABLE KOSZYK_PRODUKTOW STORE AS tab_koszyk;

INSERT INTO ZAKUPY VALUES
(t_zakupy_t('Tadeusz', t_koszyk_t('Pieluszki','Piwo','Orzeszki')));
INSERT INTO ZAKUPY VALUES
(t_zakupy_t('Janek', t_koszyk_t('Marmolada','Piwo','Orzeszki')));

select * from ZAKUPY;
SELECT s.klient
FROM ZAKUPY s, TABLE ( s.KOSZYK_PRODUKTOW ) e;
SELECT s.klient
FROM ZAKUPY s, TABLE ( s.KOSZYK_PRODUKTOW ) e
where e.column_value = 'Pieluszki' ;

DELETE FROM ZAKUPY
where klient in (SELECT s.klient
    FROM ZAKUPY s, TABLE ( s.KOSZYK_PRODUKTOW ) e
    where e.column_value = 'Pieluszki' );
select * from ZAKUPY;

--ZAD22
CREATE TABLE PISARZE (
    ID_PISARZA NUMBER PRIMARY KEY,
    NAZWISKO VARCHAR2(20),
    DATA_UR DATE );

CREATE TABLE KSIAZKI (
    ID_KSIAZKI NUMBER PRIMARY KEY,
    ID_PISARZA NUMBER NOT NULL REFERENCES PISARZE,
    TYTUL VARCHAR2(50),
    DATA_WYDANIA DATE );

INSERT INTO PISARZE VALUES(10,'SIENKIEWICZ',DATE '1880-01-01');
INSERT INTO PISARZE VALUES(20,'PRUS',DATE '1890-04-12');
INSERT INTO PISARZE VALUES(30,'ZEROMSKI',DATE '1899-09-11');

INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(10,10,'OGNIEM I MIECZEM',DATE '1990-01-05');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(20,10,'POTOP',DATE '1975-12-09');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(30,10,'PAN WOLODYJOWSKI',DATE '1987-02-15');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(40,20,'FARAON',DATE '1948-01-21');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(50,20,'LALKA',DATE '1994-08-01');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(60,30,'PRZEDWIOSNIE',DATE '1938-02-02');

CREATE TYPE KSIAZKI_T AS TABLE OF VARCHAR2(100);

CREATE TYPE PISARZ AS OBJECT (
    ID_PISARZA NUMBER,
    NAZWISKO VARCHAR2(20),
    DATA_UR DATE,
    KSIAZKI KSIAZKI_T,
    MEMBER FUNCTION ILE_KSIAZEK RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY PISARZ AS
    MEMBER FUNCTION ILE_KSIAZEK RETURN NUMBER IS
    BEGIN
        RETURN KSIAZKI.COUNT();
    END ILE_KSIAZEK;
END;

CREATE TYPE ksiazka AS OBJECT (
    ID_KSIAZKI   NUMBER,
    AUTOR        REF pisarz,
    TYTUL        VARCHAR2(50),
    DATA_WYDANIA DATE,
    MEMBER FUNCTION wiek RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY KSIAZKA AS
    MEMBER FUNCTION WIEK RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_WYDANIA);
    END WIEK;
END;

CREATE OR REPLACE VIEW KSIAZKI_VIEW
    OF ksiazka WITH OBJECT IDENTIFIER ( id_ksiazki )
AS SELECT ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIA FROM KSIAZKI;

CREATE OR REPLACE VIEW PISARZE_VIEW OF PISARZ
WITH OBJECT IDENTIFIER(ID_PISARZA)
AS SELECT ID_PISARZA, NAZWISKO, DATA_UR,
    CAST(MULTISET(SELECT TYTUL FROM KSIAZKI WHERE ID_PISARZA=P.ID_PISARZA) AS KSIAZKI_T)
FROM PISARZE P;

SELECT * FROM PISARZE_VIEW;
SELECT K.DATA_WYDANIA, K.TYTUL, K.WIEK() FROM KSIAZKI_VIEW K;
SELECT P.NAZWISKO, P.ILE_KSIAZEK() FROM PISARZE_VIEW P;
SELECT P.NAZWISKO, K.* FROM PISARZE_VIEW P, TABLE (P.KSIAZKI) K;

--ZAD23
CREATE TYPE AUTO AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10,2),
    MEMBER FUNCTION WARTOSC RETURN NUMBER
) NOT FINAL;

CREATE OR REPLACE TYPE BODY AUTO AS
    MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        WIEK NUMBER;
        WARTOSC NUMBER;
    BEGIN
        WIEK := ROUND(MONTHS_BETWEEN(SYSDATE,DATA_PRODUKCJI)/12);
        WARTOSC := CENA - (WIEK * 0.1 * CENA);
        IF (WARTOSC < 0) THEN
            WARTOSC := 0;
        END IF;
        RETURN WARTOSC;
    END WARTOSC;
END;

CREATE TYPE AUTO_OSOBOWE UNDER AUTO (
    LICZBA_MIEJSC NUMBER,
    CZY_KLIMATYZACJA VARCHAR2(3),
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY AUTO_OSOBOWE AS
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        WARTOSC NUMBER;
    BEGIN
        WARTOSC := (SELF AS AUTO).WARTOSC();
        IF (CZY_KLIMATYZACJA = 'TAK') THEN
            WARTOSC := WARTOSC * 1.5;
        END IF;
        RETURN WARTOSC;
    END;
END;

CREATE TYPE AUTO_CIEZAROWE UNDER AUTO (
    MAKSYMALNA_LADOWNOSC NUMBER,
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY AUTO_CIEZAROWE AS
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        WARTOSC NUMBER;
    BEGIN
        WARTOSC := (SELF AS AUTO).WARTOSC();
        IF (MAKSYMALNA_LADOWNOSC > 10000) THEN
            WARTOSC := WARTOSC * 2;
        END IF;
        RETURN WARTOSC;
    END;
END;

CREATE TABLE AUTA OF AUTO;

INSERT INTO AUTA VALUES (AUTO('FIAT', 'BRAVA', 60000, DATE '2020-11-30', 25000));
INSERT INTO AUTA VALUES (AUTO('FORD', 'MONDEO', 80000, DATE '2020-05-10', 45000));
INSERT INTO AUTA VALUES (AUTO('MAZDA', '323', 12000, DATE '2020-09-22', 52000));

INSERT INTO AUTA VALUES (AUTO_OSOBOWE('SKODA', 'FABIA', 20000, DATE '2020-11-30', 25000, 5, 'TAK'));
INSERT INTO AUTA VALUES (AUTO_OSOBOWE('FORD', 'FIESTA', 40000, DATE '2020-11-30', 45000, 4, 'NIE'));
INSERT INTO AUTA VALUES (AUTO_CIEZAROWE('VOLVO', 'FH4', 80000, DATE '2020-11-30', 50000, 8000));
INSERT INTO AUTA VALUES (AUTO_CIEZAROWE('MAN', 'TGE', 120000, DATE '2020-11-30', 50000, 12000));

SELECT A.MARKA, A.WARTOSC() FROM AUTA A;
SELECT A.*, A.WARTOSC() FROM AUTA A;
