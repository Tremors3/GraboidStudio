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
    CHECK (stato IN ('Pubblicato', 'Pubblicazione'))
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
    FOREIGN KEY (operatore) REFERENCES OPERATORE(codice_fiscale)  ON UPDATE CASCADE ON DELETE RESTRICT
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
    CONSTRAINT check_nome_tipologia CHECK (nome IN ('Giornaliero', 'Settimanale', 'Mensile')),
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
        OR (orario_inizio >= '14:00' AND orario_fine <= '23:00'));
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
 