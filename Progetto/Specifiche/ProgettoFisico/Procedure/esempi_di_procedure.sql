-- per le procedure di inserimento per diminuire il quantitativo di righe e semplificarle direi che ha senso creare varie funzioni
-- create_new_artist(nome_arte VARCHAR(255), data_di_registrazione DATE
-- create_new_production(titolo VARCHAR(255), artista VARCHAR(255), data_inizio DATE, tipo_produzione VARCHAR(25)):
-- create_new_song(titolo VARCHAR(255), produzione INTEGER, testo TEXT, data_di_registrazione DATE):
-- ecc


Gestion Solista 
    -- Crea un nuovo artista e un solista associato nel database.
    create_new_artist_and_solista(nome_arte VARCHAR(255), data_di_registrazione DATE, codice_fiscale CHAR(16), nome VARCHAR(255), cognome VARCHAR(255), data_di_nascita DATE, gruppo VARCHAR(255), data_adesione DATE):
 e anche del gruppo
 partecipazione solista-al-gruppo


-- annullamento di una prenotazione oraria
se si annulla una prenotazione oraria, bisogna eliminare, i record di oraria e fascia oraria annesse
-- se lo stato dell'ordine è Pagato, allora si possono avere al massimo un totale di ore = costo_totale/orario.valore
-- se lo stato dell'ordine è Da pagare, allora si imposta a 0 il costo totale dell'ordine, e si possono prenotare un numero di ore a scelta visto che il costo_totale ricalcolato ed è ancora da pagare.

Gestione Prenotazioni

    cancel_booking(codice_prenotazione INTEGER):
        Annulla una prenotazione di sala esistente.
    
    --  Aggiorna una fascia oraria nel database.
    update_time_slot(prenotazione INTEGER, nuova_orario_inizio TIME, nuova_orario_fine TIME):

    -- Cancella una fascia oraria dal database.
    delete_time_slot(prenotazione INTEGER, orario_inizio TIME):

    -- Verifica le stanze disponibili per una certa data e tipologia (oraria/giornaliera).
    check_available_rooms(giorno DATE, orario_inizio TIME, orario_fine TIME):

Gestione Tecnici
    assign_technician_to_song(codice_fiscale CHAR(16), song_id INTEGER):
        Assegna un tecnico a una canzone specifica.

    create_new_technician(data di assunzione DATE, tipo_tecnico VARCHAR(64)):
        Crea un nuovo tecnico nel database.

    -- le prevediamo le procedure di eliminazione record?
    delete_technician(codice_fiscale CHAR(16)):
        Cancella un tecnico dal database.

Gestione Produzione e Canzone

    -- Crea una nuova produzione e una canzone associata nel database.
    create_new_production_and_song(titolo VARCHAR(255), artista VARCHAR(255), data_inizio DATE, data_fine DATE, stato VARCHAR(13), tipo_produzione VARCHAR(25), genere VARCHAR(255), titolo_canzone VARCHAR(255), testo TEXT, lunghezza_in_secondi INTEGER, nome_del_file VARCHAR(255), percorso_di_sistema VARCHAR(255), estensione VARCHAR(10)):
       