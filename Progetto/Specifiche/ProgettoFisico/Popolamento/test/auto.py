import random

import psycopg2
from faker import Faker
import random

# Crea un'istanza di Faker
fake = Faker()

# Connessione al database PostgreSQL
c = psycopg2.connect(
    dbname="test",
    user="postgres",
    password="",
    host="localhost",
    port="5432"
)
cu = c.cursor()

def initialize_tables():
    cu.execute("""
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
               CREATE TABLE ARTISTA (
    nome_arte VARCHAR(255) PRIMARY KEY,
    data_di_registrazione DATE NOT NULL
); 
 
CREATE TABLE GRUPPO ( 
    artista VARCHAR(255) PRIMARY KEY, 
    data_formazione DATE NOT NULL, 
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte) 
    ON UPDATE CASCADE ON DELETE RESTRICT
); 
 
CREATE TABLE SOLISTA ( 
    artista VARCHAR(255), 
    codice_fiscale CHAR(16) UNIQUE, 
    nome VARCHAR(255), 
    cognome VARCHAR(255), 
    data_di_nascita DATE NOT NULL, 
    gruppo VARCHAR(255), 
    data_adesione DATE, 
    PRIMARY KEY (artista), 
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (gruppo) REFERENCES GRUPPO(artista) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT data_di_nascita_corretta CHECK(date_part('year', data_di_nascita)>date_part('year', CURRENT_DATE)-100)
); 
 
CREATE TABLE PARTECIPAZIONE_PASSATA ( 
    gruppo VARCHAR(255) NOT NULL, 
    solista VARCHAR(255) NOT NULL, 
    data_adesione DATE NOT NULL, 
    data_fine_adesione DATE NOT NULL, 
    PRIMARY KEY (gruppo, solista), 
    FOREIGN KEY (gruppo) REFERENCES GRUPPO(artista) ON UPDATE CASCADE ON DELETE CASCADE, 
    FOREIGN KEY (solista) REFERENCES SOLISTA(artista) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT data_fine_adesione_corretta CHECK(data_fine_adesione >= data_adesione)
);
 
CREATE TABLE EMAIL_A ( 
    email VARCHAR(255) PRIMARY KEY, 
    artista VARCHAR(255) NOT NULL, 
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte) ON UPDATE CASCADE ON DELETE CASCADE
); 
 
CREATE TABLE TELEFONO_A ( 
    numero VARCHAR(15), 
    artista VARCHAR(255), 
    PRIMARY KEY (numero), 
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte) ON UPDATE CASCADE ON DELETE CASCADE
); 
 
CREATE TABLE TIPO_PRODUZIONE ( 
    nome VARCHAR(25) PRIMARY KEY,
    CHECK (nome IN ('Album', 'Singolo', 'EP'))
); 

CREATE TABLE GENERE ( 
    nome VARCHAR(255) PRIMARY KEY 
); 
 
CREATE TABLE PRODUZIONE ( 
    -- Unique code
    codice SERIAL PRIMARY KEY,

    -- Old Primary Key
    titolo VARCHAR(255) NOT NULL,
    artista VARCHAR(255) NOT NULL,

    -- Old Primary Key Uniqueness Maintained
    CONSTRAINT unique_produzione UNIQUE (titolo, artista),
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte) ON UPDATE CASCADE ON DELETE RESTRICT,

    -- Other
    data_inizio DATE NOT NULL, 
    data_fine DATE, 
    stato VARCHAR(13) NOT NULL, 
    tipo_produzione VARCHAR(25), 
    genere VARCHAR(255), 
    FOREIGN KEY (tipo_produzione) REFERENCES TIPO_PRODUZIONE(nome) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (genere) REFERENCES GENERE(nome) ON UPDATE CASCADE ON DELETE SET NULL,
    CHECK (data_inizio <= data_fine),
    CHECK (stato IN ('Produzione', 'Pubblicazione'))
); 
 
CREATE TABLE CANZONE (
    -- Unique code
    codice SERIAL PRIMARY KEY,

    -- Old Primary Key
    titolo VARCHAR(255) NOT NULL, 
    produzione INTEGER NOT NULL,

    -- Old Primary Key Uniqueness Maintained
    CONSTRAINT unique_canzone UNIQUE (titolo, produzione),
    FOREIGN KEY (produzione) REFERENCES PRODUZIONE(codice) ON UPDATE CASCADE ON DELETE RESTRICT,
    -- Other
    testo TEXT, 
    data_di_registrazione DATE, 
    lunghezza_in_secondi INTEGER, 
    nome_del_file VARCHAR(255), 
    percorso_di_sistema VARCHAR(255), 
    estensione VARCHAR(10),
    CONSTRAINT lunghezza_in_secondi_corretta CHECK (lunghezza_in_secondi > 0)
); 

CREATE TABLE PARTECIPAZIONE ( 
    -- Unique code
    codice SERIAL PRIMARY KEY,

    -- Old Primary Key
    solista VARCHAR(255) NOT NULL, 
    canzone INTEGER NOT NULL,

    -- Old Primary Key Uniqueness Maintained
    CONSTRAINT unique_partecipazione UNIQUE (solista, canzone),
    FOREIGN KEY (solista) REFERENCES SOLISTA(artista) ON UPDATE CASCADE ON DELETE CASCADE, 
    FOREIGN KEY (canzone) REFERENCES CANZONE(codice) ON UPDATE CASCADE ON DELETE CASCADE
); 
 
CREATE TABLE PRODUTTORE ( 
    solista VARCHAR(255) PRIMARY KEY, 
    FOREIGN KEY (solista) REFERENCES SOLISTA(artista)
    ON UPDATE CASCADE ON DELETE CASCADE
); 
 
CREATE TABLE CONDURRE ( 
    produttore VARCHAR(255), 
    produzione INTEGER, 
    PRIMARY KEY (produttore, produzione), 
    FOREIGN KEY (produttore) REFERENCES PRODUTTORE(solista) ON UPDATE CASCADE ON DELETE CASCADE, 
    FOREIGN KEY (produzione) REFERENCES PRODUZIONE(codice) ON UPDATE CASCADE ON DELETE CASCADE
); 
 
CREATE TABLE OPERATORE ( 
    codice_fiscale CHAR(16) PRIMARY KEY, 
    nome VARCHAR(255) NOT NULL, 
    cognome VARCHAR(255) NOT NULL, 
    data_di_nascita DATE NOT NULL, 
    data_di_assunzione DATE NOT NULL, 
    iban VARCHAR(34) UNIQUE,
    CONSTRAINT data_di_nascita_corretta CHECK(date_part('year', data_di_nascita)>date_part('year', CURRENT_DATE)-100)
); 
 
CREATE TABLE EMAIL_O ( 
    email VARCHAR(255) NOT NULL, 
    operatore CHAR(16) NOT NULL, 
    PRIMARY KEY (email), 
    FOREIGN KEY (operatore) REFERENCES OPERATORE(codice_fiscale) ON UPDATE CASCADE ON DELETE CASCADE
); 
 
CREATE TABLE TELEFONO_O ( 
    numero VARCHAR(15) NOT NULL, 
    operatore CHAR(16) NOT NULL, 
    PRIMARY KEY (numero), 
    FOREIGN KEY (operatore) REFERENCES OPERATORE(codice_fiscale) ON UPDATE CASCADE ON DELETE CASCADE 
); 
 
CREATE TABLE ORDINE ( 
    -- Unique code
    codice SERIAL PRIMARY KEY,

    -- Old Primary Key
    timestamp TIMESTAMP NOT NULL, 
    artista VARCHAR(255) NOT NULL,

    -- Old Primary Key Uniqueness Maintained
    CONSTRAINT unique_ordine UNIQUE (timestamp, artista), 
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte) ON UPDATE CASCADE ON DELETE RESTRICT,

    -- Other
    annullato BOOLEAN NOT NULL,
    operatore CHAR(16) NOT NULL,
    FOREIGN KEY (operatore) REFERENCES OPERATORE(codice_fiscale) ON UPDATE CASCADE ON DELETE RESTRICT
); 
 
CREATE TABLE METODO ( 
    nome VARCHAR(255) PRIMARY KEY 
); 
 
CREATE TABLE PAGAMENTO (

    ordine INTEGER PRIMARY KEY,
    FOREIGN KEY (ordine) REFERENCES ORDINE(codice), 

    -- Other
    stato VARCHAR(50) NOT NULL CHECK (stato IN ('Da pagare', 'Pagato')), -- Da pagare, Pagato 
    costo_totale DECIMAL(10, 2), 
    metodo VARCHAR(255), 
    FOREIGN KEY (metodo) REFERENCES METODO(nome) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT costo_totale_maggiore CHECK(costo_totale > 0)

); 
 
CREATE TABLE TIPOLOGIA ( 
    nome VARCHAR(255) PRIMARY KEY, 
    valore DECIMAL(10, 2) NOT NULL, 
    n_giorni INTEGER NOT NULL, -- 1 giorno, 7 giorni, 30 giorni 
    CONSTRAINT check_nome_tipologia CHECK (nome IN ('Giornaliera', 'Settimanale', 'Mensile')),
    CONSTRAINT check_valore_positivo CHECK (valore > 0),
    CONSTRAINT check_n_giorni CHECK (n_giorni = 1 OR n_giorni = 7 OR n_giorni = 30)
); 
 
CREATE TABLE PACCHETTO ( 
    ordine INTEGER PRIMARY KEY,
    FOREIGN KEY (ordine) REFERENCES ORDINE(codice) ON UPDATE CASCADE ON DELETE CASCADE,

    tipologia VARCHAR(255) NOT NULL,
    FOREIGN KEY (tipologia) REFERENCES TIPOLOGIA(nome) ON UPDATE CASCADE ON DELETE RESTRICT,

    -- Other
    n_giorni_prenotati_totali INTEGER
); 
 
CREATE TABLE ORARIO ( 
    ordine INTEGER PRIMARY KEY,
    FOREIGN KEY (ordine) REFERENCES ORDINE(codice) ON UPDATE CASCADE ON DELETE CASCADE,
    
    n_ore_prenotate_totali INTEGER, 
    valore DECIMAL(10, 2),
    CONSTRAINT valore_maggiore CHECK (valore > 0)
    -- one to one
    --oraria INTEGER REFERENCES ORARIA(prenotazione) UNIQUE DEFERRABLE INITIALLY DEFERRED
); 
 
CREATE TABLE SALA ( 
    piano INTEGER, 
    numero INTEGER, 
    PRIMARY KEY (piano, numero) 
); 
 
CREATE TABLE PRENOTAZIONE ( 
    codice SERIAL PRIMARY KEY, 
    annullata BOOLEAN NOT NULL, 
    giorno DATE NOT NULL, 
    tipo BOOLEAN NOT NULL, 
    pacchetto INTEGER, 
    sala_piano INTEGER NOT NULL, 
    sala_numero INTEGER NOT NULL,
    FOREIGN KEY (pacchetto) REFERENCES PACCHETTO(ordine) ON UPDATE CASCADE ON DELETE RESTRICT, 
    FOREIGN KEY (sala_piano, sala_numero) REFERENCES SALA(piano, numero) ON UPDATE CASCADE ON DELETE RESTRICT
); 
 
CREATE TABLE ORARIA ( 
    prenotazione INTEGER PRIMARY KEY, 
    orario INTEGER UNIQUE NOT NULL, --one to one
    FOREIGN KEY (prenotazione) REFERENCES PRENOTAZIONE(codice) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (orario) REFERENCES ORARIO(ordine) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE FASCIA_ORARIA ( 
    oraria INTEGER NOT NULL, 
    orario_inizio TIME, 
    orario_fine TIME, 
    PRIMARY KEY (oraria, orario_inizio), 
    FOREIGN KEY (oraria) REFERENCES ORARIA(prenotazione) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT orario_fine_maggiore CHECK(orario_fine>orario_inizio),
    CONSTRAINT check_orario CHECK (
        (orario_inizio >= '08:00' AND orario_fine <= '12:00')
        OR (orario_inizio >= '14:00' AND orario_fine <= '23:00'))
); 
 
CREATE TABLE TIPO_TECNICO (
    nome VARCHAR(64) PRIMARY KEY,
    CHECK (nome IN ('Fonico', 'Tecnico del Suono', 'Tecnico del Suono_AND_Fonico'))
); 
 
CREATE TABLE TECNICO (
    codice_fiscale CHAR(16) PRIMARY KEY,
    sala_piano INT NOT NULL,
    sala_numero INT NOT NULL,
    tipo_tecnico VARCHAR(64) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    cognome VARCHAR(255) NOT NULL,
    data_di_nascita DATE NOT NULL,
    data_di_assunzione DATE NOT NULL,
    iban VARCHAR(34),
    FOREIGN KEY (sala_piano, sala_numero) REFERENCES SALA(piano, numero) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (tipo_tecnico) REFERENCES TIPO_TECNICO(nome) ON UPDATE CASCADE ON DELETE RESTRICT
); 
 
CREATE TABLE EMAIL_T (
    email VARCHAR(255) PRIMARY KEY,
    tecnico CHAR(16) NOT NULL,
    FOREIGN KEY (tecnico) REFERENCES TECNICO(codice_fiscale) ON UPDATE CASCADE ON DELETE CASCADE
); 
 
CREATE TABLE TELEFONO_T (
    numero VARCHAR(15) PRIMARY KEY,
    tecnico CHAR(16) NOT NULL,
    FOREIGN KEY (tecnico) REFERENCES TECNICO(codice_fiscale) ON UPDATE CASCADE ON DELETE CASCADE
); 
 
CREATE TABLE LAVORA_A (
    tecnico CHAR(16),
    canzone INTEGER,
    PRIMARY KEY (tecnico, canzone),
    FOREIGN KEY (tecnico) REFERENCES TECNICO(codice_fiscale) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (canzone) REFERENCES CANZONE(codice) ON UPDATE CASCADE ON DELETE CASCADE
); 
 
CREATE TABLE ATTREZZATURA (
    codice SERIAL PRIMARY KEY,
    modello VARCHAR(64),
    costruttore VARCHAR(255)
); 
 
CREATE TABLE AVERE (
    piano INTEGER NOT NULL,
    numero INTEGER NOT NULL,
    attrezzo INTEGER NOT NULL,

    PRIMARY KEY (piano, numero, attrezzo),
    FOREIGN KEY (attrezzo) REFERENCES ATTREZZATURA(codice) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (piano, numero) REFERENCES SALA(piano, numero) ON UPDATE CASCADE ON DELETE RESTRICT
); 
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

-----------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------

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
            RAISE EXCEPTION 'Il solista fa parte del gruppo creatore della produzione e di conseguenza della canzone.';
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER RV4
BEFORE INSERT ON PARTECIPAZIONE
FOR EACH ROW
EXECUTE FUNCTION check_participation_rule();

-----------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------
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

-----------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------
 
              """)


