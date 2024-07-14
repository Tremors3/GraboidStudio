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
--- O8) CONTARE L'AMMONTARE SPESO DA UN ARTISTA E IL NUMERO DI ORDINI EFFETTUATI ------ SECONDA MATTE [INDICE DUPLICATO]----------------------------
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
--- XX) CONTARE IL NUMERO DI PRENOTAZIONI AVVENUTE DOPO UNA DATA ------ SECONDA PATRI --------------------------------------------------------------
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
SELECT insert_multiple_ordini_giornalieri(0, 10000);

--------------------------------------------------------------------------

-- Index
DROP INDEX IF EXISTS data_inizio_prenotazione_idx;
CREATE INDEX data_inizio_prenotazione_idx on PRENOTAZIONE(giorno);

--------------------------------------------------------------------------

-- Query
EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
    SELECT count(*) AS numero_prenotazioni
    FROM PRENOTAZIONE AS p
    WHERE p.giorno >=  '2023-01-01' ;

--------------------------------------------------------------------------

10k || 2,3 ms -> .3 ms

[x] La query diventa 'lenta' man mano aumenta il numero di 'prenotazioni'. L indice 'data_inizio_prenotazione_idx' velocizza drasticamente la query.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------
--- XX) SELEZIONE TUTTI I DATI DI UN ARTISTA CHE SI E' REGISTRATO NEL SISTEMA PRIMA DI UNA CERTA DATA ------ SECONDA ENRICO ------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

-- Indice
DROP INDEX IF EXISTS data_registrazione_artista_idx;
CREATE INDEX data_registrazione_artista_idx ON artista(data_di_registrazione);

-- Query
EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
    SELECT * FROM ARTISTA AS a
    WHERE a.data_di_registrazione <= '2020-01-01';

10k || 1.3 ms -> .2 ms

[x] La query diventa 'lenta' man mano aumenta il numero di 'artisti'. L indice 'data_registrazione_artista_idx' velocizza drasticamente la query.

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
--- O9) VISUALIZZA INFORMAZIONI PRODUZIONI AVVENUTE DOPO DATA FORNITA ------ ACCETTABILE - PATRINI -------------------------------------------------
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

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------
--- A9) SELEZIONA LE CANZONI PIU' VECCHIE DI UNA CERTA DATA  ------ ACCETTABILE - ENRICO -----------------------------------------------------------
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
SELECT insert_data_multiple_times(10000, 20000);

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
			'abgdjhhjghjgy', 	--testo
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
SELECT insert_canzone_multiple_times(0, 10000);

--------------------------------------------------------------------------

-- Index
DROP INDEX IF EXISTS data_registrazione_canzone_idx;
CREATE INDEX data_registrazione_canzone_idx on CANZONE(data_di_registrazione);

--------------------------------------------------------------------------

-- Query
EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
    SELECT * FROM CANZONE 
    WHERE data_di_registrazione < '2020-04-10' ;

--------------------------------------------------------------------------

10K || 1 ms -> .02 ms

[x] La query diventa 'lenta' man mano aumenta il numero di 'canzoni'. L indice 'data_registrazione_canzone_idx' velocizza drasticamente la query.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------






