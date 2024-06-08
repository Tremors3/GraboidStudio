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
        ROLLBACK;    -- Annulla la transazione in caso di errore
        RAISE NOTICE 'Errore nell aggiornamento del costo totale di un ordine: %', SQLERRM;
END
$$;
CALL AggiornaCostoOrdine(1);

---------------------------------------------------------------------------------------------------

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
        ROLLBACK;    -- Annulla la transazione in caso di errore
        RAISE NOTICE 'Errore nella creazione di un ordine di tipo pacchetto: %', SQLERRM;
END
$$;
CALL CreaOrdinePacchetto('OPRABC90A01H501X', 'BandABC', 'Mensile');

/* INSERISCE UNA PRENOTAZIONE GIORNALIERA
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
        ROLLBACK;    -- Annulla la transazione in caso di errore
        RAISE NOTICE 'Errore nella creazione di una prenotazione giornaliera: %', SQLERRM;
END
$$;
CALL CreaPrenotazioneGiornaliera(3, '2024-07-10', 1, 101);

---------------------------------------------------------------------------------------------------

/* CREA UN ORDINE DI TIPO ORARIO E RELATIVA PRENOTAZIONE
 * La procedura produce un ordine di tipo orario e la rispettiva prenotazione.
 *
 * INPUT:   ordine_id       INT
 * INPUT:   giorno          DATE
 * INPUT:   orari_inizio    TIME[]
 * INPUT:   orari_fine      TIME[]
 * INPUT:   sala_piano      INT
 * INPUT:   sala_numero     INT
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
        ROLLBACK;    -- Annulla la transazione in caso di errore
        RAISE NOTICE 'Errore nella creazione di un ordine e di una prenotazione oraria: %', SQLERRM;
END
$$;
CALL CreaOrdineEPrenotazioneOrarie(
    'OPRABC90A01H501X', 'BandABC', 30,
    '2023-02-03', 
    '{08:00, 14:00}'::time[],
    '{10:00, 18:00}'::time[],
    2, 2
);

/* CREA UN NUOVO ORDINE DI TIPO ORARIO
 * La funzione produce un ordine di tipo orario. E restituisce il suo id.
 *
 * INPUT:   operatore_codice_fiscale   VARCHAR(16)
 * INPUT:   artista_nome_arte          VARCHAR(255)
 * INPUT:   costo_ora                  DECIMAL(10, 2)
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
    -- oraria ha come dipendenza la prenotazione e l'orario
    INSERT INTO ORARIO (ordine, n_ore_prenotate_totali, valore)
    VALUES (ordine_id, 0, costo_ora);

    -- inserimento pagamaneto
    INSERT INTO PAGAMENTO (ordine, stato, costo_totale, metodo)
    VALUES(ordine_id, 'Da pagare', NULL, NULL);

    RETURN ordine_id;
EXCEPTION
    WHEN OTHERS THEN -- Gestione degli errori
        ROLLBACK;    -- Annulla la transazione in caso di errore
        RAISE NOTICE 'Errore nella creazione di un ordine orario: %', SQLERRM;
END
$$;
SELECT CreaOrdineOrario(
    'OPRABC90A01H501X', 'BandABC', 30
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
CREATE OR REPLACE PROCEDURE CreaPrenotazioneOraria(
    ordine_id INT,
    giorno DATE,
    orari_inizio TIME[],
    orari_fine TIME[],
    sala_piano INT,
    sala_numero INT) LANGUAGE plpgsql AS $$
DECLARE
    prenotazione_id INT;
    ore_prenotate_totali INT;
BEGIN
    -- Controllo lunghezze array di orari
    IF array_length(orari_inizio, 1) != array_length(orari_fine, 1) THEN
        RAISE EXCEPTION 'Gli array di orari di inizio e fine devono avere la stessa lunghezza';
    END IF;

    -- inserimento prenotazione
    INSERT INTO PRENOTAZIONE (annullata, giorno, tipo, pacchetto, sala_piano, sala_numero)
    VALUES (FALSE, giorno, FALSE, NULL, sala_piano, sala_numero)
    RETURNING codice INTO prenotazione_id;

    -- inserimento oraria
    INSERT INTO ORARIA (prenotazione, orario)
    VALUES (prenotazione_id, ordine_id);

    -- inserimento fasce orarie
    FOR i IN 1..array_length(orari_inizio, 1) LOOP
        INSERT INTO FASCIA_ORARIA (oraria, orario_inizio, orario_fine)
        VALUES (prenotazione_id, orari_inizio[i], orari_fine[i]);
        -- numero di ore
        SELECT EXTRACT(HOUR FROM orari_fine[i] - orari_inizio[i]) INTO ore_prenotate_totali;
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
        ROLLBACK;    -- Annulla la transazione in caso di errore
        RAISE;       -- Sollevamento dell'eccezione
        RAISE NOTICE 'Errore nella creazione di una prenotazione oraria: %', SQLERRM;
END
$$;
CALL CreaPrenotazioneOraria(
    ordine_id, '2023-02-03', 
    '{08:00, 14:00}'::time[],
    '{10:00, 18:00}'::time[],
    2, 2
);

---------------------------------------------------------------------------------------------------
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
       
        ROLLBACK;  -- Annulla la transazione in caso di errore
        -- Solleva l'eccezione per visualizzare l'errore
        RAISE NOTICE 'Errore nella creazione dell artista e del solista: %', SQLERRM;
END
$$;
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

---------------------------------------------------------------------------------------------------

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
        -- Annulla la transazione in caso di errore
        ROLLBACK;
        -- Solleva l'eccezione per visualizzare l'errore
        RAISE NOTICE 'Errore nella creazione dell artista e del gruppo: %', SQLERRM;

END
$$;

CALL CreaArtistaGruppo(
    'Artista1234',
    '2024-06-09',
    'artista1234@email.com',
    '1234567333',
    '2024-01-01'
);

---------------------------------------------------------------------------------------------------
/* CREA PARTECIPAZIONE SOLISTA GRUPPO
 * Gestisce la partecipazione di un solista a un gruppo nel database.
 *
 * INPUT:   nome_arte_solista  VARCHAR(255)
 * INPUT:   nome_arte_gruppo   VARCHAR(255)
 * INPUT:   data_adesione      DATE
 */
