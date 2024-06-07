RECUPERO DATI 
    get_artista_by_nome_arte(nome_arte VARCHAR(255)):
        Restituisce i dettagli dell'artista dato il nome d'arte.

    get_solista_by_codice_fiscale(codice_fiscale CHAR(16)):
        Restituisce i dettagli di un solista dato il codice fiscale.

    get_generi(): 
        Restituisce tutti i generi musicali presenti nel database.

    get_produttori_for_produzione(produzione_id INTEGER):
        Restituisce tutti i produttori associati a una produzione.

    get_technicians_by_type(type VARCHAR(64)):
        Restituisce tutti i tecnici di un certo tipo (es. Tecnico del Suono).

    get_song_by_id(song_id INTEGER):
        Restituisce i dettagli di una canzone dato il suo identificativo.

    get_all_operators():
        Restituisce tutti gli operatori presenti nel database

CALCOLI E AGGREGAZIONI

   CalcolaCostoTotale(ordine_id INT)

    --Calcola la lunghezza media delle canzoni per una produzione.
   calculate_average_song_length(codice_produzione INTEGER) RETURNS INTEGER:

    -- Conta il numero di canzoni per una produzione.
   count_songs_in_production(codice_produzione INTEGER) RETURNS INTEGER:

   

   

operazioni CRUD

    -- la abbiamo come query al momento questa
    update_production_status(produzione_id INTEGER, new_status VARCHAR(13)):
        Aggiorna lo stato di una produzione nel database.

    --  Crea una nuova fascia oraria associata a una prenotazione nel database.
    create_time_slot(prenotazione INTEGER, orario_inizio TIME, orario_fine TIME):


   
operazione interessante
    format_phone_number(numero VARCHAR(15)) RETURNS VARCHAR(15):

        Formatta un numero di telefono nel formato desiderato.
   