def truncate_table(table_name):
    try:
        cu.execute(f"TRUNCATE TABLE {table_name} CASCADE;")
        print(f"Tabelle {table_name} svuotate.")
    except Exception as e:
        c.rollback()
        print(f"Errore durante lo svuotamento di {table_name}: {e}")

def clean_database():
    tables_to_clean = [
        'LAVORA_A',
        'TELEFONO_T',
        'EMAIL_T',
        'TECNICO',
        'TIPO_TECNICO',
        'FASCIA_ORARIA',
        'ORARIA',
        'PAGAMENTO',
        'METODO',
        'ORDINE',
        'SALA',
        'PRENOTAZIONE',
        'ORARIO',
        'PACCHETTO',
        'TIPOLOGIA',
        'TELEFONO_O',
        'EMAIL_O',
        'OPERATORE',
        'CANZONE',
        'PRODUTTORE',
        'CONDURRE',
        'PRODUZIONE',
        'GENERE',
        'TIPO_PRODUZIONE',
        'PARTECIPAZIONE',
        'GRUPPO',
        'ARTISTA',
        'SOLISTA',
        'PARTECIPAZIONE_PASSATA'
    ]
    
    for table_name in tables_to_clean:
        truncate_table(table_name)
    
    # Committa le modifiche e chiude la connessione
    c.commit()
    c.close()
    print("Database pulito")

