----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_data_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
		call AggiungiArtista('SoloXYZ ' || i, '2024-12-07');
        call CreaOrdinePacchetto('OPRABC90A01H501X', 'SoloXYZ ' || i, 'Mensile');
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT insert_data_multiple_times(1, 100000);

--------------------------------------------------------------------------

DROP INDEX IF EXISTS indice;
CREATE INDEX indice ON ordine (artista);
CLUSTER pagamento USING indice;

--------------------------------------------------------------------------

EXPLAIN ANALYSE SELECT p.ordine, sub.nome_arte, sub.numero, sub.timestamp
FROM PAGAMENTO AS p
JOIN ( 
    SELECT a.nome_arte, o.codice, te.numero, o.timestamp
    FROM ORDINE AS o, ARTISTA AS a, GRUPPO AS g, TELEFONO_A AS te
    WHERE o.artista = a.nome_arte 
    AND g.artista = a.nome_arte
	AND te.artista = a.nome_arte
) as sub ON p.ordine = sub.codice WHERE p.stato = 'Da pagare';

-- creazione di query che non fanno uso dei due campi che vanno a creare delle unique key; in modo da creare l'indice solo su un attributo, invece dei due creati in automatico
-- creazione di query lente per le altre tabelle, la tabella prenotazione ha il problema dei timestamp

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

-- prese tutte le produzioni fare un filtro che parta da una data di inizio e data una data da cui iniziare la ricerca, creando un indice su di esso, volendo si può calcolare il numero di produzioni, canzoni opppure lasciarla cosi come è 

-- Genera Produzione ed Artista
CREATE OR REPLACE FUNCTION insert_data_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP

        -- Genera Artista
		call AggiungiArtista('SoloCiccio ' || i, '2024-12-07');
		
        -- Genera Produzione
        INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
		('Album ' || i, 'SoloCiccio ' || i, '2020-02-01', '2020-06-01', 'Produzione'   , 'Album' , 'Rock');

        i := i + 1;
    END LOOP;

    WHILE i <= N+w + 1500  LOOP

        -- Genera Produzione
	  
        INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
		('Album ' || i, 'SoloCiccio 1000', '2023-02-01', '2023-06-01', 'Produzione'   , 'Album'   , 'Rock');
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

select insert_data_multiple_times(300, 10300);

create index data_inizio_produzione_idx on PRODUZIONE(data_inizio);


EXPLAIN (ANALYSE, BUFFERS, VERBOSE)  SELECT *
FROM PRODUZIONE
WHERE data_inizio >= '2023-01-01';

-- da 16 ms a 0.2 ms

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------


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

select insert_multiple_ordini_giornalieri(0, 10000);

drop index data_inizio_prenotazione_idx;
create index data_inizio_prenotazione_idx on PRENOTAZIONE(giorno);

EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
    SELECT count(*) AS numero_prenotazioni
    FROM PRENOTAZIONE AS p
    WHERE p.giorno >=  '2023-01-01' ;

-- 10k || 2,3 ms a 0,3 ms


----- indice per artista

create index data_registrazione_artista_idx on ARTISTA(data_di_registrazione);

EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
SELECT *
FROM ARTISTA AS a
WHERE a.data_di_registrazione <=  '2020-01-01' ;
-- 10k || 1,3 ms a 0,2 ms





------------------


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
SELECT insert_data_multiple_times(0, 30000);


CREATE OR REPLACE FUNCTION insert_canzone_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
    d DATE := '2020-02-10';
BEGIN
    WHILE i <= N+w loop
	    d  := DATE_ADD(d , INTERVAL '1 day');
		call AggiungiCanzoneEPartecipazioni(
			'Titolo' || i, 	    --titolo
			10000 | i , 		--produzione_id
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

select insert_canzone_multiple_times(0, 10000);

drop index data_registrazione_canzone_idx;
create index data_registrazione_canzone_idx on CANZONE(data_di_registrazione);

EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
SELECT *
FROM CANZONE 
where data_di_registrazione < '2020-04-10' ;

-- 10K | 1 ms -> 0.02 ms


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







































CREATE OR REPLACE FUNCTION grattacielo(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
		INSERT INTO SALA (piano, numero) VALUES
		(i, i%3);
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT grattacielo(4, 100000);