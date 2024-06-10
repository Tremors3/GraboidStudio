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



-- trigger che controlla che se un ordine è stato già pagato allora il campo annullato non può essere false

-- Creazione della funzione trigger
CREATE OR REPLACE FUNCTION check_ordine_pagato()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se l'ordine è stato pagato
    IF EXISTS (SELECT 1 FROM PAGAMENTO WHERE ordine = NEW.codice AND stato = 'Pagato') THEN
        -- Se l'ordine è stato pagato, impedisce che il campo annullato sia impostato su FALSE
        IF NEW.annullato = FALSE THEN
            RAISE EXCEPTION 'Non è possibile annullare un ordine già pagato';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creazione del trigger
CREATE TRIGGER check_ordine_pagato_trigger
BEFORE UPDATE ON ORDINE
FOR EACH ROW
EXECUTE FUNCTION check_ordine_pagato();


-- trigger annullando una prenotazione giornaliera dobbiamo andare a decrementare di uno il numero di giorni prenotati totali di un ordine di tipo pacchetto

-- Creazione della funzione trigger
CREATE OR REPLACE FUNCTION decrementa_giorni_pacchetto()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se la prenotazione è di tipo giornaliera (tipo = TRUE) e se è stata annullata
    IF OLD.tipo = TRUE AND NEW.annullata = TRUE AND OLD.annullata = FALSE THEN
        -- Decrementa il numero di giorni prenotati totali del pacchetto associato
        UPDATE PACCHETTO
        SET n_giorni_prenotati_totali = n_giorni_prenotati_totali - 1
        WHERE ordine = OLD.pacchetto;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creazione del trigger
CREATE TRIGGER decrementa_giorni_pacchetto_trigger
AFTER UPDATE ON PRENOTAZIONE
FOR EACH ROW
WHEN (OLD.tipo = TRUE AND NEW.annullata = TRUE AND OLD.annullata = FALSE)
EXECUTE FUNCTION decrementa_giorni_p


-- un ordine e una prenotazione possono essere annullati solo se il giorno a cui fanno riferimento non è antecedente al giorno in cui si fa la richiesta

-- TRIGGER: "Aggiunta una fascia oraria": "FASCIA-->ORARIA-->ORARIO": controllo "numero ore prenotate totali"

-- Creazione della funzione trigger
CREATE OR REPLACE FUNCTION aggiorna_ore_prenotate()
RETURNS TRIGGER AS $$
DECLARE
    ore_prenotate INTERVAL;
BEGIN
    -- Calcolo delle ore prenotate
    ore_prenotate := NEW.orario_fine - NEW.orario_inizio;
    
    -- Aggiorna il numero totale di ore prenotate nella tabella ORARIO
    UPDATE ORARIO
    SET n_ore_prenotate_totali = n_ore_prenotate_totali + EXTRACT(EPOCH FROM ore_prenotate) / 3600
    WHERE ordine = NEW.oraria;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creazione del trigger
CREATE TRIGGER aggiorna_ore_prenotate_trigger
AFTER INSERT ON FASCIA_ORARIA
FOR EACH ROW
EXECUTE FUNCTION aggiorna_ore_prenotate();


-- TRIGGER : una sala può avere al massimo due tecnici, uno di tipo Fonico e uno di tipo Tecnico Del Suono o  "Tecnico del Suono_AND_Fonico"
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
-- creare un trigger per fare in modo che le fascie orarie non overleappino, guardare la query gia creata per costruirlo.