# Connessione al database PostgreSQL
conn = psycopg2.connect(
    dbname="test",
    user="postgres",
    password="root",
    host="localhost",
    port="5432"
)
cursor = conn.cursor()

def initialize():

    cursor.execute(
        """-- Popolamento della tabella ARTISTA
INSERT INTO ARTISTA (nome_arte, data_di_registrazione) VALUES
('BandABC', '2020-01-15'),
('SoloABC', '2018-08-14'),
('SoloDEF', '2016-01-02'),
('SoloXYZ', '2019-07-23'),
('Group123', '2018-11-30'),
('DuoLMN', '2021-02-14'),
('SoloPQR', '2017-05-18'),
('TrioUVW', '2019-09-25'),
('BandDEF', '2020-03-10'),
('SoloGHI', '2018-06-20'),
('GroupJKL', '2019-04-12'),
('SoloJKL', '2022-12-03'),
('DuoMNO', '2021-07-22'),
('SoloSTU', '2021-06-21');

-- Popolamento della tabella GRUPPO
INSERT INTO GRUPPO (artista, data_formazione) VALUES
('BandABC', '2020-01-15'),
('Group123', '2018-11-30'),
('DuoLMN', '2021-02-14'),
('TrioUVW', '2019-09-25'),
('BandDEF', '2020-03-10'),
('GroupJKL', '2019-04-12'),
('DuoMNO', '2021-07-22');

-- Popolamento della tabella SOLISTA
INSERT INTO SOLISTA (artista, codice_fiscale, nome, cognome, data_di_nascita, gruppo, data_adesione) VALUES
('SoloXYZ', 'RSSMRA85M01H501Z', 'Mario'     , 'Rossi'     , '1985-03-01',  NULL,        NULL),
('SoloABC', 'VCTFNC90A01H501X', 'Francesco' , 'Verdi'     , '1990-01-01',  'BandABC',   '2020-01-20'),
('SoloDEF', 'BNCLRA92D01H501Y', 'Laura'     , 'Bianchi'   , '1992-04-01',  'Group123',  '2018-12-05'),
('SoloPQR', 'RSSMNB85M01H501Z', 'Giovanni'  , 'Russo'     , '1987-07-10',  NULL,        NULL),
('SoloGHI', 'MRTPLN90A01H501X', 'Anna'      , 'Mariani'   , '1990-05-01',  'BandDEF',   '2020-03-15'),
('SoloJKL', 'CNCMRS92D01H501Y', 'Marco'     , 'Cannavaro' , '1992-08-01',  'GroupJKL',  '2019-04-15'),
('SoloSTU', 'FRTRLA89L01H501Z', 'Lucia'     , 'Ferrari'   , '1989-11-12',  'TrioUVW',   '2019-10-01');

-- Popolamento della tabella PARTECIPAZIONE_PASSATA
INSERT INTO PARTECIPAZIONE_PASSATA (gruppo, solista, data_adesione, data_fine_adesione) VALUES
('BandABC', 'SoloXYZ', '2020-01-20', '2021-01-20'),
('Group123', 'SoloDEF', '2018-12-05', '2020-01-10'),
('TrioUVW', 'SoloSTU', '2019-10-01', '2020-05-25');

-- Popolamento della tabella EMAIL_A
INSERT INTO EMAIL_A (email, artista) VALUES
('bandabc@example.com', 'BandABC'),
('soloxyz@example.com', 'SoloXYZ'),
('group123@example.com', 'Group123'),
('duolmn@example.com', 'DuoLMN'),
('solopqr@example.com', 'SoloPQR'),
('triouvw@example.com', 'TrioUVW'),
('banddef@example.com', 'BandDEF'),
('sologhi@example.com', 'SoloGHI'),
('groupjkl@example.com', 'GroupJKL'),
('duomno@example.com', 'DuoMNO');

-- Popolamento della tabella TELEFONO_A
INSERT INTO TELEFONO_A (numero, artista) VALUES
('1234567890', 'BandABC'),
('0987654321', 'SoloXYZ'),
('1122334455', 'Group123'),
('2233445566', 'DuoLMN'),
('3344556677', 'SoloPQR'),
('4455667788', 'TrioUVW'),
('5566778899', 'BandDEF'),
('6677889900', 'SoloGHI'),
('7788990011', 'GroupJKL'),
('8899001122', 'DuoMNO');

-- Popolamento della tabella TIPO_PRODUZIONE
INSERT INTO TIPO_PRODUZIONE (nome) VALUES
('Album'), ('Singolo'), ('EP');

-- Popolamento della tabella GENERE
INSERT INTO GENERE (nome) VALUES
('Rock'), ('Pop'), ('Jazz'), ('Classical'), ('Hip Hop'), ('Electronic');

-- Popolamento della tabella PRODUZIONE
-- Pubblicazione:   immutabile
-- Produzione:      ancora modificabile
INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
('Album 1'      , 'BandABC' , '2020-02-01', '2020-06-01', 'Pubblicazione'   , 'Album'   , 'Rock'),
('Singolo 1'    , 'SoloXYZ' , '2019-08-01', '2019-08-15', 'Produzione'      , 'Singolo' , 'Pop'),
('EP 1'         , 'Group123', '2018-12-01', '2019-01-01', 'Produzione'      , 'EP'      , 'Jazz'),
('Compilation 1', 'DuoLMN'  , '2021-03-01', '2021-04-01', 'Produzione'      , 'EP'      , 'Classical'),
('Album 2'      , 'SoloPQR' , '2017-06-01', '2017-10-01', 'Pubblicazione'   , 'Album'   , 'Hip Hop'),
('Singolo 2'    , 'TrioUVW' , '2019-10-10', '2019-10-20', 'Pubblicazione'   , 'Singolo' , 'Electronic'),
('EP 2'         , 'BandDEF' , '2020-04-01', '2020-05-01', 'Produzione'      , 'EP'      , 'Rock'),
('Album 3'      , 'SoloGHI' , '2018-07-01', '2018-11-01', 'Pubblicazione'   , 'Album'   , 'Pop'),
('Singolo 3'    , 'GroupJKL', '2019-05-01', '2019-05-15', 'Produzione'      , 'Singolo' , 'Jazz'),
('EP 3'         , 'DuoMNO'  , '2021-08-01', '2021-09-01', 'Produzione'      , 'EP'      , 'Classical');

-- Popolamento della tabella CANZONE
INSERT INTO CANZONE (titolo, produzione, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione) VALUES
('Canzone 1' , 9 , 'Testo della canzone 1' , '2020-02-10', 180, 'canzone1.mp3' , '/musica/bandabc'  , 'mp3'),
('Canzone 2' , 2 , 'Testo della canzone 2' , '2019-08-05', 210, 'canzone2.mp3' , '/musica/soloxyz'  , 'mp3'),
('Canzone 3' , 7 , 'Testo della canzone 3' , '2018-12-10', 240, 'canzone3.mp3' , '/musica/group123' , 'mp3'),
('Canzone 4' , 3 , 'Testo della canzone 4' , '2021-03-10', 200, 'canzone4.mp3' , '/musica/duolmn'   , 'mp3'),
('Canzone 5' , 4 , 'Testo della canzone 5' , '2017-07-01', 190, 'canzone5.mp3' , '/musica/solopqr'  , 'mp3'),
('Canzone 6' , 7 , 'Testo della canzone 6' , '2019-10-15', 220, 'canzone6.mp3' , '/musica/triouvw'  , 'mp3'),
('Canzone 7' , 4 , 'Testo della canzone 7' , '2020-04-05', 230, 'canzone7.mp3' , '/musica/banddef'  , 'mp3'),
('Canzone 8' , 7 , 'Testo della canzone 8' , '2018-07-15', 250, 'canzone8.mp3' , '/musica/sologhi'  , 'mp3'),
('Canzone 9' , 9 , 'Testo della canzone 9' , '2019-05-10', 260, 'canzone9.mp3' , '/musica/groupjkl' , 'mp3'),
('Canzone 10', 10, 'Testo della canzone 10', '2021-08-10', 270, 'canzone10.mp3', '/musica/duomno'   , 'mp3');

-- Popolamento della tabella PARTECIPAZIONE
INSERT INTO PARTECIPAZIONE (solista, canzone) VALUES
('SoloABC', 1),
('SoloXYZ', 8),
('SoloDEF', 3),
('SoloPQR', 4),
('SoloGHI', 5),
('SoloSTU', 6),
('SoloJKL', 7),
('SoloPQR', 8),
('SoloXYZ', 9),
('SoloABC', 10),
('SoloPQR', 5),
('SoloPQR', 6),
('SoloSTU', 7),
('SoloJKL', 8),
('SoloGHI', 2);

-- Popolamento della tabella PRODUTTORE
INSERT INTO PRODUTTORE (solista) VALUES
('SoloABC'), 
('SoloXYZ'), 
('SoloDEF'), 
('SoloPQR'), 
('SoloGHI');

-- Popolamento della tabella CONDURRE
INSERT INTO CONDURRE (produttore, produzione) VALUES
('SoloABC', 1), ('SoloXYZ', 2), ('SoloDEF', 3), ('SoloPQR', 4), ('SoloGHI', 5);

-- Popolamento della tabella OPERATORE
INSERT INTO OPERATORE (codice_fiscale, nome, cognome, data_di_nascita, data_di_assunzione, iban) VALUES
('OPRXYZ85M01H501Z', 'Marco', 'Neri', '1985-03-01', '2010-01-01', 'IT60X0542811101000000123456'),
('OPRABC90A01H501X', 'Giulia', 'Rossi', '1990-01-01', '2015-01-01', 'IT60X0542811101000000654321'),
('OPRPQR85M01H501Z', 'Luca', 'Bianchi', '1985-06-15', '2012-03-01', 'IT60X0542811101000000789101'),
('OPRDEF90A01H501X', 'Elena', 'Verdi', '1990-11-20', '2017-05-15', 'IT60X0542811101000000432198'),
('OPRGHI85M01H501Z', 'Chiara', 'Russo', '1985-09-25', '2013-08-20', 'IT60X0542811101000000543210');

-- Popolamento della tabella EMAIL_O
INSERT INTO EMAIL_O (email, operatore) VALUES
('marconeri@example.com', 'OPRXYZ85M01H501Z'),
('giuliarossi@example.com', 'OPRABC90A01H501X'),
('lucabianchi@example.com', 'OPRPQR85M01H501Z'),
('elenaverdi@example.com', 'OPRDEF90A01H501X'),
('chiararusso@example.com', 'OPRGHI85M01H501Z');

-- Popolamento della tabella TELEFONO_O
INSERT INTO TELEFONO_O (numero, operatore) VALUES
('3331234567', 'OPRXYZ85M01H501Z'),
('3347654321', 'OPRABC90A01H501X'),
('3358765432', 'OPRPQR85M01H501Z'),
('3369876543', 'OPRDEF90A01H501X'),
('3379988776', 'OPRGHI85M01H501Z');

-- Popolamento della tabella ORDINE
INSERT INTO ORDINE (timestamp, artista, annullato, operatore) VALUES
('2023-01-01 10:00:00', 'BandABC', FALSE, 'OPRXYZ85M01H501Z'),
('2023-01-02 11:00:00', 'SoloXYZ', FALSE, 'OPRABC90A01H501X'),
('2023-01-03 12:00:00', 'Group123', FALSE, 'OPRPQR85M01H501Z'),
('2023-01-04 13:00:00', 'DuoLMN', FALSE, 'OPRDEF90A01H501X'),
('2023-01-05 14:00:00', 'SoloPQR', FALSE, 'OPRGHI85M01H501Z'),
('2023-01-06 15:00:00', 'TrioUVW', FALSE, 'OPRXYZ85M01H501Z'),
('2023-01-07 16:00:00', 'BandDEF', FALSE, 'OPRABC90A01H501X'),
('2023-01-08 17:00:00', 'SoloGHI', FALSE, 'OPRPQR85M01H501Z'),
('2023-01-09 18:00:00', 'GroupJKL', FALSE, 'OPRDEF90A01H501X'),
('2023-01-10 19:00:00', 'DuoMNO', FALSE, 'OPRGHI85M01H501Z');

-- Popolamento della tabella METODO
INSERT INTO METODO (nome) VALUES
('Carta di Credito'), ('PayPal'), ('Bonifico Bancario'), ('Contanti');

-- Popolamento della tabella PAGAMENTO
INSERT INTO PAGAMENTO (ordine, stato, costo_totale, metodo) VALUES
(1, 'Pagato', 150.00, 'Carta di Credito'),
(2, 'Da pagare', 200.00, NULL),
(3, 'Pagato', 250.00, 'Bonifico Bancario'),
(4, 'Da pagare', 300.00, NULL),
(5, 'Pagato', 350.00, 'Carta di Credito'),
(6, 'Pagato', 400.00, 'PayPal'),
(7, 'Da pagare', 450.00, NULL),
(8, 'Pagato', 500.00, 'Contanti'),
(9, 'Pagato', 550.00, 'Carta di Credito'),
(10, 'Pagato', 600.00, 'PayPal');

-- Popolamento della tabella TIPOLOGIA
INSERT INTO TIPOLOGIA (nome, valore, n_giorni) VALUES
('Giornaliera', 200.00, 1),
('Settimanale', 1200.00, 7), 
('Mensile', 4000.00, 30);

-- Popolamento della tabella PACCHETTO
INSERT INTO PACCHETTO (ordine, tipologia, n_giorni_prenotati_totali) VALUES
(1, 'Giornaliera', 0),
(2, 'Settimanale', 0),
(3, 'Settimanale', 0),
(4, 'Giornaliera', 0),
(5, 'Mensile', 0);

-- Popolamento della tabella ORARIO
INSERT INTO ORARIO (ordine, n_ore_prenotate_totali, valore) VALUES
(6, 20, 15),
(7, 30, 15),
(8, 40, 15),
(9, 10, 15),
(10, 20, 15);

-- Popolamento della tabella SALA
INSERT INTO SALA (piano, numero) VALUES
(1, 1), (1, 2), 
(2, 1), (2, 2), 
(3, 1), (3, 2);

-- Popolamento della tabella PRENOTAZIONE
-- PRENOTAZIONE PACCHETTO:  tipo=TRUE
-- PRENOTAZIONE ORARIA:     tipo=FALSE
INSERT INTO PRENOTAZIONE (annullata, giorno, tipo, pacchetto, sala_piano, sala_numero) VALUES
(FALSE, '2023-01-10', TRUE, 1, 1, 1),
(FALSE, '2023-01-15', TRUE, 2, 2, 1),
(FALSE, '2023-01-20', TRUE, 3, 3, 2),
(FALSE, '2023-01-25', TRUE, 4, 3, 1),
(FALSE, '2023-01-30', TRUE, 5, 1, 2),

(FALSE, '2023-02-04', FALSE, NULL, 1, 1), 
(FALSE, '2023-02-09', FALSE, NULL, 2, 1),
(FALSE, '2023-02-14', FALSE, NULL, 3, 2),
(FALSE, '2023-02-19', FALSE, NULL, 2, 2),
(FALSE, '2023-02-24', FALSE, NULL, 2, 1);

-- Le ultime 5 prenotazioni sono orarie
INSERT INTO ORARIA (prenotazione, orario) VALUES 
(6, 6), 
(7, 7), 
(8, 8), 
(9, 9), 
(10, 10);

INSERT INTO FASCIA_ORARIA (oraria, orario_inizio, orario_fine) VALUES 
(6, '09:00:00', '12:00:00'), 
(6, '14:00:00', '17:00:00'),
(7, '08:00:00', '11:00:00'),
(8, '18:00:00', '22:00:00'),
(9, '17:00:00', '23:00:00'),
(9, '09:00:00', '11:00:00'),
(10, '14:00:00', '18:00:00');

INSERT INTO TIPO_TECNICO (nome) VALUES 
('Fonico'), 
('Tecnico del Suono'),
('Tecnico del Suono_AND_Fonico');

-- Popolamento della tabella TECNICO
INSERT INTO TECNICO (codice_fiscale, sala_piano, sala_numero, tipo_tecnico, nome, cognome, data_di_nascita, data_di_assunzione, iban) VALUES
('TCNAUD85M01H501Z', 1, 1, 'Fonico', 'Luca', 'Verdi', '1985-03-01', '2010-01-01', 'IT60X0542811101000000123456'),
('TCNPRO90A01H501X', 2, 2, 'Tecnico del Suono', 'Sara', 'Bianchi', '1990-01-01', '2015-01-01', 'IT60X0542811101000000654321'),
('TCNAUD92D01H501Y', 2, 1, 'Fonico', 'Giovanni', 'Russo', '1992-04-01', '2012-02-01', 'IT60X0542811101000000765432'),
('TCNPRO88M01H501Z', 3, 1, 'Fonico', 'Marco', 'Neri', '1988-05-15', '2013-05-01', 'IT60X0542811101000000543210'),
('TCNAUD90A01H501X', 3, 2, 'Tecnico del Suono', 'Elena', 'Verdi', '1990-11-20', '2016-03-01', 'IT60X0542811101000000987654');

-- Popolamento della tabella EMAIL_T
INSERT INTO EMAIL_T (email, tecnico) VALUES
('lucaverdi@example.com', 'TCNAUD85M01H501Z'),
('sarabianchi@example.com', 'TCNPRO90A01H501X'),
('giovannirusso@example.com', 'TCNAUD92D01H501Y'),
('marconeri@example.com', 'TCNPRO88M01H501Z'),
('elenaverdi@example.com', 'TCNAUD90A01H501X');

-- Popolamento della tabella TELEFONO_T
INSERT INTO TELEFONO_T (numero, tecnico) VALUES
('3331122334', 'TCNAUD85M01H501Z'),
('3344455667', 'TCNPRO90A01H501X'),
('3355544333', 'TCNAUD92D01H501Y'),
('3366677889', 'TCNPRO88M01H501Z'),
('3377788990', 'TCNAUD90A01H501X');

-- Popolamento della tabella LAVORA_A
INSERT INTO LAVORA_A (tecnico, canzone) VALUES
('TCNAUD85M01H501Z', 1),
('TCNPRO90A01H501X', 2),
('TCNAUD92D01H501Y', 3),
('TCNPRO88M01H501Z', 4),
('TCNAUD90A01H501X', 5),
('TCNAUD85M01H501Z', 6),
('TCNPRO90A01H501X', 7),
('TCNAUD92D01H501Y', 8),
('TCNPRO88M01H501Z', 9),
('TCNAUD90A01H501X', 10);""")

