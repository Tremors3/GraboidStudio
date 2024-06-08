
Gestione Eliminazione Oraria
    -- annullamento di una prenotazione oraria
    se si annulla una prenotazione oraria, bisogna eliminare, i record di oraria e fascia oraria annesse
    
    -- se lo stato dell'ordine è Pagato, allora si possono avere al massimo un totale di ore = costo_totale/orario.valore
    
    -- se lo stato dell'ordine è Da pagare, allora si imposta a 0 il costo totale dell'ordine, e si possono prenotare un numero di ore a scelta visto che il costo_totale ricalcolato è ancora da pagare. procedura: CreaOrdineEPrenotazioneOrarie

Gestione Fascie Orarie -- probabilmente no

    -- rimozione fascia oraria
    delete_time_slot(prenotazione INTEGER, orario_inizio TIME):

    -- aggiunta fascia oraria