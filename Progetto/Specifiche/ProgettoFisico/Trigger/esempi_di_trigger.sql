SELECT * 
FROM information_schema.triggers 
WHERE event_object_table = 'prenotazione';

---------------------------------------------------------------------------------------------------

-- Spiegazione di SELECT 1
In SQL, SELECT 1 è usato per:

    Esistenza di una riga: Quando si vuole verificare se esiste almeno una riga che soddisfa una certa condizione.
    Ottimizzazione: È più efficiente di SELECT * perché non è necessario recuperare i dati delle colonne per fare questa verifica.

Ecco un esempio di come viene utilizzato:

sql

-- Verifica se esiste almeno un record in PRODUZIONE con codice specifico 123
SELECT 1
FROM PRODUZIONE
WHERE codice = 123;

Se esiste almeno una riga con codice = 123 nella tabella PRODUZIONE, questa query restituirà una riga con valore 1. Se non esiste alcuna riga che soddisfi la condizione, la query non restituirà alcun risultato.

---------------------------------------------------------------------------------------------------

RV4: Nella relazione partecipazione, si tiene traccia solo degli artisti che non sono membri del gruppo musicale che ha composto la produzione e che non sia il solista che abbia composto da solo una canzone.

    Implementazione: .

CREATE OR REPLACE FUNCTION check_participation_rule() 
RETURNS TRIGGER AS $$
BEGIN
    -- Controllo per il solista
    IF EXISTS (
        SELECT 1 
        FROM SOLISTA 
        WHERE artista = NEW.solista 
        AND NOT EXISTS (
            SELECT 1 FROM GRUPPO WHERE artista = NEW.solista
        )
    ) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Un solista può partecipare solo se non è già associato a un gruppo.';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_participation_rule_trigger
BEFORE INSERT ON PARTECIPAZIONE
FOR EACH ROW
EXECUTE FUNCTION check_participation_rule();


---------------------------------------------------------------------------------------------------
RV5: Non è possibile che un Gruppo partecipi alla composizione di una canzone appartenente ad un altro artista.

Spiegazione:

    Funzione check_group_composition:
        La funzione verifica se il Gruppo (identificato da NEW.solista) sta partecipando alla composizione di una canzone (identificata da NEW.canzone) appartenente a un artista diverso.
        Se trova che il Gruppo sta partecipando alla composizione di una canzone di un altro artista, solleva un eccezione con il messaggio appropriato.
    Trigger RV5:
        Questo trigger si attiva prima di ogni inserimento nella tabella PARTECIPAZIONE.
        Il trigger esegue la funzione check_group_composition per verificare il vincolo desiderato.

CREATE OR REPLACE FUNCTION check_group_composition() 
RETURNS TRIGGER AS $$
DECLARE
    group_artist VARCHAR(255);
    song_artist VARCHAR(255);
BEGIN
    -- Otteniamo l'artista del gruppo
    SELECT artista INTO group_artist FROM GRUPPO WHERE artista = NEW.solista;

    -- Otteniamo l'artista della canzone
    SELECT artista INTO song_artist FROM CANZONE WHERE codice = NEW.canzone;

    -- Verifichiamo se il gruppo sta partecipando alla composizione di una canzone di un altro artista
    IF group_artist IS NOT NULL AND group_artist <> song_artist THEN
        RAISE EXCEPTION 'Un gruppo non può partecipare alla composizione di una canzone di un altro artista.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER RV5
BEFORE INSERT ON PARTECIPAZIONE
FOR EACH ROW
EXECUTE FUNCTION check_group_composition();


RV6: L’attributo nome di Tipologia comprende il seguente dominio "giornaliero", "settimanale", "mensile".

    Implementazione: Questo vincolo può essere implementato con un vincolo CHECK sulla tabella TIPOLOGIA.

ALTER TABLE TIPOLOGIA
ADD CONSTRAINT check_tipo_nome
CHECK (nome IN ('giornaliero', 'settimanale', 'mensile'));

--
-- ATTENZIONE ATTENZIONE ATTENZIONE, ma se il costo totale di ordine è derivato dalle prenotazioni, ma le prenotazioni sono prenotabili solo dopo,
-- ciò significa che il costo totale non sarebbe un dato derivato ma viene passato in input dal sito quando l'utente effettua la scelta,
-- è un bel problema questo, quindi suggerisco di rimuovere questo vincolo o effettuarci delle modifiche sensate..., direi di rimuoverlo tanto
-- è l'operatore che ha la lista di chi non paga ed è compito suo fare in modo che chi non paga non si presenti allo studio cancellandone 
--   la prenotazione e di conseguenza l'ordine
RV7: Un artista deve aver pagato l’Ordine altrimenti non è possibile effettuare la prenotazione.

    Implementazione: Questo vincolo può essere implementato con un vincolo CHECK sulla tabella PRENOTAZIONE.
-------------------------


RV8: Le fasce orarie prenotabili vanno dalle 8:00 alle 12:00, dalle 14:00 alle 23:00.

    Implementazione: Questo vincolo può essere implementato con un vincolo CHECK sulla tabella FASCIA_ORARIA.

ALTER TABLE FASCIA_ORARIA
ADD CONSTRAINT check_orario
CHECK (
    (orario_inizio >= '08:00' AND orario_fine <= '12:00')
    OR (orario_inizio >= '14:00' AND orario_fine <= '23:00')
);