def insert_artista():
    nome_arte = fake.unique.name()
    data_di_registrazione = fake.date_this_decade()
    cursor.execute(
        """
        INSERT INTO ARTISTA (nome_arte, data_di_registrazione)
        VALUES (%s, %s)
        RETURNING nome_arte
        """,
        (nome_arte, data_di_registrazione)
    )
    return cursor.fetchone()[0]

def insert_gruppo(artista):
    data_formazione = fake.date_this_decade()
    cursor.execute(
        """
        INSERT INTO GRUPPO (artista, data_formazione)
        VALUES (%s, %s)
        """,
        (artista, data_formazione)
    )
 
    return cursor.fetchone()[0]

def insert_solista(artista):
    codice_fiscale = fake.unique.ssn()
    nome = fake.first_name()
    cognome = fake.last_name()
    data_di_nascita = fake.date_of_birth(minimum_age=18, maximum_age=90)
    gruppo = random.choice([None, insert_gruppo(artista)])  # Lascia NULL per alcuni record
    data_adesione = fake.date_this_decade() if gruppo else None
    cursor.execute(
        """
        INSERT INTO SOLISTA (artista, codice_fiscale, nome, cognome, data_di_nascita, gruppo, data_adesione)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        RETURNING codice_fiscale
        """,
        (artista, codice_fiscale, nome, cognome, data_di_nascita, gruppo, data_adesione)
    )
    return cursor.fetchone()[0]

