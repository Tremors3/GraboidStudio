/* RV1: Non è necessario utilizzare i giorni di un pacchetto tutti in fila ma possono essere sfruttati nell arco di 90 giorni. 
 * IMPLEMENTAZIONE: Impedire la creazione di una prenotazione dopo 90 giorni dall effettuazione dell ordine.
 * Impedire inoltre di inserire una prenotazione in una data antecedente alla data di effettuazione dell ordine.
 */
CREATE OR REPLACE FUNCTION check_ordine_orario() 
RETURNS TRIGGER AS $$
DECLARE
    ordine_timestamp TIMESTAMP;
    differenza_giorni INTEGER;
BEGIN
    IF NEW.tipo THEN
        -- Otteniamo la data di effettuazione dell'ordine
        SELECT timestamp INTO ordine_timestamp
        FROM ordine WHERE codice = NEW.PACCHETTO;
        
        -- Calcoliamo la differenza dei giorni
        differenza_giorni := (NEW.giorno::date - ordine_timestamp::date);

        -- Controlliamo che la differenza non sia negativa
        IF differenza_giorni < 0 THEN
            RAISE EXCEPTION 'Non è possibile creare una prenotazione che vada indietro nel tempo.';
        END IF;
        
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

/* RV2: Una produzione una volta pubblicata diventa immutabile quindi non è più possibile aggiungere canzoni. 
 * IMPLEMENTAZIONE: Questo vincolo può essere implementato con un trigger che si attiva prima dell'inserimento 
 * di una produzione.
 */
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

/* RV3: L'entità Singolo comprende da una a tre canzoni, l'entità Extended Play comprende un massimo di 5 canzoni e 
 * l'entità Album non ha un limite al numero di canzoni fintanto che la durata complessiva stia sotto l'ora.
 */
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

/* RV4: Un solista può partecipare ad una canzone soltanto se: non è il compositore della produzione 
 * nella quale compare la canzone interessata; non fa parte del gruppo che ha composto la produzione 
 * nella quale si trova la canzone interessata.
 */
CREATE OR REPLACE FUNCTION check_participation_rule() 
RETURNS TRIGGER AS $$
DECLARE
    gruppo_del_solista VARCHAR(255);
BEGIN

    -- Si controlla se il solista è a capo della produzione di cui fa parte la canzone
    PERFORM FROM produzione as p
    JOIN artista as a ON p.artista = NEW.solista
    JOIN canzone as c ON p.codice = c.produzione
    WHERE c.codice = NEW.canzone;
    
    -- Controllo per il solista a capo
    IF (FOUND) THEN
        RAISE EXCEPTION 'Un solista non può partecipare a una canzone di cui è già a capo.';
    END IF;
    
    -- Selezioniamo il nome del gruppo corrente del solista
    SELECT gruppo INTO gruppo_del_solista FROM solista AS s WHERE s.artista = new.solista;
    IF (gruppo_del_solista IS NOT NULL) THEN
    
        -- Controlliamo se il solista fa parte del gruppo creatore della produzione e di conseguenza della canzone
        PERFORM FROM canzone AS c
        JOIN produzione AS p ON c.produzione = p.codice
        JOIN artista AS a ON p.artista = a.nome_arte
        WHERE c.codice = NEW.canzone AND a.nome_arte = gruppo_del_solista;

        -- Controllo per il solista a capo
        IF (FOUND) THEN
            RAISE EXCEPTION 'll solista fa parte del gruppo creatore della produzione e di conseguenza della canzone.';
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER RV4
BEFORE INSERT ON PARTECIPAZIONE
FOR EACH ROW
EXECUTE FUNCTION check_participation_rule();

---------------------------------------------------------------------------------------------------

/* T1: Dato un certo ordine, controllare che il numero di giorni prenotati non superi il numero di 
 * giorni prenotabili offerti dal pacchetto.
 */
CREATE OR REPLACE FUNCTION ControllaGiorniPrenotati()
RETURNS TRIGGER AS $$
DECLARE
    numero_giorni_prenotati INT;
    numero_giorni_prenotabili INT;
    nome_tipologia VARCHAR(255);
BEGIN

    -- Recuperiamo il numero di giorni già prenotati e il numero massimo di giorni prenotabili
    SELECT p.n_giorni_prenotati_totali, t.n_giorni INTO numero_giorni_prenotati, numero_giorni_prenotabili
    FROM pacchetto as p
    JOIN tipologia as t ON t.nome = p.tipologia
    WHERE p.ordine = NEW.pacchetto;

    -- Se il numero di giorni prenotati più il corrente supera il numero massimo di giorni prenotabili
    IF numero_giorni_prenotati + 1 > numero_giorni_prenotabili THEN
        RAISE EXCEPTION 'Numero di giorni prenotati supera il massimo consentito per la tipologia.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER T1
