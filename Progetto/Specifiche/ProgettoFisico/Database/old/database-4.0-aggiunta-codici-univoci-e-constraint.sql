CREATE TABLE ARTISTA (
    nome_arte VARCHAR(255) PRIMARY KEY,
    data_di_registrazione DATE
); 
 
CREATE TABLE GRUPPO ( 
    artista VARCHAR(255), 
    data_formazione DATE, 
    PRIMARY KEY (artista), 
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte) 
); 
 
CREATE TABLE SOLISTA ( 
    artista VARCHAR(255), 
    codice_fiscale VARCHAR(16) UNIQUE, 
    nome VARCHAR(255), 
    cognome VARCHAR(255), 
    data_di_nascita DATE, 
    gruppo VARCHAR(255), 
    data_adesione DATE, 
    PRIMARY KEY (artista), 
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte), 
    FOREIGN KEY (gruppo) REFERENCES GRUPPO(artista) 
); 
 
CREATE TABLE PARTECIPAZIONE_PASSATA ( 
    gruppo VARCHAR(255), 
    solista VARCHAR(255), 
    data_adesione DATE, 
    data_fine_adesione DATE, 
    PRIMARY KEY (gruppo, solista), 
    FOREIGN KEY (gruppo) REFERENCES GRUPPO(artista), 
    FOREIGN KEY (solista) REFERENCES SOLISTA(artista) 
); 
 
CREATE TABLE EMAIL_A ( 
    email VARCHAR(255), 
    artista VARCHAR(255), 
    PRIMARY KEY (email), 
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte) 
); 
 
CREATE TABLE TELEFONO_A ( 
    numero VARCHAR(15), 
    artista VARCHAR(255), 
    PRIMARY KEY (numero), 
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte) 
); 
 
CREATE TABLE TIPO_PRODUZIONE ( 
    nome VARCHAR(255) PRIMARY KEY 
); 

CREATE TABLE GENERE ( 
    nome VARCHAR(255) PRIMARY KEY 
); 
 
CREATE TABLE PRODUZIONE ( 
    -- Unique code
    codice SERIAL PRIMARY KEY,

    -- Old Primary Key
    titolo VARCHAR(255),
    artista VARCHAR(255),

    -- Old Primary Key Uniqueness Maintained
    CONSTRAINT unique_produzione UNIQUE (titolo, artista),
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte),

    -- Other
    data_inizio DATE, 
    data_fine DATE, 
    stato VARCHAR(50), 
    tipo_produzione VARCHAR(255), 
    genere VARCHAR(255), 
    FOREIGN KEY (tipo_produzione) REFERENCES TIPO_PRODUZIONE(nome),
    FOREIGN KEY (genere) REFERENCES GENERE(nome) 
); 
 
CREATE TABLE CANZONE (
    -- Unique code
    codice SERIAL PRIMARY KEY,

    -- Old Primary Key
    titolo VARCHAR(255), 
    produzione INTEGER,

    -- Old Primary Key Uniqueness Maintained
    CONSTRAINT unique_canzone UNIQUE (titolo, produzione),
    FOREIGN KEY (produzione) REFERENCES PRODUZIONE(codice),

    -- Other
    testo TEXT, 
    data_di_registrazione DATE, 
    lunghezza_in_secondi INTEGER, 
    nome_del_file VARCHAR(255), 
    percorso_di_sistema VARCHAR(255), 
    estensione VARCHAR(10)
); 

CREATE TABLE PARTECIPAZIONE ( 
    -- Unique code
    codice SERIAL PRIMARY KEY,

    -- Old Primary Key
    solista VARCHAR(255), 
    canzone INTEGER,

    -- Old Primary Key Uniqueness Maintained
    CONSTRAINT unique_partecipazione UNIQUE (solista, canzone),
    FOREIGN KEY (solista) REFERENCES SOLISTA(artista), 
    FOREIGN KEY (canzone) REFERENCES CANZONE(codice)
); 
 
CREATE TABLE PRODUTTORE ( 
    solista VARCHAR(255) PRIMARY KEY, 
    FOREIGN KEY (solista) REFERENCES SOLISTA(artista)
); 
 
CREATE TABLE CONDURRE ( 
    produttore VARCHAR(255), 
    produzione INTEGER, 
    PRIMARY KEY (produttore, produzione), 
    FOREIGN KEY (produttore) REFERENCES PRODUTTORE(solista), 
    FOREIGN KEY (produzione) REFERENCES PRODUZIONE(codice)
); 
 
CREATE TABLE OPERATORE ( 
    codice_fiscale VARCHAR(16) PRIMARY KEY, 
    nome VARCHAR(255), 
    cognome VARCHAR(255), 
    data_di_nascita DATE, 
    data_di_assunzione DATE, 
    iban VARCHAR(34) 
); 
 
CREATE TABLE EMAIL_O ( 
    email VARCHAR(255), 
    operatore VARCHAR(16), 
    PRIMARY KEY (email), 
    FOREIGN KEY (operatore) REFERENCES OPERATORE(codice_fiscale) 
); 
 