def insert_partecipazione_passata(gruppo, solista):
    data_adesione = fake.date_this_decade()
    data_fine_adesione = fake.date_between(start_date=data_adesione, end_date='today')
    cursor.execute(
        """
        INSERT INTO PARTECIPAZIONE_PASSATA (gruppo, solista, data_adesione, data_fine_adesione)
        VALUES (%s, %s, %s, %s)
        """,
        (gruppo, solista, data_adesione, data_fine_adesione)
    )

def insert_email_a(artista):
    email = fake.email()
    cursor.execute(
        """
        INSERT INTO EMAIL_A (email, artista)
        VALUES (%s, %s)
        """,
        (email, artista)
    )

def insert_telefono_a(artista):
    numero = fake.phone_number()
    cursor.execute(
        """
        INSERT INTO TELEFONO_A (numero, artista)
        VALUES (%s, %s)
        """,
        (numero, artista)
    )

# Funzione per inserire un tipo di produzione
def insert_tipo_produzione():
    # Scelte possibili per il campo 'nome' nella tabella TIPO_PRODUZIONE
    choices = ['Album', 'Singolo', 'EP']
    
    # Esegui la scelta casuale
    nome = random.choice(choices)
    
    cursor.execute(
        """
        INSERT INTO TIPO_PRODUZIONE (nome)
        VALUES (%s)
        RETURNING nome
        """,
        (nome,)
    )
    conn.commit()
    
    return cursor.fetchone()[0]
