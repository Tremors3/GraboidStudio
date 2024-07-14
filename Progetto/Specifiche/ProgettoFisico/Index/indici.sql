SELECT * FROM pg_stat_user_indexes;
SELECT * FROM pg_stat_user_tables;

----------------------------------------------------------------------------------------------------------------------------------------------------
--- ------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

VINCOLI TROVATI

----------------------------------------------------------------------------------------------------------------------------------------------------
--- A1) ELENCARE LE PRODUZIONI COMPOSTE DA UN DETERMINATO ARTISTA ----------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

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

    WHILE i <= N+w + 150  LOOP

        -- Genera Produzione
	  
        INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
		('Album ' || i, 'SoloCiccio 1000', '2020-02-01', '2020-06-01', 'Pubblicazione'   , 'Album'   , 'Rock');
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

select insert_data_multiple_times(300, 10300);
--------------------------------------------------------------------------

-- Index
DROP INDEX artista_produzione_indx;
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




















----------------------------------------------------------------------------------------------------------------------------------------------------
--- O7) ELENCARE GLI ORDINI CHE NON SONO ANCORA STATI PAGATI ---------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

-- Genera gli ordini
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

--------------------------------------------------------------------------

-- Indice
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