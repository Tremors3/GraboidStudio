SELECT * FROM pg_stat_user_indexes;
SELECT * FROM pg_stat_user_tables;

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

INDICI INUTILI

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
--- N1) CONTARE L'AMMONTARE SPESO DA UN ARTISTA E IL NUMERO DI ORDINI EFFETTUATI ------ SECONDA MATTE [INDICE DUPLICATO]----------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
FATTO
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
DROP INDEX IF EXISTS artista_ordine_index;
CREATE INDEX artista_ordine_index ON ordine(artista);

--------------------------------------------------------------------------

-- Query
EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
    SELECT SUM(p.costo_totale) AS costo_totale, count(*) AS numero_ordini
    FROM PAGAMENTO AS p
    JOIN ORDINE AS o ON p.ordine = o.codice
    WHERE o.artista = 'SoloXZ 25000';

--------------------------------------------------------------------------

30 k || 3 ms -> .05 ms

[x] La query diventa 'lenta' man mano aumenta il numero di 'ordini'. L indice 'ordine_artista_indx' velocizza drasticamente la query.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------
--- N3) CONTARE IL NUMERO DI PRENOTAZIONI AVVENUTE DOPO UNA DATA ------ SECONDA PATRI --------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

-- Genera le Date
CREATE OR REPLACE FUNCTION insert_multiple_ordini_giornalieri(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
    before_date DATE := '2023-02-03';
    after_date DATE := '2023-02-03';
BEGIN

    WHILE i <= N+w LOOP

        before_date := DATE_ADD(before_date, INTERVAL '-1 day');

        -- Genera Artista
		CALL AggiungiArtista('SoloYZ ' || i, '2019-12-07');
     	
        -- Genera Ordine e Prenotazione Orarie effettuate prima del 2023-01-01
        CALL CreaOrdineEPrenotazioneOrarie(
            'OPRABC90A01H501X', 'SoloYZ ' || i, 30,
            before_date, 
            '{08:00, 14:00}'::time[],
            '{12:00, 18:00}'::time[],
            2, 2
        );

     	i = i + 1;
    END LOOP;
   
    WHILE i <= N+w + 1500  LOOP

        after_date := DATE_ADD(after_date, INTERVAL '1 day');
       
        -- Genera Artista
		CALL AggiungiArtista('SoloYZ ' || i, '2021-12-07');

        -- Genera Ordine e Prenotazione Orarie effettuate dopo il 2023-01-01
        CALL CreaOrdineEPrenotazioneOrarie(
            'OPRABC90A01H501X', 'SoloYZ ' || i, 30,
            after_date, 
            '{08:00, 14:00}'::time[],
            '{12:00, 18:00}'::time[],
            2, 2
        );

        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
SELECT insert_multiple_ordini_giornalieri(0, 30000);

--------------------------------------------------------------------------

-- Index
DROP INDEX IF EXISTS giorno_prenotazione_index;
CREATE INDEX giorno_prenotazione_index ON prenotazione (giorno);

--------------------------------------------------------------------------

-- Query
EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
    SELECT count(*) AS numero_prenotazioni
    FROM PRENOTAZIONE AS p
    WHERE p.giorno >= '2023-01-01' ;

--------------------------------------------------------------------------

30k || 2 ms -> .2 ms

[x] La query diventa 'lenta' man mano aumenta il numero di 'prenotazioni'. L indice 'giorno_prenotazione_index' velocizza drasticamente la query.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------
--- N5) SELEZIONE TUTTI I DATI DI UN ARTISTA CHE SI E' REGISTRATO NEL SISTEMA PRIMA DI UNA CERTA DATA ------ SECONDA ENRICO ------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

--- Genera gli Ordini
CREATE OR REPLACE FUNCTION insert_multiple_ordini_giornalieri(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP

        -- Genera Artista
		CALL AggiungiArtista('SoloXZ ' || i, '2024-12-07');
     	
     	i = i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
SELECT insert_multiple_ordini_giornalieri(1, 30000);

-- Indice
DROP INDEX IF EXISTS data_di_registrazione_artista_index;
CREATE INDEX data_di_registrazione_artista_index ON artista (data_di_registrazione);

-- Query
EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
    SELECT * FROM ARTISTA AS a
    WHERE a.data_di_registrazione <= '2020-01-01';

30k || 3 ms -> .03 ms

[x] La query diventa 'lenta' man mano aumenta il numero di 'artisti'. L indice 'data_di_registrazione_artista_index' velocizza drasticamente la query.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
































































----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

INDICI TROVATI

----------------------------------------------------------------------------------------------------------------------------------------------------
--- O7) ELENCARE GLI ORDINI CHE NON SONO ANCORA STATI PAGATI ------ ACCETTABILE - MATTEO -----------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
FATTO
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
DROP INDEX IF EXISTS artista_ordine_index;
CREATE INDEX artista_ordine_index ON ordine (artista);