def insert_genere():
    generi = ['Rock', 'Pop', 'Jazz', 'Classical', 'Hip Hop', 'Electronic']
    nome = random.choice(generi)
    cursor.execute(
        """
        INSERT INTO GENERE (nome)
        VALUES (%s)
        RETURNING nome
        """,
        (nome,)
    )
    return cursor.fetchone()[0]

def insert_produzione(artista, tipo):
    titolo = fake.sentence(nb_words=3)
    data_inizio = fake.date_this_decade()
    data_fine = fake.date_between(start_date=data_inizio, end_date='today')
    stato = random.choice(['Pubblicato', 'Pubblicazione'])
    tipo_produzione = tipo
    genere = insert_genere()
    cursor.execute(
        """
        INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        RETURNING titolo
        """,
        (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere)
    )
    return cursor.fetchone()[0]

def insert_canzone(produzione):
    titolo = fake.sentence(nb_words=4)
    testo = fake.text()
    data_di_registrazione = fake.date_this_decade()
    lunghezza_in_secondi = random.randint(180, 300)
    nome_del_file = fake.file_name()
    percorso_di_sistema = fake.file_path()
    estensione = fake.file_extension()
    cursor.execute(
        """
        INSERT INTO CANZONE (titolo, produzione, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING titolo
        """,
        (titolo, produzione, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione)
    )
    return cursor.fetchone()[0]

def insert_partecipazione(solista, canzone):
    cursor.execute(
        """
        INSERT INTO PARTECIPAZIONE (solista, canzone)
        VALUES (%s, %s, %s)
        """,
        (solista, canzone)
    )

def insert_produttore(solista):
    cursor.execute(
        """
        INSERT INTO PRODUTTORE (solista)
        VALUES (%s)
        RETURNING solista
        """,
        (solista,)
    )
    return cursor.fetchone()[0]

def insert_condurre(produttore, produzione):
    cursor.execute(
        """
        INSERT INTO CONDURRE (produttore, produzione)
        VALUES (%s, %s)
        """,
        (produttore, produzione)
    )

def insert_operatore():
    codice_fiscale = fake.unique.ssn()
    nome = fake.first_name()
    cognome = fake.last_name()
    data_di_nascita = fake.date_of_birth(minimum_age=18, maximum_age=90)
    data_di_assunzione = fake.date_this_decade()
    iban = fake.iban()
    cursor.execute(
        """
        INSERT INTO OPERATORE (codice_fiscale, nome, cognome, data_di_nascita, data_di_assunzione, iban)
        VALUES (%s, %s, %s, %s, %s, %s)
        RETURNING codice_fiscale
        """,
        (codice_fiscale, nome, cognome, data_di_nascita, data_di_assunzione, iban)
    )
    return cursor.fetchone()[0]

