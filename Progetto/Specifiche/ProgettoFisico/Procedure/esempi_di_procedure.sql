
Gestione Eliminazione Oraria
    -- annullamento di una prenotazione oraria
    se si annulla una prenotazione oraria, bisogna eliminare, i record di oraria e fascia oraria annesse
    
    -- se lo stato dell'ordine è Pagato, allora si possono avere al massimo un totale di ore = costo_totale/orario.valore
    
    -- se lo stato dell'ordine è Da pagare, allora si imposta a 0 il costo totale dell'ordine, e si possono prenotare un numero di ore a scelta visto che il costo_totale ricalcolato è ancora da pagare. procedura: CreaOrdineEPrenotazioneOrarie

Gestione Fascie Orarie -- probabilmente no

    -- rimozione fascia oraria
    delete_time_slot(prenotazione INTEGER, orario_inizio TIME):

    -- aggiunta fascia oraria

/*
PERFORM query explanation, FOUND 
This executes query and discards the result. Write the query the same way you would write an SQL SELECT command, but replace the initial keyword SELECT with PERFORM. For WITH queries, use PERFORM and then place the query in parentheses. (In this case, the query can only return one row.) PL/pgSQL variables will be substituted into the query just as described above, and the plan is cached in the same way. Also, the special variable FOUND is set to true if the query produced at least one row, or false if it produced no row
*/
