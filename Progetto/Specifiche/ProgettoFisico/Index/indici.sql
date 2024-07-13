
VINCOLI TROVATI

----------------------------------------------------------------------------------------------------------------------------------------------------
--- O7) ELENCARE GLI ORDINI CHE NON SONO ANCORA STATI PAGATI ---------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

CREATE INDEX indice ON ordine (artista);

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

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------