def insert_email_o(operatore):
    email = fake.email()
    cursor.execute(
        """
        INSERT INTO EMAIL_O (email, operatore)
        VALUES (%s, %s)
        """,
        (email, operatore)
    )

def insert_telefono_o(operatore):
    numero = fake.phone_number()
    cursor.execute(
        """
        INSERT INTO TELEFONO_O (numero, operatore)
        VALUES (%s, %s)
        """,
        (numero, operatore)
    )

def insert_ordine(artista, operatore):
    timestamp = fake.date_time_this_decade()
    annullato = random.choice([True, False])
    cursor.execute(
        """
        INSERT INTO ORDINE (timestamp, artista, annullato, operatore)
        VALUES (%s, %s, %s, %s)
        RETURNING timestamp
        """,
        (timestamp, artista, annullato, operatore)
    )
    return cursor.fetchone()[0]

def insert_metodo():
    metodi_pagamento = ['Carta di Credito', 'PayPal', 'Bonifico Bancario', 'Contanti']
    nome = random.choice(metodi_pagamento)
    cursor.execute(
        """
        INSERT INTO METODO (nome)
        VALUES (%s)
        RETURNING nome
        """,
        (nome,)
    )
    return cursor.fetchone()[0]

def insert_pagamento(ordine):
    stato = random.choice(['Pagato', 'Da pagare'])
    costo_totale = 0
    metodo = insert_metodo()
    cursor.execute(
        """
        INSERT INTO PAGAMENTO (ordine, stato, costo_totale, metodo)
        VALUES (%s, %s, %s, %s)
        """,
        (ordine, stato, costo_totale, metodo)
    )
# Funzione per inserire le tipologie nel database e restituire il nome della tipologia inserita
def insert_tipologia(i):
    # Lista delle tipologie da inserire
    tipologie = [
        ('Giornaliero', 160.00, 1),
        ('Settimanale', 600.00, 7),
        ('Mensile', 2200.00, 30)
    ]
    
    cursor.execute(
        """
        INSERT INTO TIPOLOGIA (nome, valore, n_giorni)
        VALUES (%s, %s, %s)
        RETURNING nome
        """,
        (tipologie[i][0], tipologie[i][1], tipologie[i][2])
    )
    conn.commit()

def insert_pacchetto(ordine):
    tipologia = insert_tipologia()
    n_giorni_prenotati_totali = 0
    cursor.execute(
        """
        INSERT INTO PACCHETTO (ordine, tipologia, n_giorni_prenotati_totali)
        VALUES (%s, %s, %s)
        """,
        (ordine, tipologia, n_giorni_prenotati_totali)
    )

def insert_orario(ordine):
    n_ore_prenotate_totali = 0
    valore = round(random.uniform(20, 30), 2)
    cursor.execute(
        """
        INSERT INTO ORARIO (ordine, n_ore_prenotate_totali, valore)
        VALUES (%s, %s, %s)
        """,
        (ordine, n_ore_prenotate_totali, valore)
    )

def insert_sala(piano):
    piano = piano
    numero = random.randint(1, 10)
    cursor.execute(
        """
        INSERT INTO SALA (piano, numero)
        VALUES (%s, %s)
        RETURNING piano, numero
        """,
        (piano, numero)
    )
    return cursor.fetchone()

def insert_prenotazione(pacchetto, sala):
    annullata = random.choice([True, False])
    giorno = fake.date_this_year()
    if pacchetto is None:
        tipo = 0
    else:
        tipo = 1
    cursor.execute(
        """
        INSERT INTO PRENOTAZIONE (annullata, giorno, tipo, pacchetto, sala_piano, sala_numero)
        VALUES (%s, %s, %s, %s, %s, %s)
        """,
        (annullata, giorno, tipo, pacchetto, sala[0], sala[1])
    )

def insert_oraria(prenotazione, orario):
    cursor.execute(
        """
        INSERT INTO ORARIA (prenotazione, orario)
        VALUES (%s, %s)
        """,
        (prenotazione, orario)
    )

def insert_fascia_oraria(oraria):
    orario_inizio = fake.time()
    orario_fine = fake.time()
    cursor.execute(
        """
        INSERT INTO FASCIA_ORARIA (oraria, orario_inizio, orario_fine)
        VALUES (%s, %s, %s)
        """,
        (oraria, orario_inizio, orario_fine)
    )


def insert_tipo_tecnico():
    # Scelte possibili per il campo 'nome' nella tabella TIPO_TECNICO
    tipi = ['Fonico', 'Tecnico del Suono', 'Tecnico del Suono_AND_Fonico']

    for tipo in tipi:
        cursor.execute(
            """
            INSERT INTO TIPO_TECNICO (nome)
            VALUES (%s)
            RETURNING nome
            """,
            (tipo,)
        )
        tipo_inserito = cursor.fetchone()[0]


def insert_tecnico(sala):
    codice_fiscale = fake.unique.ssn()
    tipo_tecnico = 'Fonico' #random.choice(choices)  choices = ['Fonico', 'Tecnico del Suono', 'Tecnico del Suono_AND_Fonico']
    nome = fake.first_name()
    cognome = fake.last_name()
    data_di_nascita = fake.date_of_birth(minimum_age=18, maximum_age=90)
    data_di_assunzione = fake.date_this_decade()
    iban = fake.iban()
    cursor.execute(
        """
        INSERT INTO TECNICO (codice_fiscale, sala_piano, sala_numero, tipo_tecnico, nome, cognome, data_di_nascita, data_di_assunzione, iban)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING codice_fiscale
        """,
        (codice_fiscale, sala[0], sala[1], tipo_tecnico, nome, cognome, data_di_nascita, data_di_assunzione, iban)
    )
    return cursor.fetchone()[0]

def insert_email_t(tecnico):
    email = fake.email()
    cursor.execute(
        """
        INSERT INTO EMAIL_T (email, tecnico)
        VALUES (%s, %s)
        """,
        (email, tecnico)
    )


def insert_telefono_t(tecnico):
    numero = fake.phone_number()
    cursor.execute(
        """
        INSERT INTO TELEFONO_T (numero, tecnico)
        VALUES (%s, %s)
        """,
        (numero, tecnico)
    )

def insert_lavora_a(tecnico_id, canzone_id):
    cursor.execute(
        """
        INSERT INTO LAVORA_A (tecnico, canzone)
        VALUES (%s, %s)
        """,
        (tecnico_id, canzone_id)
    )
    return cursor.rowcount  # Restituisce il numero di righe inserite

