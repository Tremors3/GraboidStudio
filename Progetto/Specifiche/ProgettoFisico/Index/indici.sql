------------------------------------- ARTISTA -------------------------------------
DROP INDEX IF EXISTS artista_titolo_idx;
-- Definisci una funzione che esegue l'inserimento ripetuto con i incrementati
CREATE OR REPLACE FUNCTION insert_data_multiple_times(n INT, w INT ) RETURNS VOID AS $$
DECLARE
    i INT := n;
BEGIN
    WHILE i <= N+w LOOP
        INSERT INTO produzione (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere)
        VALUES ('Album ' || i, 'SoloXYZ', '2020-02-01', '2020-06-01', 'Pubblicazione', 'Album', 'Rock');
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Esegui la funzione per inserire i dati
SELECT insert_data_multiple_times(3000, 10000); --indice di partenza, quante volte

CREATE INDEX artista_titolo_idx ON produzione (titolo);

DROP INDEX IF EXISTS artista_titolo_idx2;
create  index  artista_titolo_idx2 ON produzione (titolo) ;
Cluster produzione using artista_titolo_idx2;
EXPLAIN ANALYSE SELECT * FROM produzione AS p WHERE artista = 'SoloXYZ' and titolo='Album 1000' order by p.titolo;

--------------------------------------------------------------------------

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

--------------------------------------------------------------------------

explain analyze SELECT p.ordine, sub.nome, sub.cognome, sub.numero, sub.timestamp
FROM PAGAMENTO AS p
JOIN ( 
    SELECT o.codice, s.nome, s.cognome, te.numero, o.timestamp
    FROM ORDINE AS o, ARTISTA AS a, SOLISTA AS s, TELEFONO_A AS te
    WHERE o.artista = a.nome_arte 
    AND s.artista = a.nome_arte
	AND te.artista = a.nome_arte
) as sub ON p.ordine = sub.codice WHERE p.stato = 'Da pagare' 
order by sub.nome, sub.cognome;