RV9: Le Fascie Orarie di un Ordine Orario devono essere scelte nel momento in cui si effettua l’ordine.
    Implementazione: Questo vincolo può essere implementato tramite un trigger che verifichi la corretta selezione delle fasce orarie.
CREATE OR REPLACE FUNCTION check_ordine_orario() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ordine IS NOT NULL THEN
        RAISE EXCEPTION 'Le fasce orarie devono essere scelte al momento dell''ordine.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_ordine_orario_trigger
BEFORE INSERT ON ORARIO
FOR EACH ROW
EXECUTE FUNCTION check_ordine_orario();

RV10: Nel caso si vogliano prenotare due giorni [settimane o mesi] è necessario effettuare due ordini distinti; quindi un ordine di tipo Giornaliero [Settimanale o Mensile] per giorno [settimana o mese] che si vuole prenotare. Gli ordini di tipo Giornaliero, Settimanale e Mensile possono effettuare prenotazioni Giornaliere, NON Orarie.

    Implementazione:

Funzione check_tipo_pacchetto:

    Questa funzione controlla se il nuovo pacchetto che si sta inserendo nella tabella PACCHETTO rispetta il vincolo RV10.
    Utilizza una query per verificare se esiste una tipologia nella tabella TIPOLOGIA che corrisponda al tipo di tipologia e al numero di giorni prenotati totali specificato nel nuovo pacchetto.
    Se la tipologia non esiste o non è tra 'giornaliero', 'settimanale' o 'mensile', viene sollevata un eccezione.

Trigger check_tipo_pacchetto_trigger:

    Questo trigger viene attivato prima di ogni inserimento nella tabella PACCHETTO.
    Esegue la funzione check_tipo_pacchetto appena definita per ogni riga che viene inserita nella tabella PACCHETTO.
    Se la funzione plpgsql solleva un'eccezione, l'inserimento del pacchetto non avviene.

-- Creazione della funzione per il controllo del vincolo RV10
CREATE OR REPLACE FUNCTION check_tipo_pacchetto()
RETURNS TRIGGER AS $$
BEGIN
    -- Controllo se il tipo di tipologia è corretto
    IF NOT EXISTS (
        SELECT 1 FROM TIPOLOGIA 
        WHERE nome = NEW.tipologia 
        AND n_giorni_prenotati_totali = NEW.n_giorni
        AND nome IN ('giornaliero', 'settimanale', 'mensile')
    ) THEN
        RAISE EXCEPTION 'Impossibile creare un pacchetto con questo tipo di tipologia e numero di giorni prenotati';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creazione del trigger BEFORE INSERT sulla tabella PACCHETTO
CREATE TRIGGER check_tipo_pacchetto_trigger
BEFORE INSERT ON PACCHETTO
FOR EACH ROW
EXECUTE FUNCTION check_tipo_pacchetto();

-- creare un trigger per fare in modo che le fascie orarie non overleappino, guardare la query gia creata per costruirlo.

fare un trigger che controli che n giorni prentoati totali non superi il numero di giorni nella tipologia di un dato ordine

CREATE OR REPLACE FUNCTION ControllaGiorniPrenotati()
RETURNS TRIGGER AS $$
BEGIN
    -- Controllo solo se è un ordine di tipo pacchetto
    IF EXISTS (
        SELECT 1
        FROM PACCHETTO p
        WHERE p.ordine = NEW.ordine
    ) THEN
        -- Calcola il numero totale di giorni prenotati per l'ordine
        SELECT SUM(t.n_giorni_prenotati_totali)
        INTO NEW.numero_giorni_prenotati
        FROM PACCHETTO p
        JOIN TIPOLOGIA t ON p.tipologia = t.nome
        WHERE p.ordine = NEW.ordine;

        -- Ottieni il numero massimo di giorni dalla tipologia
        SELECT t.n_giorni
        INTO NEW.numero_giorni_massimi
        FROM PACCHETTO p
        JOIN TIPOLOGIA t ON p.tipologia = t.nome
        WHERE p.ordine = NEW.ordine;

        -- Se il numero di giorni prenotati supera il numero massimo, genera un errore
        IF NEW.numero_giorni_prenotati > NEW.numero_giorni_massimi THEN
            RAISE EXCEPTION 'Numero di giorni prenotati supera il massimo consentito per la tipologia';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER controllo_giorni_prenotati
BEFORE INSERT OR UPDATE ON ORARIA
FOR EACH ROW
EXECUTE FUNCTION ControllaGiorniPrenotati();

-- trigger che controlla che se un ordine è stato già pagato allora il campo annullato non può essere false

-- trigger annullando una prenotazione giornaliera dobbiamo andare a decrementare di uno il numero di giorni prenotati totali di un ordine di tipo pacchetto

-- un ordine e una prenotazione possono essere annullati solo se il giorno a cui fanno riferimento non è antecedente al giorno in cui si fa la richiesta

-- TRIGGER: "Aggiunta una fascia oraria": "FASCIA-->ORARIA-->ORARIO": controllo "numero ore prenotate totali"

-- TRIGGER : una sala può avere al massimo due tecnici, uno di tipo Fonico e uno di tipo Tecnico Del Suono o  "Tecnico del suono_AND_Fonico"
