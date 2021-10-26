--ZAD1--
CREATE TABLE movies (
    id          NUMBER(12) PRIMARY KEY,
    title       VARCHAR2(400) NOT NULL,
    category    VARCHAR(50),
    year        CHAR(4),
    cast        VARCHAR2(4000),
    director    VARCHAR2(4000),
    story       VARCHAR2(4000),
    price       NUMBER(5, 2),
    cover       BLOB,
    mime_type   VARCHAR2(50)
)

--ZAD2--
INSERT INTO movies
SELECT
    id,
    title,
    category,
    substr(year, 0, 4),
    cast,
    director,
    story,
    price,
    image,
    mime_type
FROM
    descriptions   d
    LEFT JOIN covers         
    c ON d.id = c.movie_id;

--ZAD3-- 
SELECT ID, TITLE FROM MOVIES
WHERE COVER IS NULL;

--ZAD4--
SELECT ID, TITLE, dbms_lob.getlength(COVER)  AS FILESIZE
FROM MOVIES
WHERE COVER IS NOT NULL;

--ZAD5--
SELECT ID, TITLE, dbms_lob.getlength(COVER) AS FILESIZE
FROM MOVIES
WHERE COVER IS NULL;

--ZAD6--
SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM ALL_DIRECTORIES;

--ZAD7--
UPDATE MOVIES SET COVER = EMPTY_BLOB(), MIME_TYPE = 'image/jpeg'
WHERE ID = 66;

--ZAD8--
SELECT ID, TITLE, dbms_lob.getlength(COVER) AS FILESIZE
FROM MOVIES
WHERE ID = 66 OR ID = 65;

--ZAD9--
DECLARE
    lobd blob;
    fils BFILE := BFILENAME('ZSBD_DIR', 'escape.jpg');
BEGIN
    SELECT COVER INTO lobd
    FROM MOVIES
    WHERE ID = 66
    FOR UPDATE;
    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(lobd, fils, DBMS_LOB.getlength(fils));
    DBMS_LOB.FILECLOSE(fils);
    COMMIT;
END;
    
--ZAD10--

CREATE TABLE temp_covers (
    movie_id    NUMBER(12),
    image       BFILE,
    mime_type   VARCHAR2(50)
);

--ZAD11--

INSERT INTO TEMP_COVERS 
VALUES (65, BFILENAME('ZSBD_DIR', 'eagles.jpg'), 'image/jpeg');

--ZAD12--

SELECT movie_id, dbms_lob.getlength(image) AS FILESIZE
FROM TEMP_COVERS;

--ZAD13--

DECLARE
    lobd blob;
    fils TEMP_COVERS.IMAGE%TYPE;
    MIME TEMP_COVERS.MIME_TYPE%TYPE;
BEGIN
    SELECT IMAGE, MIME_TYPE INTO FILS, MIME
    FROM TEMP_COVERS
    WHERE MOVIE_ID = 65;
    
    DBMS_LOB.CREATETEMPORARY(LOBD, TRUE);
    
    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(lobd, fils, DBMS_LOB.getlength(fils));
    DBMS_LOB.FILECLOSE(fils);
    
    UPDATE MOVIES SET COVER = lobd, MIME_TYPE = MIME 
    WHERE ID = 65;
    
    dbms_lob.freetemporary(LOBD);
    
    COMMIT;
END;

--ZAD14--

SELECT ID, TITLE, dbms_lob.getlength(COVER) AS FILESIZE
FROM MOVIES
WHERE ID = 66 OR ID = 65;
    
--ZAD15--
DROP TABLE MOVIES;
DROP TABLE TEMP_COVERS;
