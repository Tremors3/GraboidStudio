--------------------------------------------------------------------------
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

-- Con solo gli ordini utilizzare entrambe le chiavi | Oppure ne basta soltanto uno
-- CREATE INDEX indice ON ordine (artista);
-- CREATE INDEX indice2 ON gruppo (artista);

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

-- Con gli ordini e i gruppi, utilizzando entrambe le chiavi resta comunque lento

--------------------------------------------------------------------------

DROP INDEX IF EXISTS indice;
DROP INDEX IF EXISTS indice2;
CREATE INDEX indice ON ordine (artista); -- Questo dovrebbe essere l'unico sensato
CREATE INDEX indice2 ON gruppo (artista);
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





