--------------------------------------------------------------------------

/*
 * O7) ELENCARE GLI ORDINI CHE NON SONO ANCORA STATI PAGATI
 */
CREATE OR REPLACE VIEW ordini_non_pagati_gruppo AS
SELECT p.ordine, sub.nome_arte, sub.numero, sub.timestamp
FROM PAGAMENTO AS p
JOIN ( 
    SELECT a.nome_arte, o.codice, te.numero, o.timestamp
    FROM ORDINE AS o, ARTISTA AS a, GRUPPO AS g, TELEFONO_A AS te
    WHERE o.artista = a.nome_arte 
    AND g.artista = a.nome_arte
    AND te.artista = a.nome_arte
) as sub ON p.ordine = sub.codice WHERE p.stato = 'Da pagare';

-- Analisi della query interessata
EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
    select * from ordini_non_pagati_gruppo;

--------------------------------------------------------------------------

100 k || 20 ms -> .120 ms

[x] La query diventa molto 'lenta' man mano aumenta il numero di 'ordini'. L indice 'artista_ordine_index' velocizza drasticamente la query.
[ ] Un altro problema sorge nell aumentare il numero di 'gruppi'. In questo caso non è stato individuato nessun indice che possa velocizzare la query.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------
--- N2) VISUALIZZA INFORMAZIONI PRODUZIONI AVVENUTE DOPO DATA FORNITA ------ ACCETTABILE - PATRINI -------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
FATTO
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
		('Album ' || i, 'SoloCiccio ' || i, '2020-02-01', '2020-06-01', 'Produzione', 'Album', 'Rock');

        i := i + 1;
    END LOOP;

    WHILE i <= N+w + 1500  LOOP

        -- Genera Produzione
        INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
		('Album ' || i, 'SoloCiccio 1000', '2023-02-01', '2023-06-01', 'Produzione', 'Album', 'Rock');

        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
SELECT insert_data_multiple_times(0, 30000);

--------------------------------------------------------------------------

-- Indice
DROP INDEX IF EXISTS data_inizio_produzione_index;
CREATE INDEX data_inizio_produzione_index ON produzione (data_inizio);

--------------------------------------------------------------------------

-- Query
EXPLAIN (ANALYSE, BUFFERS, VERBOSE)
    SELECT * FROM PRODUZIONE
    WHERE data_inizio >= '2023-01-01';

--------------------------------------------------------------------------

A me (Matteo) viene: 30 k || 2  ms -> .2

[x] La query diventa 'lenta' man mano aumenta il numero di 'produzioni'. L indice 'data_inizio_produzione_index' velocizza drasticamente la query.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------
--- N4) SELEZIONA LE CANZONI PIU' VECCHIE DI UNA CERTA DATA  ------ ACCETTABILE - ENRICO -----------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

-- Genera Produzioni
CREATE OR REPLACE FUNCTION insert_data_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP

        -- Genera Artista
		CALL AggiungiArtista('SoloCiccio ' || i, '2024-12-07');
		
        -- Genera Produzione
        INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
		('Album ' || i, 'SoloCiccio ' || i, '2020-02-01', '2020-06-01', 'Produzione'   , 'Album' , 'Rock');

        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
SELECT insert_data_multiple_times(10000, 50000);

--------------------------------------------------------------------------

-- Genera Canzoni
CREATE OR REPLACE FUNCTION insert_canzone_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
    d DATE := '2020-02-10';
BEGIN
    WHILE i <= N+w loop
	    d  := DATE_ADD(d , INTERVAL '1 day');
		CALL AggiungiCanzoneEPartecipazioni(
			'Titolo' || i, 	    --titolo
			10000 + i,   		--produzione_id
			'Testo', 	        --testo
			d,		            --data_di_registrazione
			60, 				--lunghezza_in_secondi
			'Titolo' || i, 	    --nome_del_file
			'percorso', 		--percorso_di_sistema
			'mp3', 				--estensione
			ARRAY['SoloXYZ'],	--solisti_nome_arte
			'TCNPRO90A01H501X'  --codice_fiscale_tecnico	
		);
		
      i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
SELECT insert_canzone_multiple_times(0, 40000);

--------------------------------------------------------------------------

-- Index
DROP INDEX IF EXISTS data_di_registrazione_canzone_index;
CREATE INDEX data_di_registrazione_canzone_index ON canzone (data_di_registrazione);

--------------------------------------------------------------------------

-- Query
EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
    SELECT * FROM CANZONE 
    WHERE data_di_registrazione < '2020-04-10' ;

--------------------------------------------------------------------------

40K || 3 ms -> .02 ms

[x] La query diventa 'lenta' man mano aumenta il numero di 'canzoni'. L indice 'data_di_registrazione_canzone_index' velocizza drasticamente la query.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------






