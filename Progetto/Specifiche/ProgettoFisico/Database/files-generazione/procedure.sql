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
EXCEPTION
    WHEN OTHERS THEN -- Gestione degli errori
        RAISE EXCEPTION 'Errore nell aggiornamento del costo totale di un ordine: %', SQLERRM;
        ROLLBACK;    -- Annulla la transazione in caso di errore
END
$$;

-----------------------------------------------------------------------------------------

/* AGGIUNGE UN ARTISTA
 * La funzione crea il record di un artista con i parametri passati come argomento.
 *
 * INPUT:   nome_arte               VARCHAR(50)
 * INPUT:   data_registrazione      DATE
 */
CREATE OR REPLACE PROCEDURE AggiungiArtista(nome_arte VARCHAR(50), data_registrazione DATE) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO ARTISTA (nome_arte, data_di_registrazione)
    VALUES (nome_arte, data_registrazione);
END
$$;

-----------------------------------------------------------------------------------------

/* CREA UN NUOVO ORDINE DI TIPO PACCHETTO
 * La procedura crea un ordine di tipo pacchetto.
 *
 * INPUT:   operatore_codice_fiscale    VARCHAR(16)
 * INPUT:   artista_nome_arte           VARCHAR(255)
 * INPUT:   pacchetto_nome              VARCHAR(255)
 */
CREATE OR REPLACE PROCEDURE CreaOrdinePacchetto(
    operatore_codice_fiscale VARCHAR(16), 
    artista_nome_arte VARCHAR(255), 
    pacchetto_nome VARCHAR(255)) LANGUAGE plpgsql AS $$
DECLARE
    ordine_id INT;
BEGIN
    -- inserimento ordine
	INSERT INTO ORDINE (timestamp, artista, annullato, operatore)
	VALUES (CURRENT_TIMESTAMP, artista_nome_arte, FALSE, operatore_codice_fiscale)
	RETURNING codice INTO ordine_id;
    
    -- collegamento pacchetto
    INSERT INTO PACCHETTO (ordine, tipologia, n_giorni_prenotati_totali)
    VALUES (ordine_id, pacchetto_nome, 0);

    -- inserimento pagamaneto
    INSERT INTO PAGAMENTO (ordine, stato, costo_totale, metodo)
    VALUES(ordine_id, 'Da pagare', CalcolaCostoTotale(ordine_id), NULL);
EXCEPTION
    WHEN OTHERS THEN -- Gestione degli errori
        RAISE EXCEPTION 'Errore nella creazione di un ordine di tipo pacchetto: %', SQLERRM;
        ROLLBACK;    -- Annulla la transazione in caso di errore
END
$$;

/* CREA UNA PRENOTAZIONE DI TIPO GIORNALIERA
 * Procedura che inserisce una nuova prenotazione associandola al 
 * ordine di tipo pacchetto il cui id è dato come argomento.
 * 
 * INPUT:   pacchetto_id               INT
 * INPUT:   giorno                     DATE
 * INPUT:   sala_piano                 INT
 * INPUT:   sala_numero                INT
 */
CREATE OR REPLACE PROCEDURE CreaPrenotazioneGiornaliera(
    pacchetto_id INT,
    giorno DATE,
    sala_piano INT,
    sala_numero INT
)LANGUAGE plpgsql AS $$
BEGIN
    -- inserimento prenotazione
    INSERT INTO PRENOTAZIONE (annullata, giorno, tipo, pacchetto, sala_piano, sala_numero)
    VALUES (FALSE, giorno, TRUE, pacchetto_id, sala_piano, sala_numero);

    -- aggiornamento contatore giorni prenotati
    UPDATE PACCHETTO
    SET n_giorni_prenotati_totali = n_giorni_prenotati_totali + 1
    WHERE ordine = pacchetto_id;
EXCEPTION
    WHEN OTHERS THEN -- Gestione degli errori
        RAISE EXCEPTION 'Errore nella creazione di una prenotazione giornaliera: %', SQLERRM;
        ROLLBACK;    -- Annulla la transazione in caso di errore
