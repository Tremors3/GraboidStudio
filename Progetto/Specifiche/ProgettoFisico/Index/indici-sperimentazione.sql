
TROVARE I VINCOLI

----------------------------------------------------------------------------------------------------------------------------------------------------
--- O7) ELENCARE GLI ORDINI CHE NON SONO ANCORA STATI PAGATI ---------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM pg_stat_user_indexes;
SELECT * FROM pg_stat_user_tables;
-- Genera Ordini
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

SELECT insert_data_multiple_times(0, 100000);

-- CREATE INDEX indice ON ordine (artista);

--------------------------------------------------------------------------

-- Genera Gruppi
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

-- Accrescendo il numero di gruppi la query diventa e resta lenta qualsiasi indice utilizzato

--------------------------------------------------------------------------

DROP INDEX IF EXISTS indice;
DROP INDEX IF EXISTS indice2;

CREATE INDEX indice ON ordine (artista);  -- Questo dovrebbe essere l'unico sensato       <---
CREATE INDEX indice2 ON gruppo (artista); -- Questo non serve a niente

CLUSTER pagamento USING indice;

--------------------------------------------------------------------------

EXPLAIN ANALYSE VERBOSE SELECT p.ordine, sub.nome_arte, sub.numero, sub.timestamp
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

CREATE OR REPLACE FUNCTION insert_data_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
		call aggiungicanzoneepartecipazioni(
			'Titolo' || i, 	--titolo
			'' || i, 		--produzione_id
			'abgdjhhjghjgy',--testo
			TIMESTAMP, 		--data_di_registrazione
			'' ||i, 		--lunghezza_in_secondi
			'Titolo' || i, 	--nome_del_file
			'percorso', 	--percorso_di_sistema
			'mp3', 			--estensione
                            --solisti_nome_arte
                            --codice_fiscale_tecnico	
		);
		
		INSERT INTO produzione (titolo, artista, stato, tipo_produzione, genere)
		VALUES (
            'Titolo' || i,
            'Artista' || i%5,
            'Produzione',
            'Album',
            '' || i%6
		);
		
      i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT insert_data_multiple_times(0, 100000);











SELECT DISTINCT t.codice_fiscale, t.nome, t.cognome
FROM TECNICO t
JOIN LAVORA_A l ON t.codice_fiscale = l.tecnico
JOIN CANZONE c ON l.canzone = c.codice
JOIN PRODUZIONE g ON c.genere = g.codice
WHERE g.nome = 'Pop';






/*
c. genere non esiste --> aggiungere a CANZONE:
    genere VARCHAR(255),
    FOREIGN KEY (genere) REFERENCES genere(nome) ON UPDATE CASCADE ON DELETE RESTRICT,
bisogna aggiornare anche le procedure

g.codice è sbagliato --> g.nome

*/


----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------























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