----------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_data_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
        call AggiungiArtista('SoloXYZ ' || i, '2024-12-07');
        INSERT INTO produzione (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere)
        VALUES ('Album 100' || i, 'SoloXYZ ' || i, '2020-02-01', '2020-06-01', 'Pubblicazione', 'Album', 'Rock');
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT insert_data_multiple_times(1, 100000); --indice di partenza, quante volte

DROP INDEX IF EXISTS unique_produzione;
CREATE INDEX artista_titolo_idx ON produzione (artista, titolo);
CLUSTER produzione USING artista_produzione_idx;
EXPLAIN ANALYSE SELECT * FROM produzione AS p WHERE p.titolo LIKE 'Album 100%'AND p.artista = 'SoloXYZ' ORDER BY p.titolo;

-- INDICE GIÀ ESISTE DOVUTO AL CONSTRAINT UNIQUE(artista, titolo) presente su produzione

----------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------ALL AggiungiArtista('SoloYZ ' || i, '2018-12-07');
drop index data_registrazione_artista_idx;
create index data_registrazione_artista_idx on ARTISTA(data_di_registrazione);

EXPLAIN (ANALYSE, BUFFERS, VERBOSE) 
SELECT *
FROM ARTISTA AS a
WHERE a.data_di_registrazione =  '2018-12-07' ;
da 1ms a 0.02 ms
-------------------------------------------------------------------
------- ---------------------------------------------------------------------------------------------------------------------------------------------



-- Creazione dell'indice sulla colonna titolo
-- Creazione dell'indice composito
-- CREATE INDEX artista_titolo_idx ON produzione (artista, titolo);

----------------------------------------------------------------------------------------------------------------------------------------------------
--- 6) Trovare il costo totale dei pagamenti per un dato artista -----------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

SELECT SUM(p.costo_totale) AS costo_totale
FROM PAGAMENTO p
JOIN ORDINE o ON p.ordine = o.codice
WHERE o.artista = 'SoloXYZ';

----------------------------------------------------------------------------------------------------------------------------------------------------
--- T11) Elencare i tecnici che hanno lavorato su canzoni in un determinato genere------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_produzione_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
		INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
		('Album ' || i, 'SoloXYZ' , '2020-02-01', '2020-06-01', 'Produzione'   , 'Album'   , 'Rock');
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_canzone_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
		call aggiungicanzoneepartecipazioni(
			'Titolo' || i, 	--titolo
			i+100, 					--produzione_id
			'abgdjhhjghjgy', 	--testo
			'2024-06-21',		--data_di_registrazione
			i+1, 					--lunghezza_in_secondi
			'Titolo' || i, 	--nome_del_file
			'percorso', 		--percorso_di_sistema
			'mp3', 				--estensione
			ARRAY['SoloPQR', 'SoloGHI'],			--solisti_nome_arte
			'TCNPRO90A01H501X'--codice_fiscale_tecnico	
		);
		
      i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT insert_produzione_multiple_times(0, 100000);
SELECT insert_canzone_multiple_times(0, 10000);