END
$$;

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
CREATE OR REPLACE PROCEDURE CreaOrdineEPrenotazioneOrarie(
    operatore_codice_fiscale VARCHAR(16), 
    artista_nome_arte VARCHAR(255),
    costo_ora DECIMAL(10, 2),
    giorno DATE,
    orari_inizio TIME[],
    orari_fine TIME[],
    sala_piano INT,
    sala_numero INT) LANGUAGE plpgsql AS $$
DECLARE
    ordine_id INT;
    prenotazione_id INT;
    ore_prenotate_totali INT;
BEGIN
    ordine_id := CreaOrdineOrario(
        operatore_codice_fiscale, 
        artista_nome_arte, 
        costo_ora
    );
    CALL CreaPrenotazioneOraria(
        ordine_id, giorno, 
        orari_inizio,
        orari_fine,
        sala_piano,
        sala_numero
    );
EXCEPTION
    WHEN OTHERS THEN -- Gestione degli errori
        RAISE EXCEPTION 'Errore nella creazione di un ordine e di una prenotazione oraria: %', SQLERRM;
        ROLLBACK;    -- Annulla la transazione in caso di errore
END
$$;

/* CREA UN NUOVO ORDINE DI TIPO ORARIO
 * La funzione produce un ordine di tipo orario. E restituisce il suo id.
 *
 * INPUT:   operatore_codice_fiscale   VARCHAR(16)
 * INPUT:   artista_nome_arte          VARCHAR(255)
 * INPUT:   costo_ora                  DECIMAL(10, 2)
 *
 * OUTPUT:  ordine_id                  INT
 */
CREATE OR REPLACE FUNCTION CreaOrdineOrario(
    operatore_codice_fiscale VARCHAR(16), 
    artista_nome_arte VARCHAR(255),
    costo_ora DECIMAL(10, 2)) RETURNS INT LANGUAGE plpgsql AS $$
DECLARE
    ordine_id INT;
BEGIN
    -- inserimento ordine
	INSERT INTO ORDINE (timestamp, artista, annullato, operatore) 
	VALUES (CURRENT_TIMESTAMP, artista_nome_arte, FALSE, operatore_codice_fiscale)
	RETURNING codice INTO ordine_id;

    -- collegamento orario
    INSERT INTO ORARIO (ordine, n_ore_prenotate_totali, valore)
    VALUES (ordine_id, 0, costo_ora);

    -- inserimento pagamaneto
    INSERT INTO PAGAMENTO (ordine, stato, costo_totale, metodo)
    VALUES(ordine_id, 'Da pagare', NULL, NULL);

    RETURN ordine_id;
EXCEPTION
    WHEN OTHERS THEN -- Gestione degli errori
        RAISE EXCEPTION 'Errore nella creazione di un ordine orario: %', SQLERRM;
        ROLLBACK;    -- Annulla la transazione in caso di errore
END
$$;

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
CREATE OR REPLACE PROCEDURE CreaPrenotazioneOraria(
    ordine_id INT,
    giorno DATE,
    orari_inizio TIME[],
    orari_fine TIME[],
    sala_piano INT,
    sala_numero INT) LANGUAGE plpgsql AS $$
DECLARE
    prenotazione_id INT;
    ore_prenotate_parziali INT;
    ore_prenotate_totali INT;
BEGIN
    -- Controllo lunghezze array di orari
    IF array_length(orari_inizio, 1) != array_length(orari_fine, 1) THEN
        RAISE EXCEPTION 'Gli array di orari di inizio e fine devono avere la stessa lunghezza.';
    END IF;

    -- Controllo lunghezze array di orari
    IF array_length(orari_inizio, 1) IS NULL OR array_length(orari_fine, 1) IS NULL THEN
        RAISE EXCEPTION 'Gli array di orari di inizio e fine devono contenere almento una fascia oraria.';
    END IF;

    -- inserimento prenotazione
    INSERT INTO PRENOTAZIONE (annullata, giorno, tipo, pacchetto, sala_piano, sala_numero)
    VALUES (FALSE, giorno, FALSE, NULL, sala_piano, sala_numero)
    RETURNING codice INTO prenotazione_id;

    -- inserimento oraria
    INSERT INTO ORARIA (prenotazione, orario)
    VALUES (prenotazione_id, ordine_id);

    -- inserimento fasce orarie
    ore_prenotate_totali := 0;
    FOR i IN 1..array_length(orari_inizio, 1) LOOP
        INSERT INTO FASCIA_ORARIA (oraria, orario_inizio, orario_fine)
        VALUES (prenotazione_id, orari_inizio[i], orari_fine[i]);
        -- numero di ore della fascia oraria
        SELECT EXTRACT(HOUR FROM orari_fine[i] - orari_inizio[i]) INTO ore_prenotate_parziali;
        ore_prenotate_totali := ore_prenotate_totali + ore_prenotate_parziali;
    END LOOP;
    
    -- aggiornamento numero totale di ore
    UPDATE orario AS o
    SET n_ore_prenotate_totali = ore_prenotate_totali
    WHERE o.ordine = ordine_id;

    -- aggiornamento del costo del pagamento
    UPDATE PAGAMENTO AS p
    SET costo_totale = CalcolaCostoTotale(ordine_id)
    WHERE p.ordine = ordine_id;
