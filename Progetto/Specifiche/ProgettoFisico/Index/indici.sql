SELECT * FROM pg_stat_user_indexes;
SELECT * FROM pg_stat_user_tables;

----------------------------------------------------------------------------------------------------------------------------------------------------
--- ------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

VINCOLI TROVATI

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
EXPLAIN ANALYSE VERBOSE SELECT p.ordine, sub.nome_arte, sub.numero, sub.timestamp
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

1 [x]) La query diventa molto 'lenta' man mano aumenta il numero di 'ordini'. L indice 'ordine_artista_indx' velocizza drasticamente la query.
2 [ ]) Un altro problema sorge nell aumentare il numero di 'gruppi'. In questo caso non è stato individuato nessun indice che possa velocizzare la query.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------