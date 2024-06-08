CREATE PROCEDURE AggiungiArtista (
    IN nome_arte VARCHAR(50),
    IN data_registrazione DATE
)
BEGIN
    INSERT INTO ARTISTA (nome_arte, data_di_registrazione)
    VALUES (nome_arte, data_registrazione);
END;

CREATE PROCEDURE AggiornaCostoOrdine (
    IN ordine_id INT,
    IN nuovo_costo DECIMAL(10, 2)
)
BEGIN
    --DECLARE costo_totale DECIMAL(10, 2);

    -- Calcola il costo totale utilizzando la funzione
    SET costo_totale_aggiornato = CalcolaCostoTotale(ordine_id);


    UPDATE PAGAMENTO
    SET costo_totale = costo_totale_aggiornato
    WHERE ordine = ordine_id;
END;



-- volendo si possono aggiungere i check anche per controllare che i valori siano corretti prima di aggiornarli:
-- CHECK(costo_totale_aggiornato)>0 