EXCEPTION
    WHEN OTHERS THEN -- Gestione degli errori
        RAISE EXCEPTION 'Errore nella creazione di una prenotazione oraria: %', SQLERRM;
        ROLLBACK;    -- Annulla la transazione in caso di errore
END
$$;

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
CREATE OR REPLACE PROCEDURE CreaArtistaSolista(
    nome_arte VARCHAR(255), 
    data_di_registrazione DATE, 
    codice_fiscale CHAR(16), 
    nome VARCHAR(255), 
    cognome VARCHAR(255), 
    data_di_nascita DATE, 
    email VARCHAR(255), 
    telefono VARCHAR(15)
) 
LANGUAGE plpgsql AS $$
BEGIN
    -- Inserimento nella tabella Artista
    INSERT INTO Artista (nome_arte, data_di_registrazione)
    VALUES (nome_arte, data_di_registrazione);
    
    -- Inserimento nella tabella Solista
    INSERT INTO Solista (artista, codice_fiscale, nome, cognome, data_di_nascita)
    VALUES (nome_arte, codice_fiscale, nome, cognome, data_di_nascita);

    -- Inserimento nella tabella EMAIL_A
    INSERT INTO EMAIL_A (email, artista)
    VALUES (email, nome_arte);

    -- Inserimento nella tabella TELEFONO_A
    INSERT INTO TELEFONO_A (numero, artista)
    VALUES (telefono, nome_arte);

EXCEPTION
    
    WHEN OTHERS THEN -- Gestione degli errori
       
        RAISE EXCEPTION 'Errore nella creazione dell artista e del solista: %', SQLERRM;
        ROLLBACK;    -- Annulla la transazione in caso di errore
END
$$;

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
CREATE OR REPLACE PROCEDURE CreaArtistaGruppo(
    nome_arte VARCHAR(255), 
    data_di_registrazione DATE, 
    email VARCHAR(255), 
    telefono VARCHAR(15), 
    data_formazione DATE
) 
LANGUAGE plpgsql AS $$
DECLARE
BEGIN
    -- Inserimento nella tabella Artista
    INSERT INTO Artista (nome_arte, data_di_registrazione)
    VALUES (nome_arte, data_di_registrazione);
    
    -- Inserimento nella tabella EMAIL_A
    INSERT INTO EMAIL_A (email, artista)
    VALUES (email, nome_arte);
    
    -- Inserimento nella tabella TELEFONO_A
    INSERT INTO TELEFONO_A (numero, artista)
    VALUES (telefono, nome_arte);
    
    -- Inserimento nella tabella Gruppo
    INSERT INTO Gruppo (artista, data_formazione)
    VALUES (nome_arte, data_formazione);
    
EXCEPTION
    -- Gestione degli errori
    WHEN OTHERS THEN
        -- Solleva l'eccezione per visualizzare l'errore
        RAISE EXCEPTION 'Errore nella creazione dell artista e del gruppo: %', SQLERRM;
        ROLLBACK;    -- Annulla la transazione in caso di errore

END
$$;

-----------------------------------------------------------------------------------------
/* CREA PARTECIPAZIONE SOLISTA GRUPPO
 * Gestisce la partecipazione di un solista a un gruppo nel database.
 *
 * INPUT:   nome_arte_solista       VARCHAR(255)
 * INPUT:   gruppo_nuovo            VARCHAR(255)
 * INPUT:   data_adesione_corrente  DATE
 */
