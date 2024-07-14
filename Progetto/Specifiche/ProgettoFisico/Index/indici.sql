SELECT * FROM pg_stat_user_indexes;
SELECT * FROM pg_stat_user_tables;

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

VINCOLI INUTILI

----------------------------------------------------------------------------------------------------------------------------------------------------
--- A1) ELENCARE LE PRODUZIONI COMPOSTE DA UN DETERMINATO ARTISTA ------ NON ACCETTABILE [INUTILE] -------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

-- Genera Produzione ed Artista
CREATE OR REPLACE FUNCTION insert_data_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP

        -- Genera Artista
		CALL AggiungiArtista('SoloCiccio ' || i, '2024-12-07');
		
        -- Genera Produzione
        INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
		('Album ' || i, 'SoloCiccio ' || i, '2020-02-01', '2020-06-01', 'Pubblicazione'   , 'Album' , 'Rock');

        i := i + 1;
    END LOOP;

    WHILE i <= N+w + 150  LOOP

        -- Genera Produzione
	  
        INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
		('Album ' || i, 'SoloCiccio 1000', '2023-02-01', '2023-06-01', 'Pubblicazione'   , 'Album'   , 'Rock');
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
SELECT insert_data_multiple_times(300, 10300);

--------------------------------------------------------------------------

-- Index
DROP INDEX IF EXISTS artista_produzione_indx;
CREATE INDEX artista_produzione_indx ON produzione (artista);

--------------------------------------------------------------------------

-- Query
EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
    SELECT * FROM produzione AS p WHERE artista = 'SoloCiccio 1000';

--------------------------------------------------------------------------

10 k || 1 ms -> .035 ms

Decidiamo di non utilizzare l indice perchè:
[ ] E difficile che otterremo un numero di produzioni molto alto;
[ ] ...e comunque su 10mila record 1ms è accettabile.
[ ] ... provare con i clusters

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------
--- O8) CONTARE L'AMMONTARE SPESO DA UN ARTISTA E IL NUMERO DI ORDINI EFFETTUATI ------ NON ACCETTABILE [VINCOLO DUPLICATO]-------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

--- Genera gli Ordini
CREATE OR REPLACE FUNCTION insert_multiple_ordini_giornalieri(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP

        -- Genera Artista
		CALL AggiungiArtista('SoloXZ ' || i, '2024-12-07');
     	
        -- Genera Ordine di tipo Pacchetto
        CALL CreaOrdinePacchetto('OPRABC90A01H501X', 'SoloXZ ' || i, 'Giornaliera');  

     	i = i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
SELECT insert_multiple_ordini_giornalieri(1, 30000);

--------------------------------------------------------------------------

-- Indice
DROP INDEX IF EXISTS artista_produzione_indx;
CREATE INDEX ordine_artista_indx ON ordine(artista);

--------------------------------------------------------------------------

-- Query
EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
    SELECT SUM(p.costo_totale) AS costo_totale, count(*) AS numero_ordini
    FROM PAGAMENTO AS p
    JOIN ORDINE AS o ON p.ordine = o.codice
    WHERE o.artista = 'SoloXZ 25000';

--------------------------------------------------------------------------

30 k || 5 ms -> .05 ms

[x] La query diventa 'lenta' man mano aumenta il numero di 'ordini'. L indice 'ordine_artista_indx' velocizza drasticamente la query.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------




























----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

VINCOLI TROVATI

----------------------------------------------------------------------------------------------------------------------------------------------------
--- O7) ELENCARE GLI ORDINI CHE NON SONO ANCORA STATI PAGATI ------ ACCETTABILE - MATTEO -----------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

-- Genera gli Ordini
CREATE OR REPLACE FUNCTION insert_data_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
		CALL AggiungiArtista('SoloXYZ ' || i, '2024-12-07');
        CALL CreaOrdinePacchetto('OPRABC90A01H501X', 'SoloXYZ ' || i, 'Mensile');
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
SELECT insert_data_multiple_times(0, 100000);

-- Genera gli Gruppi
CREATE OR REPLACE FUNCTION insert_data_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
		CALL CreaArtistaGruppo('Gruppo ' || i, '2024-06-09', i || 'artista@email.com', '' || i, '2024-01-01');
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT insert_data_multiple_times(0, 100000);

--------------------------------------------------------------------------

-- Indice
DROP INDEX IF EXISTS ordine_artista_indx;
CREATE INDEX ordine_artista_indx ON ordine (artista);

--------------------------------------------------------------------------

-- Query
EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
    SELECT p.ordine, sub.nome_arte, sub.numero, sub.timestamp
    FROM PAGAMENTO AS p
    JOIN ( 
        SELECT a.nome_arte, o.codice, te.numero, o.timestamp
        FROM ORDINE AS o, ARTISTA AS a, GRUPPO AS g, TELEFONO_A AS te
        WHERE o.artista = a.nome_arte 
        AND g.artista = a.nome_arte
        AND te.artista = a.nome_arte
    ) as sub ON p.ordine = sub.codice WHERE p.stato = 'Da pagare';

--------------------------------------------------------------------------

100 k || 20 ms -> .120 ms

[x] La query diventa molto 'lenta' man mano aumenta il numero di 'ordini'. L indice 'ordine_artista_indx' velocizza drasticamente la query.
[ ] Un altro problema sorge nell aumentare il numero di 'gruppi'. In questo caso non è stato individuato nessun indice che possa velocizzare la query.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------
--- O9) VISUALIZZA INFORMAZIONI PRODUZIONI AVVENUTE DOPO DATA FORNITA ------ ACCETTABILE - PATRINI -----------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

-- Genera le Produzioni e gli Artisti
CREATE OR REPLACE FUNCTION insert_data_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP

        -- Genera Artista
		CALL AggiungiArtista('SoloCiccio ' || i, '2024-12-07');
		
        -- Genera Produzione
        INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
		('Album ' || i, 'SoloCiccio ' || i, '2020-02-01', '2020-06-01', 'Pubblicazione'   , 'Album' , 'Rock');

        i := i + 1;
    END LOOP;

    WHILE i <= N+w + 1500  LOOP

        -- Genera Produzione
        INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
		('Album ' || i, 'SoloCiccio 1000', '2023-02-01', '2023-06-01', 'Pubblicazione'   , 'Album'   , 'Rock');

        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
SELECT insert_data_multiple_times(0, 30000);

--------------------------------------------------------------------------

-- Indice
DROP INDEX IF EXISTS data_inizio_produzione_indx;
CREATE INDEX data_inizio_produzione_indx on PRODUZIONE(data_inizio);

--------------------------------------------------------------------------

-- Query
EXPLAIN (ANALYSE, BUFFERS, VERBOSE)
    SELECT * FROM PRODUZIONE
    WHERE data_inizio >= '2023-01-01';

--------------------------------------------------------------------------

30 k || 16 ms -> .2 ms

[x] La query diventa 'lenta' man mano aumenta il numero di 'produzioni'. L indice 'data_inizio_produzione_indx' velocizza drasticamente la query.