explain analyze SELECT DISTINCT t.codice_fiscale, t.nome, t.cognome
FROM TECNICO t
JOIN LAVORA_A l ON t.codice_fiscale = l.tecnico
JOIN CANZONE c ON l.canzone = c.codice
JOIN PRODUZIONE p ON c.produzione = p.codice
WHERE p.genere = 'Rock';

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_multiple_ordini_giornalieri(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
        -- Genera Artista
		call AggiungiArtista('SoloXYZ ' || i, '2024-12-07');
     	call CreaOrdinePacchetto('OPRABC90A01H501X', 'SoloXYZ ' || i, 'Giornaliera');
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Esegui la funzione per inserire i dati
select insert_multiple_ordini_giornalieri(60, 10); --indice di partenza, quante volte

 









------------------------------








CREATE OR REPLACE FUNCTION insert_data_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
        call AggiungiArtista('SoloXYZ ' || i, '2024-12-07');
        INSERT INTO produzione (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere)
        VALUES ('Album 100' || i, 'SoloXYZ ' || i, '2020-02-01', '2020-06-01', 'Pubblicazione', 'Album', 'Rock');
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT insert_data_multiple_times(1, 100000); --indice di partenza, quante volte

DROP INDEX IF EXISTS unique_produzione;
CREATE INDEX artista_titolo_idx ON produzione (artista, titolo);
CLUSTER produzione USING artista_produzione_idx;
EXPLAIN ANALYSE SELECT * FROM produzione AS p WHERE p.titolo LIKE 'Album 100%'AND p.artista = 'SoloXYZ' ORDER BY p.titolo;

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_data_multiple_times_p(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
     	call CreaOrdinePacchetto('OPRABC90A01H501X', 'SoloXYZ', 'Mensile');
    	raise notice '%',i;
     PERFORM pg_sleep(1);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Esegui la funzione per inserire i dati
select insert_data_multiple_times_p(60, 10); --indice di partenza, quante volte

-- Creazione dell'indice sulla colonna titolo
-- Creazione dell'indice composito
--CREATE INDEX artista_titolo_idx ON produzione (artista, titolo);

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



Query 6: Trovare il costo totale dei pagamenti per un dato artista

sql

SELECT SUM(p.costo_totale) AS costo_totale
FROM PAGAMENTO p
JOIN ORDINE o ON p.ordine = o.codice
WHERE o.artista = 'SoloXYZ';


Query 11: Elencare i tecnici che hanno lavorato su canzoni in un determinato genere

sql

SELECT DISTINCT t.codice_fiscale, t.nome, t.cognome
FROM TECNICO t
JOIN LAVORA_A l ON t.codice_fiscale = l.tecnico
JOIN CANZONE c ON l.canzone = c.codice
JOIN GENERE g ON c.genere = g.codice
WHERE g.nome = 'Pop';




--=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=




--- FUNZIONA INDICE ma è gia usato
CREATE OR REPLACE FUNCTION insert_multiple_ordini_giornalieri(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
        -- Genera Artista
		call AggiungiArtista('SoloXZ ' || i, '2024-12-07');
     	call CreaOrdinePacchetto('OPRABC90A01H501X', 'SoloXZ ' || i, 'Giornaliera');  
     

     	i = i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

select insert_multiple_ordini_giornalieri(50000, 30000);

drop index p_ord_idx;
create index p_ord_idx on ordine(artista);

explain analyse verbose SELECT sum(p.costo_totale) as costo_totale, count(*) AS counter
FROM PAGAMENTO p
JOIN ORDINE o ON p.ordine = o.codice
WHERE o.artista = 'SoloXZ 70000';
-- DA 5 MS PASSA A .05 SU 30mila RECORDS

--------------



--- Genera gli Ordini
CREATE OR REPLACE FUNCTION insert_multiple_ordini_giornalieri(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP

        -- Genera Artista
		call AggiungiArtista('SoloXZ ' || i, '2024-12-07');
     	
        -- Genera Ordine di tipo Pacchetto
        call CreaOrdinePacchetto('OPRABC90A01H501X', 'SoloXZ ' || i, 'Giornaliera');  

     	i = i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
select insert_multiple_ordini_giornalieri(1, 30000);

--------------------------------------------------------------------------

CREATE INDEX ordine_artista_indx ON prenotazioni(artista);

--------------------------------------------------------------------------



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

select insert_data_multiple_times(300, 10300);

create index data_inizio_produzione_idx on PRODUZIONE(data_inizio);


EXPLAIN (ANALYSE, BUFFERS, VERBOSE)  SELECT *
FROM PRODUZIONE
WHERE data_inizio >= '2023-01-01';

-- da 16 ms a 0.2 ms

-----------------------------------------------------------------



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
