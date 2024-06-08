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
        RAISE;       -- Sollevamento dell'eccezione
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
        RAISE;       -- Sollevamento dell'eccezione
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
        RAISE;       -- Sollevamento dell'eccezione
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
        RAISE;       -- Sollevamento dell'eccezione
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
        RAISE;       -- Sollevamento dell'eccezione
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
END
$$;
CALL CreaPrenotazioneOraria(
    ordine_id, '2023-02-03', 
    '{08:00, 14:00}'::time[],
    '{10:00, 18:00}'::time[],
    2, 2
);