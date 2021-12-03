--zad1a
SELECT LPAD('-', 2 * (LEVEL - 1), '|-') || T.OWNER || '.' || T.TYPE_NAME ||' (FINAL:' || T.FINAL || ', INSTANTIABLE:' || T.INSTANTIABLE ||', ATTRIBUTES:' || T.ATTRIBUTES || ', METHODS:' || T.METHODS || ')' 
FROM ALL_TYPES T
START WITH T.TYPE_NAME = 'ST_GEOMETRY'
CONNECT BY PRIOR T.TYPE_NAME = T.SUPERTYPE_NAME AND PRIOR T.OWNER = T.OWNER;

--zad1b
SELECT DISTINCT M.METHOD_NAME
FROM ALL_TYPE_METHODS M
WHERE M.TYPE_NAME LIKE 'ST_POLYGON' AND M.OWNER = 'MDSYS'
ORDER BY 1;

--zad1c
CREATE TABLE MYST_MAJOR_CITIES (
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME VARCHAR2(40),
    STGEOM ST_POINT
);

--zad1d
INSERT INTO MYST_MAJOR_CITIES
SELECT FIPS_CNTRY, CITY_NAME, TREAT(ST_POINT.FROM_SDO_GEOM(GEOM) AS ST_POINT) AS STGEOM
FROM MAJOR_CITIES;

--zad2a
INSERT INTO MYST_MAJOR_CITIES 
VALUES ('PL', 'Szczyrk', TREAT(ST_POINT.FROM_WKT('POINT (19.036107 49.718655)') AS ST_POINT));

--zad2b
SELECT NAME, TREAT(ST_POINT.FROM_SDO_GEOM(GEOM) AS ST_GEOMETRY).GET_WKT() AS WKT 
FROM RIVERS;

--zad2c
SELECT SDO_UTIL.TO_GMLGEOMETRY(ST_POINT.GET_SDO_GEOM(STGEOM)) AS GML 
FROM MYST_MAJOR_CITIES
WHERE CITY_NAME = 'Szczyrk';

--zad3a
CREATE TABLE MYST_COUNTRY_BOUNDARIES (
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM ST_MULTIPOLYGON
);

--zad3b
INSERT INTO MYST_COUNTRY_BOUNDARIES
SELECT FIPS_CNTRY, CNTRY_NAME, ST_MULTIPOLYGON(GEOM)
FROM COUNTRY_BOUNDARIES;

--zad3c
SELECT B.STGEOM.ST_GEOMETRYTYPE() AS TYP_OBIEKTU, COUNT(*) AS ILE
FROM MYST_COUNTRY_BOUNDARIES B
GROUP BY B.STGEOM.ST_GEOMETRYTYPE();

--zad3d
SELECT B.STGEOM.ST_ISSIMPLE()
FROM MYST_COUNTRY_BOUNDARIES B;

--zad4a
--Błąd spowodowany jest brakiem informacji odnośnie przestrzennego układu odniesienia (SRID) dla wcześniej dodanego miasta 'Szczyrk'

UPDATE MYST_MAJOR_CITIES B SET B.STGEOM = ST_POINT(B.STGEOM.ST_X(), B.STGEOM.ST_Y(), 8307) 
WHERE B.CITY_NAME = 'Szczyrk';


SELECT B.CNTRY_NAME, COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES B, MYST_MAJOR_CITIES C
WHERE C.STGEOM.ST_WITHIN(B.STGEOM) = 1
GROUP BY B.CNTRY_NAME;

--zad4b
SELECT A.CNTRY_NAME AS A_NAME, B.CNTRY_NAME AS B_NAME
FROM MYST_COUNTRY_BOUNDARIES A, MYST_COUNTRY_BOUNDARIES B
WHERE A.STGEOM.ST_TOUCHES(B.STGEOM) = 1 AND B.CNTRY_NAME = 'Czech Republic';

--zad4c
SELECT DISTINCT A.CNTRY_NAME, B.NAME
FROM MYST_COUNTRY_BOUNDARIES A, RIVERS B
WHERE ST_LINESTRING(B.GEOM).ST_INTERSECTS(A.STGEOM) = 1 AND A.CNTRY_NAME = 'Czech Republic';

--zad4d
SELECT ROUND(TREAT(A.STGEOM.ST_UNION(B.STGEOM) AS ST_POLYGON).ST_AREA(), -2) AS POWIERZCHNIA
FROM MYST_COUNTRY_BOUNDARIES A, MYST_COUNTRY_BOUNDARIES B
WHERE A.CNTRY_NAME = 'Czech Republic' AND B.CNTRY_NAME = 'Slovakia';

--zad4e
SELECT A.STGEOM AS OBIEKT, A.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(B.GEOM)).ST_GEOMETRYTYPE() AS WEGRY_BEZ
FROM MYST_COUNTRY_BOUNDARIES A, WATER_BODIES B
WHERE A.CNTRY_NAME = 'Hungary' AND B.NAME = 'Balaton';

--zad5a
EXPLAIN PLAN FOR
SELECT A.CNTRY_NAME AS A_NAME, COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES A, MYST_MAJOR_CITIES B
WHERE SDO_WITHIN_DISTANCE(B.STGEOM, A.STGEOM, 'distance=100 unit=km') = 'TRUE' AND A.CNTRY_NAME = 'Poland'
GROUP BY A.CNTRY_NAME;

SELECT PLAN_TABLE_OUTPUT 
FROM TABLE(DBMS_XPLAN.DISPLAY);

--zad5b
INSERT INTO USER_SDO_GEOM_METADATA
SELECT 'MYST_MAJOR_CITIES', 'STGEOM', T.DIMINFO, T.SRID
FROM ALL_SDO_GEOM_METADATA T
WHERE T.TABLE_NAME = 'MAJOR_CITIES';

--zad5c
CREATE INDEX MYST_MAJOR_CITIES_IDX 
ON MYST_MAJOR_CITIES(STGEOM) INDEXTYPE 
IS MDSYS.SPATIAL_INDEX_V2;

--zad5d
EXPLAIN PLAN FOR
SELECT A.CNTRY_NAME AS A_NAME, COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES A, MYST_MAJOR_CITIES B
WHERE SDO_WITHIN_DISTANCE(B.STGEOM, A.STGEOM, 'distance=100 unit=km') = 'TRUE' AND A.CNTRY_NAME = 'Poland'
GROUP BY A.CNTRY_NAME;

SELECT PLAN_TABLE_OUTPUT 
FROM TABLE(DBMS_XPLAN.DISPLAY);

--Odp: Założone indeksy zostały wykorzystane w planie wykonania zapytania