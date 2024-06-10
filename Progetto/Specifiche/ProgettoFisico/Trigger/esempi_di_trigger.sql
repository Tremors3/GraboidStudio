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

-- trigger annullando una prenotazione giornaliera dobbiamo andare a decrementare di uno il numero di giorni prenotati totali di un ordine di tipo pacchetto

-- Creazione della funzione trigger
CREATE OR REPLACE FUNCTION decrementa_giorni_pacchetto()
RETURNS TRIGGER AS $$
BEGIN

    -- Decrementa il numero di giorni prenotati totali del pacchetto associato
    UPDATE PACCHETTO
    SET n_giorni_prenotati_totali = n_giorni_prenotati_totali - 1
    WHERE ordine = OLD.pacchetto;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creazione del trigger
CREATE TRIGGER T4
AFTER UPDATE ON PRENOTAZIONE
FOR EACH ROW WHEN (OLD.tipo = TRUE AND NEW.annullata = TRUE AND OLD.annullata = FALSE)
EXECUTE FUNCTION decrementa_giorni_pacchetto

---------------------------------------------------------------------------------------------------

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