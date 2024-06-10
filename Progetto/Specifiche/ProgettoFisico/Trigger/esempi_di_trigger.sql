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

-- TRIGGER T2: una sala può avere al massimo due tecnici, uno di tipo Fonico e uno di tipo Tecnico Del Suono o  "Tecnico del Suono_AND_Fonico": t, f -- f, t -- tf opzioni disponibili

CREATE OR REPLACE FUNCTION check_max_tecnici()
RETURNS TRIGGER AS $$
DECLARE
    numero_fonici INTEGER;
    numero_tecnici INTEGER;
    numero_tecnico_e_fonico INTEGER;
BEGIN

    -- Conta dei Fonici
    SELECT COUNT(codice_fiscale) INTO numero_fonici 
    FROM TECNICO WHERE sala_piano = NEW.sala_piano AND sala_numero = NEW.sala_numero AND tipo_tecnico = 'Fonico';

    -- Conta dei Tecnici del Suono
    SELECT COUNT(codice_fiscale) INTO numero_tecnici 
    FROM TECNICO WHERE sala_piano = NEW.sala_piano AND sala_numero = NEW.sala_numero AND tipo_tecnico = 'Tecnico del Suono';

    -- Conta dei Tecnico del Suono_AND_Fonico
    SELECT COUNT(codice_fiscale) INTO numero_tecnico_e_fonico 
    FROM TECNICO WHERE sala_piano = NEW.sala_piano AND sala_numero = NEW.sala_numero AND tipo_tecnico = 'Tecnico del Suono_AND_Fonico';

    IF ((numero_fonici + numero_tecnici) = 2)
        THEN RAISE EXCEPTION 'Impossibile aggiungere un tecnico, la sala comprende già un Tecnico del Suono e un Fonico.';
    ELSEIF (numero_fonici = 1 AND NEW.tipo_tecnico = 'Fonico')
        THEN RAISE EXCEPTION 'Impossibile aggiungere il tecnico, la sala comprende già un Fonico.';
    ELSEIF (numero_tecnici = 1 AND NEW.tipo_tecnico = 'Tecnico del Suono')
        THEN RAISE EXCEPTION 'Impossibile aggiungere il tecnico, la sala comprende già un Tecnico del Suono.';
    ELSEIF (numero_tecnico_e_fonico = 1)
        THEN RAISE EXCEPTION 'Impossibile aggiungere un tecnico, la sala comprende già un Tecnico del Suono_AND_Fonico.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creazione del trigger BEFORE INSERT o BEFORE UPDATE sulla tabella TECNICO
CREATE TRIGGER T2
BEFORE INSERT OR UPDATE ON TECNICO
FOR EACH ROW
EXECUTE FUNCTION check_max_tecnici();

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
CREATE TRIGGER T3
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
CREATE TRIGGER T4
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
CREATE TRIGGER T5
AFTER INSERT ON FASCIA_ORARIA
FOR EACH ROW
EXECUTE FUNCTION aggiorna_ore_prenotate();



-- creare un trigger per fare in modo che le fascie orarie non overleappino, guardare la query gia creata per costruirlo.