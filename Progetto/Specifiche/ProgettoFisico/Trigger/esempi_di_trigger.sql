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

    Implementazione: Questo vincolo può essere implementato tramite un vincolo CHECK sulla tabella PARTECIPAZIONE.

ALTER TABLE PARTECIPAZIONE
ADD CONSTRAINT check_participation_rule
CHECK (
    (
        SELECT COUNT(*) 
        FROM SOLISTA 
        WHERE artista = NEW.solista 
        AND NOT EXISTS (
            SELECT 1 FROM GRUPPO WHERE artista = NEW.solista
        )
    ) > 0
);

---------------------------------------------------------------------------------------------------

RV5: Non è possibile che un Gruppo partecipi alla composizione di una canzone appartenente ad un altro artista.

ALTER TABLE PARTECIPAZIONE
ADD CONSTRAINT check_group_composition
CHECK (
    NOT EXISTS (
        SELECT 1 FROM CANZONE C, GRUPPO G -- errata direi (almeno la selezione che seleziona 1) ma giusto per avere un idea
        WHERE C.artista = G.artista
        AND C.codice = NEW.canzone
        AND G.artista = NEW.solista
    )
);

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

    Implementazione: Questo vincolo può essere implementato con un vincolo CHECK sulla tabella PACCHETTO.

ALTER TABLE PACCHETTO
ADD CONSTRAINT check_tipo_pacchetto
CHECK (
    (
        SELECT nome FROM TIPOLOGIA WHERE nome = NEW.tipologia AND n_giorni_prenotati_totali = NEW.n_giorni
    ) IN ('giornaliero', 'settimanale', 'mensile')
);

creare un trigger per fare in modo che le fascie orarie non overleappino, guardare la query gia creata per costruirlo.

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
