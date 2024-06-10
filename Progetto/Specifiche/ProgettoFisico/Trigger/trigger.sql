-- Implementazione dei vincoli
RV1: Non è necessario utilizzare i giorni di un pacchetto tutti in fila ma possono essere sfruttati nell’arco di 90 giorni. 

    Implementazione: Impedire la creazione di una prenotazione dopo 90 giorni dall effettuazione dell ordine. Impedire inoltre di inserire una prenotazione in una data antecedente alla data di effettuazione dell ordine.

CREATE OR REPLACE FUNCTION check_ordine_orario() 
RETURNS TRIGGER AS $$
DECLARE
    ordine_timestamp TIMESTAMP;
    differenza_giorni INTEGER;
BEGIN
    IF NEW.tipo THEN
        -- Otteniamo la data di effettuazione dell'ordine
        SELECT timestamp INTO ordine_timestamp
        FROM ordine WHERE codice = NEW.PACCHETTO; -- il pacchetto ha la stessa chiave primaria dell'ordine
        
        -- Calcoliamo la differenza dei giorni
        differenza_giorni := (NEW.giorno::date - ordine_timestamp::date);

        -- Controlliamo che la differenza non sia negativa
        IF differenza_giorni < 0 THEN
            RAISE EXCEPTION 'Non è possibile creare una prenotazione che vada indietro nel tempo.';
        END IF;
        
        -- Stampa la differenza dei giorni
        --RAISE NOTICE 'differenza giorni: %', differenza_giorni;

        -- Controlliamo se la differenza è maggiore di 90 giorni
        IF differenza_giorni > 90 THEN
            RAISE EXCEPTION 'Non è possibile creare una prenotazione dopo 90 giorni dall effettuazione dell ordine.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER RV1
BEFORE INSERT ON prenotazione 
FOR EACH ROW WHEN (NEW.tipo = TRUE)
EXECUTE FUNCTION check_ordine_orario();

---------------------------------------------------------------------------------------------------

RV2: Una produzione una volta pubblicata diventa immutabile quindi non è più possibile aggiungere canzoni.

    Implementazione: Questo vincolo può essere implementato con un trigger che si attiva prima dell inserimento di una produzione, per garantire che non possano essere aggiunte nuove canzoni.

Spiegazione:

    Funzione PL/pgSQL (check_production_immutable):
        Questa funzione controlla se la produzione associata alla nuova canzone (NEW.produzione) è stata pubblicata (stato = 'pubblicato').
        Se la produzione è stata pubblicata, lancia un eccezione che impedisce l inserimento della nuova canzone.
        Se la produzione non è stata pubblicata, restituisce semplicemente NEW.

    Trigger check_production_immutable_trigger:
        Questo trigger viene eseguito prima dell inserimento di una nuova riga nella tabella CANZONE.
        Per ogni riga inserita (FOR EACH ROW), esegue la funzione check_production_immutable.
        Il trigger è associato all evento BEFORE INSERT ON CANZONE, quindi viene attivato prima che i dati vengano effettivamente inseriti.

Come funziona:

    Quando si tenta di inserire una nuova canzone (INSERT INTO CANZONE), il trigger check_production_immutable_trigger verifica se la produzione associata (NEW.produzione) è già stata pubblicata.
    Se la produzione è stata pubblicata (stato = 'pubblicato'), il trigger solleva un eccezione che impedisce l inserimento della canzone.
    Se la produzione non è stata pubblicata, la nuova riga di CANZONE viene inserita con successo.

CREATE OR REPLACE FUNCTION controlla_produzione_immutabile() RETURNS TRIGGER AS $$
BEGIN
    PERFORM artista
    FROM PRODUZIONE 
    WHERE codice = NEW.produzione AND stato = 'Pubblicazione';
    
    -- Se la produzione interessata è già stata pubblicata
    IF FOUND THEN
        RAISE EXCEPTION 'Impossibile aggiungere canzoni a una produzione in stato di Pubblicazione (codice produzione: %).', NEW.produzione;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER RV2
BEFORE INSERT ON CANZONE
FOR EACH ROW
EXECUTE FUNCTION controlla_produzione_immutabile();

---------------------------------------------------------------------------------------------------

RV3: L entità Singolo comprende da una a tre canzoni, l entità Extended Play comprende un massimo di 5 canzoni e l entità Album non ha un limite al numero di canzoni fintanto che la durata complessiva stia sotto l ora.

    Implementazione: Questo vincolo può essere implementato con un vincolo CHECK sulla tabella CANZONE.

CREATE OR REPLACE FUNCTION check_tipo_produzione() RETURNS TRIGGER AS $$
DECLARE
    tipo_produzione VARCHAR(25);
    numero_canzoni INT;
    lunghezza_totale_secondi INT;
BEGIN

    -- Selezioniamo la tipologia della produzione (tra Album / EP / Singolo) in cui la canzone compare
    SELECT p.tipo_produzione INTO tipo_produzione FROM produzione AS p WHERE codice = NEW.produzione;
    
    IF tipo_produzione = 'Album' THEN
        -- Controlliamo se con l'aggiunta di una nuova canzone sforiamo il limite superiore di secondi (3600)
        SELECT SUM(lunghezza_in_secondi) INTO lunghezza_totale_secondi FROM CANZONE WHERE produzione = NEW.produzione;

        IF (lunghezza_totale_secondi + NEW.lunghezza_in_secondi > 3600)
            THEN RAISE EXCEPTION 'Impossibile aggiungere canzone. La durata complessiva di un Album deve essere tra mezz ora e un ora.';
        END IF;
    
    ELSE

        -- Calcoliamo il numero delle canzoni
        SELECT COUNT(*) INTO numero_canzoni FROM CANZONE WHERE produzione = NEW.produzione;
        
        IF tipo_produzione = 'Singolo' THEN 
            -- Controlliamo se con l'aggiunta di una canzone sforiamo il limite superiore (di 3 canzoni)
            IF (numero_canzoni + 1 > 3)
                THEN RAISE EXCEPTION 'Impossibile aggiungere canzone. Un Singolo può contenere al massimo 3 canzoni.';
            END IF;
                
        ELSEIF tipo_produzione = 'EP' THEN
            -- Controlliamo se con l'aggiunta di una canzone sforiamo il limite superiore dalle 5 canzoni 
            IF (numero_canzoni + 1 > 5)
                THEN RAISE EXCEPTION 'Impossibile aggiungere canzone. Un Extended Play può contenere al massimo 5 canzoni.';
            END IF;
            
        END IF;

    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER RV3
BEFORE INSERT ON CANZONE
FOR EACH ROW
EXECUTE FUNCTION check_tipo_produzione();

---------------------------------------------------------------------------------------------------