BEFORE INSERT ON prenotazione
FOR EACH ROW WHEN (NEW.tipo = TRUE) 
EXECUTE FUNCTION ControllaGiorniPrenotati();

---------------------------------------------------------------------------------------------------

/* T2: Una sala può avere al massimo due tecnici. Uno di tipo Fonico e l'altro di tipo Tecnico del Suono.
 * Può anche darsi che una sala contenga soltanto un tecnico di tipo: "Tecnico del Suono_AND_Fonico".
 */ 
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

CREATE TRIGGER T2
BEFORE INSERT OR UPDATE ON TECNICO
FOR EACH ROW
EXECUTE FUNCTION check_max_tecnici();

---------------------------------------------------------------------------------------------------

/* T3: Se un ordine è già stato pagato allora il campo "annullato" non può essere impostato a FALSE.
 */
CREATE OR REPLACE FUNCTION check_ordine_pagato()
RETURNS TRIGGER AS $$
BEGIN
    -- Se l'ordine è stato pagato otteniamo un record
    PERFORM FROM ORDINE
    JOIN PAGAMENTO ON ordine = NEW.codice
    WHERE stato = 'Pagato';

    -- Verifica se l'ordine è stato pagato
    IF FOUND THEN
    
        -- Se l'ordine è stato pagato, impedisce che il campo annullato sia impostato su TRUE
        RAISE EXCEPTION 'Non è possibile annullare un ordine già pagato.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER T3
BEFORE UPDATE ON ORDINE
FOR EACH ROW WHEN (NEW.annullato = TRUE AND OLD.annullato = FALSE)
EXECUTE FUNCTION check_ordine_pagato();

---------------------------------------------------------------------------------------------------

/* T4: Annullando una prenotazione giornaliera dobbiamo andare a decrementare di uno il numero di giorni 
 * prenotati totali di un ordine di tipo pacchetto.
 */
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

CREATE TRIGGER T4
AFTER UPDATE ON prenotazione
FOR EACH ROW WHEN (OLD.tipo = TRUE AND NEW.annullata = TRUE AND OLD.annullata = FALSE)
EXECUTE FUNCTION decrementa_giorni_pacchetto();

---------------------------------------------------------------------------------------------------
/* T5: Aggiorna il numero totale di ore prenotate dopo la modifica di una fascia oraria.
 */
CREATE OR REPLACE FUNCTION aggiorna_ore_prenotate()
RETURNS TRIGGER AS $$
DECLARE
    nuove_ore_prenotate INTERVAL;
    vecchie_ore_prenotate INTERVAL;
BEGIN
    -- Calcolo delle ore prenotate
    nuove_ore_prenotate := NEW.orario_fine - NEW.orario_inizio;
    vecchie_ore_prenotate := OLD.orario_fine - OLD.orario_inizio;

    -- Aggiorna il numero totale di ore prenotate nella tabella ORARIO
    UPDATE ORARIO
    SET n_ore_prenotate_totali = 
        n_ore_prenotate_totali + EXTRACT(HOUR FROM nuove_ore_prenotate) - EXTRACT(HOUR FROM vecchie_ore_prenotate)
    WHERE ordine = NEW.oraria;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER T5
AFTER UPDATE ON FASCIA_ORARIA
FOR EACH ROW WHEN (NEW.orario_inizio != OLD.orario_inizio OR NEW.orario_fine != OLD.orario_fine)
EXECUTE FUNCTION aggiorna_ore_prenotate();

---------------------------------------------------------------------------------------------------

/* T6: Una prenotazione può essere annullata solo se fa riferimento ad una data futura.
 */
CREATE OR REPLACE FUNCTION check_data_futura_per_prenotazione()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se la data della prenotazione è futura
    IF NEW.giorno < CURRENT_DATE THEN
        -- Se la data non è futura, impedisce l'annullamento
        RAISE EXCEPTION 'Non è possibile annullare una prenotazione passata.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER T6
AFTER UPDATE ON prenotazione
FOR EACH ROW WHEN (NEW.annullata = TRUE AND OLD.annullata = FALSE)
EXECUTE FUNCTION check_data_futura_per_prenotazione();

---------------------------------------------------------------------------------------------------

/* T7: Un ordine può essere annullato solo se fa riferimento ad una data futura.
 */
CREATE OR REPLACE FUNCTION check_data_futura_per_ordine()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se la data della prenotazione è futura
    IF NEW.timestamp < CURRENT_DATE THEN
        -- Se la data non è futura, impedisce l'annullamento
        RAISE EXCEPTION 'Non è possibile annullare un ordine passato.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER T7
AFTER UPDATE ON ordine
FOR EACH ROW WHEN (NEW.annullato = TRUE AND OLD.annullato = FALSE)
EXECUTE FUNCTION check_data_futura_per_ordine();

---------------------------------------------------------------------------------------------------