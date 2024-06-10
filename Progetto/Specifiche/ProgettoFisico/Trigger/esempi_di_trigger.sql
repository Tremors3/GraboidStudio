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

RV7: Le fasce orarie prenotabili vanno dalle 8:00 alle 12:00, dalle 14:00 alle 23:00.

    Implementazione: Questo vincolo può essere implementato con un vincolo CHECK sulla tabella FASCIA_ORARIA.

ALTER TABLE FASCIA_ORARIA
ADD CONSTRAINT check_orario
CHECK (
    (orario_inizio >= '08:00' AND orario_fine <= '12:00')
    OR (orario_inizio >= '14:00' AND orario_fine <= '23:00')
);

RV8: Le Fascie Orarie di un Ordine Orario devono essere scelte nel momento in cui si effettua l’ordine.
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

---------------------------------------------------------------------------------------------------

RV9: Nel caso si vogliano prenotare due giorni [settimane o mesi] è necessario effettuare due ordini distinti; quindi un ordine di tipo Giornaliero [Settimanale o Mensile] per giorno [settimana o mese] che si vuole prenotare. Gli ordini di tipo Giornaliero, Settimanale e Mensile possono effettuare prenotazioni Giornaliere, NON Orarie.

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

-- creare un trigger per fare in modo che le fascie orarie non overleappino, guardare la query gia creata per costruirlo.

-- trigger che controlla che se un ordine è stato già pagato allora il campo annullato non può essere false

-- trigger annullando una prenotazione giornaliera dobbiamo andare a decrementare di uno il numero di giorni prenotati totali di un ordine di tipo pacchetto

-- un ordine e una prenotazione possono essere annullati solo se il giorno a cui fanno riferimento non è antecedente al giorno in cui si fa la richiesta

-- TRIGGER: "Aggiunta una fascia oraria": "FASCIA-->ORARIA-->ORARIO": controllo "numero ore prenotate totali"

-- TRIGGER : una sala può avere al massimo due tecnici, uno di tipo Fonico e uno di tipo Tecnico Del Suono o  "Tecnico del suono_AND_Fonico"
-- Creazione della funzione plpgsql per il controllo del vincolo
CREATE OR REPLACE FUNCTION check_max_tecnici()
RETURNS TRIGGER AS $$
DECLARE
    count_tecnico_fonico INTEGER;
    count_tecnico_suono INTEGER;
BEGIN
    -- Contiamo il numero di tecnici di tipo 'Fonico' e 'Tecnico del Suono_AND_Fonico'
    SELECT 
        COUNT(*) INTO count_tecnico_fonico 
    FROM 
        TECNICO 
    WHERE 
        sala = NEW.sala 
        AND tipo = 'Fonico';
    
    SELECT 
        COUNT(*) INTO count_tecnico_suono 
    FROM 
        TECNICO 
    WHERE 
        sala = NEW.sala 
        AND (tipo = 'Tecnico del Suono' OR tipo = 'Tecnico del Suono_AND_Fonico');
    
    -- Controlliamo se il numero di tecnici supera quello consentito
    IF count_tecnico_fonico >= 1 THEN
        RAISE EXCEPTION 'Impossibile aggiungere un tecnico di tipo Fonico. La sala ha già un tecnico di tipo Fonico.';
    END IF;

    IF count_tecnico_suono >= 1 THEN
        RAISE EXCEPTION 'Impossibile aggiungere un tecnico di tipo Tecnico del Suono o Tecnico del Suono_AND_Fonico. La sala ha già un tecnico di uno di questi tipi.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creazione del trigger BEFORE INSERT o BEFORE UPDATE sulla tabella TECNICO
CREATE TRIGGER check_max_tecnici_trigger
BEFORE INSERT OR UPDATE ON TECNICO
FOR EACH ROW
EXECUTE FUNCTION check_max_tecnici();
