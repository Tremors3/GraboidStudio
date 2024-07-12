/* AGGIORNA IL COSTO TOTALE
 * Ricalcola ed aggiorna il costo totale di un ordine.
 * Da eseguire una sola volta dopo la creazione di un ordine di tipo "Pacchetto".
 * Da eseguire tutte le volte che si inseriscono delle nuove "Prenotazioni orarie"/"Fasce orarie".
 *
 * INPUT:   ordine_id   INT
 */
CALL AggiornaCostoOrdine(1);

-----------------------------------------------------------------------------------------

/* AGGIUNGE UN ARTISTA
 * La funzione crea il record di un artista con i parametri passati come argomento.
 *
 * INPUT:   nome_arte               VARCHAR(50)
 * INPUT:   data_registrazione      DATE
 */
CALL AggiungiArtista('Tremore', '2024-06-08');

-----------------------------------------------------------------------------------------

/* CREA UN NUOVO ORDINE DI TIPO PACCHETTO
 * La procedura crea un ordine di tipo pacchetto.
 *
 * INPUT:   operatore_codice_fiscale    VARCHAR(16)
 * INPUT:   artista_nome_arte           VARCHAR(255)
 * INPUT:   pacchetto_nome              VARCHAR(255)
 */
CALL CreaOrdinePacchetto('OPRABC90A01H501X', 'TrioUVW', 'Mensile');

/* CREA UNA PRENOTAZIONE DI TIPO GIORNALIERA
 * Procedura che inserisce una nuova prenotazione associandola al 
 * ordine di tipo pacchetto il cui id è dato come argomento.
 * 
 * INPUT:   pacchetto_id               INT
 * INPUT:   giorno                     DATE
 * INPUT:   sala_piano                 INT
 * INPUT:   sala_numero                INT
 */
CALL CreaPrenotazioneGiornaliera(1, '2023-01-10', 2, 2); -- Funzionante
--CALL CreaPrenotazioneGiornaliera(1, '2022-01-01', 2, 2); -- Eccezione: Indietro nel tempo
--CALL CreaPrenotazioneGiornaliera(1, '2023-05-01', 2, 2); -- Eccezione: Più di 90 giorni

-----------------------------------------------------------------------------------------

/* CREA UN ORDINE DI TIPO ORARIO E RELATIVA PRENOTAZIONE
 * La procedura produce un ordine di tipo orario e la rispettiva prenotazione.
 * 
 * INPUT:   operatore_codice_fiscale    VARCHAR(16)
 * INPUT:   artista_nome_arte           VARCHAR(255)
 * INPUT:   costo_ora                   DECIMAL(10, 2)
 * INPUT:   giorno                      DATE
 * INPUT:   orari_inizio                TIME[]
 * INPUT:   orari_fine                  TIME[]
 * INPUT:   sala_piano                  INT
 * INPUT:   sala_numero                 INT
 */
CALL CreaOrdineEPrenotazioneOrarie(
    'OPRABC90A01H501X', 'BandABC', 30,
    '2023-02-03', 
    '{08:00, 14:00}'::time[],
    '{12:00, 18:00}'::time[],
    2, 2
);

/* CREA UN NUOVO ORDINE DI TIPO ORARIO
 * La funzione produce un ordine di tipo orario. E restituisce il suo id.
 *
 * INPUT:   operatore_codice_fiscale   VARCHAR(16)
 * INPUT:   artista_nome_arte          VARCHAR(255)
 * INPUT:   costo_ora                  DECIMAL(10, 2)
 *
 * OUTPUT:  ordine_id                  INT
 */
SELECT CreaOrdineOrario(
    'OPRABC90A01H501X', 'BandDEF', 30
);

/* CREA PRENOTAZIONE PER ORDINE ORARIO
 * La procedura produce la prenotazione per un ordine orario.
 *
 * INPUT:   ordine_id       INT
 * INPUT:   giorno          DATE
 * INPUT:   orari_inizio    TIME[]
 * INPUT:   orari_fine      TIME[]
 * INPUT:   sala_piano      INT
 * INPUT:   sala_numero     INT
 */
