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
 
CREATE TABLE PRODUZIONE ( 
    codice SERIAL PRIMARY KEY, 
    titolo VARCHAR(255), 
    data_inizio DATE, 
    data_fine DATE, 
    stato VARCHAR(50), 
    tipo_produzione VARCHAR(255), 
    FOREIGN KEY (tipo_produzione) REFERENCES TIPO_PRODUZIONE(nome) 
); 
 
CREATE TABLE GENERE ( 
    nome VARCHAR(255) PRIMARY KEY 
); 
 
CREATE TABLE GENERE_PRODUZIONE ( 
    genere VARCHAR(255), 
    produzione INTEGER, 
    PRIMARY KEY (genere, produzione), 
    FOREIGN KEY (genere) REFERENCES GENERE(nome), 
    FOREIGN KEY (produzione) REFERENCES PRODUZIONE(codice) 
); 
 
CREATE TABLE CANZONE ( 
    titolo VARCHAR(255), 
    produzione INTEGER, 
    artista VARCHAR(255), 
    testo TEXT, 
    data_di_registrazione DATE, 
    lunghezza_in_secondi INTEGER, 
    nome_del_file VARCHAR(255), 
    percorso_di_sistema VARCHAR(255), 
    estensione VARCHAR(10), 
    PRIMARY KEY (titolo, produzione, artista), 
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte), 
    FOREIGN KEY (produzione) REFERENCES PRODUZIONE(codice)
); 

CREATE TABLE PARTECIPAZIONE ( 
    solista VARCHAR(255), 
    titolo VARCHAR(255), 
    produzione INTEGER, 
    artista VARCHAR(255), 
    PRIMARY KEY (solista, titolo, produzione, artista), 
    FOREIGN KEY (solista) REFERENCES SOLISTA(artista), 
    FOREIGN KEY (titolo, produzione, artista) REFERENCES CANZONE(titolo, produzione, artista) 
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
    timestamp TIMESTAMP, 
    artista VARCHAR(255), 
    operatore VARCHAR(16), 
    annullato BOOLEAN, 
    PRIMARY KEY (timestamp, artista), 
    FOREIGN KEY (artista) REFERENCES ARTISTA(nome_arte), 
    FOREIGN KEY (operatore) REFERENCES OPERATORE(codice_fiscale) 
); 
 
CREATE TABLE METODO ( 
    nome VARCHAR(255) PRIMARY KEY 
); 
 
CREATE TABLE PAGAMENTO ( 
    timestamp TIMESTAMP, 
    artista VARCHAR(255),
    metodo VARCHAR(255), 
    stato VARCHAR(50), 
    costo_totale DECIMAL(10, 2), 
    PRIMARY KEY (timestamp, artista), 
    FOREIGN KEY (timestamp, artista) REFERENCES ORDINE(timestamp, artista), 
    FOREIGN KEY (metodo) REFERENCES METODO(nome) 
); 
 
CREATE TABLE TIPOLOGIA ( 
    nome VARCHAR(255), 
    valore DECIMAL(10, 2), 
    n_giorni INTEGER, 
    PRIMARY KEY (nome) 
); 
 
CREATE TABLE PACCHETTO ( 
    tipologia VARCHAR(255), 
    timestamp TIMESTAMP, 
    artista VARCHAR(255),
    n_giorni_prenotati_totali INTEGER, 
    PRIMARY KEY (timestamp, artista, tipologia), 
    FOREIGN KEY (timestamp, artista) REFERENCES ORDINE(timestamp, artista), 
    FOREIGN KEY (tipologia) REFERENCES TIPOLOGIA(nome) 
); 
 
CREATE TABLE ORARIO ( 
    timestamp TIMESTAMP, 
    artista VARCHAR(255),
    n_ore_prenotate_totali INTEGER, 
    valore DECIMAL(10, 2), 
    PRIMARY KEY (timestamp, artista), 
    FOREIGN KEY (timestamp, artista) REFERENCES ORDINE(timestamp, artista)
); 
 
CREATE TABLE SALA ( 
    piano INTEGER, 
    numero INTEGER, 
    PRIMARY KEY (piano, numero) 
); 
 
CREATE TABLE PRENOTAZIONE ( 
    codice SERIAL PRIMARY KEY, 
    artista VARCHAR(255),
    timestamp TIMESTAMP, 
    tipologia VARCHAR(255), 
    sala_piano INTEGER, 
    sala_numero INTEGER, 
    annullata BOOLEAN, 
    giorno DATE, 
    tipo VARCHAR(50), 
    FOREIGN KEY (timestamp, artista, tipologia) REFERENCES PACCHETTO(timestamp, artista, tipologia), 
    FOREIGN KEY (sala_piano, sala_numero) REFERENCES SALA(piano, numero) 
); 
 
CREATE TABLE ORARIA ( 
    prenotazione SERIAL PRIMARY KEY, 
    FOREIGN KEY (prenotazione) REFERENCES PRENOTAZIONE(codice) 
); 
 
CREATE TABLE FASCIA_ORARIA ( 
    oraria SERIAL, 
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
    titolo VARCHAR(255), 
    produzione INTEGER, 
    artista VARCHAR(255), 
    PRIMARY KEY (tecnico, titolo, produzione, artista),
    FOREIGN KEY (tecnico) REFERENCES TECNICO(codice_fiscale),
    FOREIGN KEY (titolo, produzione, artista) REFERENCES CANZONE(titolo, produzione, artista) 
); 
 