CREATE OR REPLACE PROCEDURE CreaPartecipazioneSolistaGruppo(
    nome_arte_solista VARCHAR(255), 
    nome_arte_gruppo VARCHAR(255), 
    data_adesione_corrente DATE
) 
LANGUAGE plpgsql AS $$
DECLARE
    solista_gruppo VARCHAR(255);
BEGIN
    -- Cerca il gruppo attuale del solista
    SELECT gruppo INTO solista_gruppo
    FROM SOLISTA
    WHERE artista = nome_arte_solista;

    -- Se il solista non è in nessun gruppo, aggiorna con il nuovo gruppo
    IF solista_gruppo IS NULL THEN
        UPDATE SOLISTA
        SET gruppo = nome_arte_gruppo, data_adesione = data_adesione_corrente
        WHERE artista = nome_arte_solista;
    ELSE
         -- Se il solista è già nel gruppo specificato, non fare nulla
        IF solista_gruppo = nome_arte_gruppo THEN
            RAISE NOTICE 'Il solista è già nel gruppo specificato.';
        ELSE
            -- Se il solista è già in un gruppo, aggiorna la partecipazione passata e crea una nuova partecipazione
            INSERT INTO PARTECIPAZIONE_PASSATA (gruppo, solista, data_adesione, data_fine_adesione)
            VALUES (solista_gruppo, nome_arte_solista, data_adesione_corrente, CURRENT_DATE);
            
            UPDATE SOLISTA
            SET gruppo = nome_arte_gruppo, data_adesione = data_adesione_corrente
            WHERE artista = nome_arte_solista;
        END IF;
    END IF;
         
    EXCEPTION
        -- Gestione degli errori
        WHEN OTHERS THEN
        -- Annulla la transazione in caso di errore
        ROLLBACK;
        -- Solleva l'eccezione per visualizzare l'errore
        RAISE NOTICE 'Errore nella creazione della partecipazione del solista al gruppo: %', SQLERRM;
END
$$;

CALL CreaPartecipazioneSolistaGruppo('PopStar', 'Artista1234', '2024-06-08');
CALL CreaPartecipazioneSolistaGruppo('PopStar', 'Artista1234', '2024-06-08');
CALL CreaPartecipazioneSolistaGruppo('PopStar', 'BandABC', '2024-06-08');
CALL CreaPartecipazioneSolistaGruppo('PopStar', 'Group123', '2024-06-08');