CALL CreaPrenotazioneOraria(
    10, '2023-02-03', -- ordine_id = 10
    '{08:00, 14:00}'::time[],
    '{10:00, 18:00}'::time[],
    2, 2
);

-----------------------------------------------------------------------------------------

/* CREA UN SOLISTA
 * Crea un nuovo artista e un solista associato nel database.
 *
 * INPUT:   nome_arte            VARCHAR(255)
 * INPUT:   data_di_registrazione DATE
 * INPUT:   codice_fiscale       CHAR(16)
 * INPUT:   nome                 VARCHAR(255)
 * INPUT:   cognome              VARCHAR(255)
 * INPUT:   data_di_nascita      DATE
 * INPUT:   email                VARCHAR(255)
 * INPUT:   telefono             CHAR(15)
 */
CALL CreaArtistaSolista(
    'PopStar', 
    '2024-06-08', 
    'PSMRTN90B05C351K', 
    'Giulia', 
    'Bianchi', 
    '1990-02-05', 
    'giulia.bianchi@example.com', 
    '098762222'
);

-----------------------------------------------------------------------------------------

/* CREA UN ARTISTA E UN GRUPPO
 * Crea un nuovo artista e un gruppo associato nel database.
 *
 * INPUT:   nome_arte            VARCHAR(255)
 * INPUT:   data_di_registrazione DATE
 * INPUT:   email                VARCHAR(255)
 * INPUT:   telefono             CHAR(15)
 * INPUT:   data_formazione      DATE
 */
CALL CreaArtistaGruppo(
    'Artista1234',
    '2024-06-09',
    'artista1234@email.com',
    '1234567333',
    '2024-01-01'
);

-----------------------------------------------------------------------------------------

/* CREA PARTECIPAZIONE SOLISTA GRUPPO
 * Gestisce la partecipazione di un solista a un gruppo nel database.
 *
 * INPUT:   nome_arte_solista       VARCHAR(255)
 * INPUT:   gruppo_nuovo            VARCHAR(255)
 * INPUT:   data_adesione_corrente  DATE
 */
CALL CreaPartecipazioneSolistaGruppo('PopStar', 'Artista1234', '2024-06-08');
CALL CreaPartecipazioneSolistaGruppo('PopStar', 'Artista1234', '2024-06-08'); -- controllo Il solista è già nel gruppo specificato
CALL CreaPartecipazioneSolistaGruppo('PopStar', 'BandABC',     '2024-06-08');
CALL CreaPartecipazioneSolistaGruppo('PopStar', 'Group123',    '2024-06-08');

-----------------------------------------------------------------------------------------

/*
 * AGGIUNGI CANZONE
 * Aggiunge una nuova canzone al database e gestisce la relazione "lavora_a" con solisti.
 *
 * INPUT:   titolo                      VARCHAR(255)    - Titolo della canzone
 * INPUT:   produzione_id               INT             - Id della produzione
 * INPUT:   testo                       TEXT            - Testo della canzone
 * INPUT:   data_di_registrazione       DATE            - Data di registrazione della canzone
 * INPUT:   lunghezza_in_secondi        INT             - Lunghezza in secondi della canzone
 * INPUT:   nome_del_file               VARCHAR(255)    - Nome del file della canzone
 * INPUT:   percorso_di_sistema         VARCHAR(255)    - Percorso di sistema del file della canzone
 * INPUT:   estensione                  VARCHAR(10)     - Estensione del file della canzone
 * INPUT:   solisti_nome_arte           VARCHAR[]       - Array di nomi d'arte dei solisti che partecipano alla creazione della canzone
 * INPUT:   codice_fiscale_tecnico      CHAR(16)        - Codice fiscale del tecnico che lavora sulla canzone
 */
CALL AggiungiCanzoneEPartecipazioni(
    'Titolo della Canzone',
    2,
    'Testo della canzone',
    '2024-06-09',
    300, -- Lunghezza in secondi
    'nome_file.mp3',
    '/percorso/di/sistema',
    'mp3', -- Estensione del file
    ARRAY['SoloPQR', 'PopStar'], -- Array di nomi d'arte dei solisti
    'TCNAUD85M01H501Z' -- Codice fiscale del tecnico
);