# Esempio di popolamento del database mantenendo i vincoli di integrità referenziali
# Esegui la pulizia del database
initialize_tables()
#clean_database()
#initialize()
'''

# Array per tenere traccia delle chiavi primarie
sale = []
tecnici = []
tipologie = []
prenotazioni = []
produzioni = []
singoli = []
ep = []
album = []
artisti = []
solisti = []
gruppi = []
canzoni = []
produttori = []
ordini = []
pacchetti = []
giornaliere = []
orari = []
orarie = []
fasce_orarie = []

# Funzioni per il popolamento delle tabelle (già definite sopra)
# ...

# SALA: 41
for i in range(4):
    sala_id = insert_sala(i)
    sale.append(sala_id)

insert_tipo_tecnico()

# TECNICO: 6 (associazione tra tecnico e sala)
for sala_id in sale:
    for _ in range(1):  # ogni sala ha 1 tecnico
        tecnico_id = insert_tecnico(sala_id)
        tecnici.append(tecnico_id)

# TIPOLOGIA: 4
d=0
for _ in range(3):
    tipologia_id = insert_tipologia(d) #0,1,2
    tipologie.append(tipologia_id)
    d = d+1

# ARTISTA: 224
for _ in range(224):
    artista_id = insert_artista()
    artisti.append(artista_id)

# SOLISTA: 194
for artista_id in artisti[:194]:
    solista_id = insert_solista(artista_id)
    solisti.append(solista_id)

# PRODUTTORE: 56
for artista_id in artisti[:56]:
    produttore_id = insert_produttore(artista_id)
    produttori.append(produttore_id)

# GRUPPO: 30
#for artista_id in artisti[:30]:
#    gruppo_id = insert_gruppo(artista_id)
#    gruppi.append(gruppo_id)

# CANZONE: 256
for _ in range(256):
    canzone_id = insert_canzone(random.choice(produzioni))
    canzoni.append(canzone_id)

# PRODUZIONE: 84 (associazione tra artista e produzione)
c = 0
c = 0
for artista_id in artisti:
    if c < 60:
        produzione_id = insert_produzione(artista_id, 'Singolo')
        produzioni.append(produzione_id)
    elif c >= 60 and c < 74:
        produzione_id = insert_produzione(artista_id, 'EP')
        produzioni.append(produzione_id)
    else:
        produzione_id = insert_produzione(artista_id, 'Album')
        produzioni.append(produzione_id)

    for _ in range(3):  # Supponiamo 3 canzoni per produzione
        canzone_id = insert_canzone(produzione_id)
        canzoni.append(canzone_id)
        solista_id = random.choice(solisti)
        insert_partecipazione(solista_id, canzone_id)
    c += 1
        
# PARTECIPAZIONE: 96 (associazione tra canzone e solista)
for _ in range(96):
    insert_partecipazione(random.choice(solisti), random.choice(canzoni))

# CONDURRE: 90 (associazione tra produttore e produzione)
for _ in range(90):
    insert_condurre(random.choice(produttori), random.choice(produzioni))

# PRENOTAZIONE: 506 (associazione tra ordine e sala)
for ordine_id in ordini:
    for _ in range(506 // len(ordini)):
        prenotazione_id = insert_prenotazione(ordine_id, random.choice(sale))
        prenotazioni.append(prenotazione_id)

# ORDINE: 324
for _ in range(324):
    ordine_id = insert_ordine(random.choice(artisti), random.choice([1, 2]))
    ordini.append(ordine_id)

# PAGAMENTO: 324
for ordine_id in ordini:
    insert_pagamento(ordine_id)

# Genera PACCHETTO: 124
for i in range(124):
    ordine_id = ordini[i] 
    pacchetto_id = insert_pacchetto(ordine_id)
    pacchetti.append(pacchetto_id)

# ATTREZZATURA: 37
#for _ in range(37):
#    attrezzatura_id = insert_attrezzatura()
#    attrezzature.append(attrezzatura_id)

# GIORNALIERA: 306
for _ in range(306):
    giornaliera_id = insert_prenotazione(True, random.choice(sale))
    giornaliere.append(giornaliera_id)

# Genera ORARIO: 200
for i in range(124, 324):
    ordine_id = ordini[i]
    orario_id = insert_orario(ordine_id)
    orari.append(orario_id)


# ORARIA: 200
for i in range(200):
    oraria_id = insert_oraria(orari[i])
    orarie.append(oraria_id)

# FASCIA ORARIA: 360
for _ in range(360):
    fascia_oraria_id = insert_fascia_oraria()
    fasce_orarie.append(fascia_oraria_id)

# EMAIL_A: 224
for artista_id in artisti:
    insert_email_a(artista_id)

# TELEFONO_A: 240
for artista_id in artisti:
    insert_telefono_a(artista_id)

# EMAIL_O: 2
for operatore_id in range(1, 3):  # supponendo 2 operatori
    insert_email_o(operatore_id)

# TELEFONO_O: 2
for operatore_id in range(1, 3):  # supponendo 2 operatori
    insert_telefono_o(operatore_id)

# EMAIL_T: 6
for tecnico_id in tecnici:
    insert_email_t(tecnico_id)

# TELEFONO_T: 8
for tecnico_id in tecnici:
    insert_telefono_t(tecnico_id)
'''
# Effettuazione (associazione tra tecnico e canzone)
'''
---
for _ in range(324):
    insert_effettuazione(random.choice(tecnici), random.choice(canzoni))

# Assegnazione (associazione tra tecnico e sala)
for sala_id in sale:
    for _ in range(1):  # ogni sala ha 1 tecnico
        tecnico_id = insert_tecnico(sala_id)
        insert_assegnazione(tecnico_id, sala_id)

# Composizione (associazione tra artista e produzione)
for artista_id in artisti:
    produzione_id = random.choice(produzioni)
    insert_composizione(artista_id, produzione_id)
    --
'''
'''
# Partecipazione Passata (associazione tra solista e gruppo)
for _ in range(16):
    gruppo_id = random.choice(gruppi)
    solista_id = random.choice(solisti)
    insert_partecipazione_passata(solista_id, gruppo_id)
'''

'''
--
# Partecipazione Corrente (associazione tra gruppo e solista)
for _ in range(120):
    gruppo_id = random.choice(gruppi)
    solista_id = random.choice(solisti)
    insert_partecipazione_corrente(solista_id, gruppo_id)

# Raccolta di (associazione tra produzione e canzone)
for produzione_id in produzioni:
    for _ in range(3):  # supponiamo 3 canzoni per produzione
        canzone_id = insert_canzone(produzione_id)
        insert_raccolta_di(produzione_id, canzone_id)
    ---
'''

'''
# Lavora a (associazione tra tecnico e canzone)
for _ in range(306):
    insert_lavora_a(random.choice(tecnici), random.choice(canzoni))
'''


# Commit delle operazioni
conn.commit()

# Chiusura della connessione
cursor.close()
conn.close()