CREATE OR REPLACE PROCEDURE CreaPartecipazioneSolistaGruppo(
    nome_arte_solista VARCHAR(255), 
    gruppo_nuovo VARCHAR(255), 
    data_adesione_corrente DATE
) 
LANGUAGE plpgsql AS $$
DECLARE
    gruppo_vecchio VARCHAR(255);
BEGIN
    -- Cerca il gruppo attuale del solista
    SELECT gruppo INTO gruppo_vecchio
    FROM SOLISTA
    WHERE artista = nome_arte_solista;

    -- Se il solista non è in nessun gruppo, il gruppo diventa il suo corrente
    IF gruppo_vecchio IS NULL THEN
        UPDATE SOLISTA
        SET gruppo = gruppo_nuovo, data_adesione = data_adesione_corrente
        WHERE artista = nome_arte_solista;
    ELSE
        -- Se il solista è già nel gruppo specificato, non fare nulla
        IF gruppo_vecchio = gruppo_nuovo THEN -- partecipazione corrente
            RAISE NOTICE 'Il solista è già nel gruppo specificato.';
        ELSE
            -- Se il solista è già in un gruppo, aggiorna la partecipazione passata e crea una nuova partecipazione
            INSERT INTO PARTECIPAZIONE_PASSATA (gruppo, solista, data_adesione, data_fine_adesione)
            VALUES (gruppo_vecchio, nome_arte_solista, data_adesione_corrente, CURRENT_DATE);
            
            UPDATE SOLISTA
            SET gruppo = gruppo_nuovo, data_adesione = data_adesione_corrente
            WHERE artista = nome_arte_solista;
        END IF;
    END IF;
         
    EXCEPTION
        -- Gestione degli errori
        WHEN OTHERS THEN
            -- Solleva l'eccezione per visualizzare l'errore
            RAISE EXCEPTION 'Errore nella creazione della partecipazione del solista al gruppo: %', SQLERRM;
            ROLLBACK;    -- Annulla la transazione in caso di errore
END
$$;

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
CREATE OR REPLACE PROCEDURE AggiungiCanzoneEPartecipazioni(
    titolo VARCHAR(255),
    produzione_id INT,
    testo TEXT, 
    data_di_registrazione DATE, 
    lunghezza_in_secondi INT,
    nome_del_file VARCHAR(255), 
    percorso_di_sistema VARCHAR(255), 
    estensione VARCHAR(10), 
    solisti_nome_arte VARCHAR[],
    codice_fiscale_tecnico CHAR(16)
)
LANGUAGE plpgsql AS $$
declare
    codice_canzone INT;
    solista_nome VARCHAR(255);
BEGIN
    -- Inserisce la canzone
    INSERT INTO CANZONE (titolo, produzione, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione)
    VALUES (titolo, produzione_id, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione)
    RETURNING codice INTO codice_canzone;

    -- Inserisce la partecipazione dei solisti
    FOREACH solista_nome IN ARRAY solisti_nome_arte LOOP

        -- Inserisce la partecipazione solo se il solista esiste nella tabella SOLISTA
        -- Cerca l'artista (solista) per nome d'arte
        PERFORM artista
        FROM SOLISTA
        WHERE artista = solista_nome;

        -- Se l'artista (solista) esiste, inserisce la partecipazione nella canzone
        IF FOUND THEN

            -- Verifica se il solista è già presente nella canzone
            INSERT INTO PARTECIPAZIONE (solista, canzone)
            VALUES (solista_nome, codice_canzone);

        ELSE
            -- Solleva un avviso se l'artista (solista) non esiste
            RAISE NOTICE 'Solista non trovato con nome d arte %, non è stato possibile aggiungere la partecipazione.', solista_nome;
        END IF;
    END LOOP;
    
    -- Aggiunge il tecnico alla tabella Lavora_a
    INSERT INTO LAVORA_A (tecnico, canzone)
    VALUES (codice_fiscale_tecnico, codice_canzone);

EXCEPTION
    -- Gestione degli errori
    WHEN OTHERS THEN
        -- Solleva l'eccezione per visualizzare l'errore
        RAISE EXCEPTION 'Errore durante l aggiunta della canzone: %', SQLERRM;
        ROLLBACK;    -- Annulla la transazione in caso di errore
END;
$$;