/* AGGIORNA IL COSTO TOTALE
 * Ricalcola ed aggiorna il costo totale di un ordine.
 * Da eseguire una sola volta dopo la creazione di un ordine di tipo "Pacchetto".
 * Da eseguire tutte le volte che si inseriscono delle nuove "Prenotazioni orarie"/"Fasce orarie".
 *
 * INPUT:   ordine_id   INT
 */
CREATE OR REPLACE PROCEDURE AggiornaCostoOrdine(ordine_id INT) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE PAGAMENTO
    SET costo_totale = CalcolaCostoTotale(ordine_id)
    WHERE ordine = ordine_id;
END
$$;
CALL AggiornaCostoOrdine(1);