CREATE TABLE TELEFONO_O ( 
    numero VARCHAR(15), 
    operatore VARCHAR(16), 
    PRIMARY KEY (numero), 
    FOREIGN KEY (operatore) REFERENCES OPERATORE(codice_fiscale) 
); 
 
CREATE TABLE ORDINE ( 
    -- Unique code
    codice SERIAL PRIMARY KEY,

    -- Old Primary Key
    timestamp TIMESTAMP, 
    artista VARCHAR(255),

    -- Old Primary Key Uniqueness Maintained
    CONSTRAINT unique_ordine UNIQUE (timestamp, artista), 
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte),

    -- Other
    annullato BOOLEAN,
    operatore VARCHAR(16),
    FOREIGN KEY (operatore) REFERENCES OPERATORE(codice_fiscale) 
); 
 
CREATE TABLE METODO ( 
    nome VARCHAR(255) PRIMARY KEY 
); 
 
CREATE TABLE PAGAMENTO (

    ordine INTEGER PRIMARY KEY,
    FOREIGN KEY (ordine) REFERENCES ORDINE(codice), 

    -- Other
    stato VARCHAR(50), 
    costo_totale DECIMAL(10, 2), 
    metodo VARCHAR(255), 
    FOREIGN KEY (metodo) REFERENCES METODO(nome) 
); 
 
CREATE TABLE TIPOLOGIA ( 
    nome VARCHAR(255), 
    valore DECIMAL(10, 2), 
    n_giorni INTEGER, 
    PRIMARY KEY (nome) 
); 
 
CREATE TABLE PACCHETTO ( 
    ordine INTEGER PRIMARY KEY,
    FOREIGN KEY (ordine) REFERENCES ORDINE(codice),

    tipologia VARCHAR(255),
    FOREIGN KEY (tipologia) REFERENCES TIPOLOGIA(nome),

    -- Other
    n_giorni_prenotati_totali INTEGER
); 
 
CREATE TABLE ORARIO ( 
    ordine INTEGER PRIMARY KEY,
    FOREIGN KEY (ordine) REFERENCES ORDINE(codice),
    
    n_ore_prenotate_totali INTEGER, 
    valore DECIMAL(10, 2)
    
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
    annullata BOOLEAN, 
    giorno DATE, 
    tipo BOOLEAN, 
    pacchetto INTEGER, 
    sala_piano INTEGER, 
    sala_numero INTEGER,
    FOREIGN KEY (pacchetto) REFERENCES PACCHETTO(codice), 
    FOREIGN KEY (sala_piano, sala_numero) REFERENCES SALA(piano, numero) 
); 
 
CREATE TABLE ORARIA ( 
    prenotazione INTEGER PRIMARY KEY, 
    FOREIGN KEY (prenotazione) REFERENCES PRENOTAZIONE(codice),

    -- one to one
    orario INTEGER REFERENCES ORARIO(ordine) UNIQUE NOT NULL
); 
 
CREATE TABLE FASCIA_ORARIA ( 
    oraria INTEGER, 
    orario_inizio TIME, 
    orario_fine TIME, 
    PRIMARY KEY (oraria, orario_inizio), 
    FOREIGN KEY (oraria) REFERENCES ORARIA(prenotazione) 
); 
 
-- Creazione della tabella TIPO_TECNICO
CREATE TABLE TIPO_TECNICO (
    nome VARCHAR(255) PRIMARY KEY
); 
 
-- Creazione della tabella TECNICO
CREATE TABLE TECNICO (
    codice_fiscale CHAR(16) PRIMARY KEY,
    sala_piano INT,
    sala_numero INT,
    tipo_tecnico VARCHAR(255),
    nome VARCHAR(255),
    cognome VARCHAR(255),
    data_di_nascita DATE,
    data_di_assunzione DATE,
    iban VARCHAR(27),
    FOREIGN KEY (sala_piano, sala_numero) REFERENCES SALA(piano, numero),
    FOREIGN KEY (tipo_tecnico) REFERENCES TIPO_TECNICO(nome)
); 
 
-- Creazione della tabella EMAIL_T
CREATE TABLE EMAIL_T (
    email VARCHAR(255) PRIMARY KEY,
    tecnico CHAR(16),
    FOREIGN KEY (tecnico) REFERENCES TECNICO(codice_fiscale)
); 
 
-- Creazione della tabella TELEFONO_T
CREATE TABLE TELEFONO_T (
    numero VARCHAR(15) PRIMARY KEY,
    tecnico CHAR(16),
    FOREIGN KEY (tecnico) REFERENCES TECNICO(codice_fiscale)
); 
 
-- Creazione della tabella LAVORA_A
CREATE TABLE LAVORA_A (
    tecnico CHAR(16),
    canzone INTEGER,
    PRIMARY KEY (tecnico, canzone),
    FOREIGN KEY (tecnico) REFERENCES TECNICO(codice_fiscale),
    FOREIGN KEY (canzone) REFERENCES CANZONE(codice)
); 
 