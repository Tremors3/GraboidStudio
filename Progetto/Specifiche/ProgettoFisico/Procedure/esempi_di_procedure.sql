Gestione Solista 
    -- Crea un nuovo artista e un solista associato nel database.
    create_new_artist_and_solista(nome_arte VARCHAR(255), data_di_registrazione DATE, codice_fiscale CHAR(16), nome VARCHAR(255), cognome VARCHAR(255), data_di_nascita DATE, gruppo VARCHAR(255), data_adesione DATE):
    
    -- Crea un nuovo artista e un gruppo associato nel database.
    
    -- Crea una partecipazione di un solista ad un gruppo

Gestione Produzione e Canzone

    -- aggiunta di una canzone, e quindi anche di relazione "lavora_a" e lista di id dei solisti

Gestione Eliminazione Oraria
    -- annullamento di una prenotazione oraria
    se si annulla una prenotazione oraria, bisogna eliminare, i record di oraria e fascia oraria annesse
    
    -- se lo stato dell'ordine è Pagato, allora si possono avere al massimo un totale di ore = costo_totale/orario.valore
    
    -- se lo stato dell'ordine è Da pagare, allora si imposta a 0 il costo totale dell'ordine, e si possono prenotare un numero di ore a scelta visto che il costo_totale ricalcolato è ancora da pagare. procedura: CreaOrdineEPrenotazioneOrarie

Gestione Fascie Orarie -- probabilmente no

    -- rimozione fascia oraria
    delete_time_slot(prenotazione INTEGER, orario_inizio TIME):

    -- aggiunta fascia oraria