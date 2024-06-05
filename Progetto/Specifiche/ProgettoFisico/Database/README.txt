-------------------------------------------------------------------------------------------------

ERROR:  non c'è alcun vincolo univoco che corrisponda alle chiavi indicate per la tabella referenziata "canzone", "pacchetto",
SOLUTION: aggiungere la tag UNIQUE ad uno qualsiasi degli attributi che compongono la chiave primaria.

canzone   --> titolo: UNIQUE
pacchetto --> timestamp: UNIQUE

-------------------------------------------------------------------------------------------------

La chiave primaria di ORDINE non ha molto senso:
"timestamp" la rende già univoca, non ha senso comprendere nella chiave anche "Artista".

-------------------------------------------------------------------------------------------------

CREATE TABLE PARTECIPAZIONE ( 
    solista VARCHAR(255), 
    canzone VARCHAR(255), 
    PRIMARY KEY (solista, canzone), 
    FOREIGN KEY (solista) REFERENCES SOLISTA(artista), 
    FOREIGN KEY (canzone) REFERENCES CANZONE(titolo) 
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

-------------------------------------------------------------------------------------------------

CREATE TABLE PRENOTAZIONE ( 
    codice SERIAL PRIMARY KEY, 
    pacchetto TIMESTAMP, 
    sala_piano INTEGER, 
    sala_numero INTEGER, 
    annullata BOOLEAN, 
    giorno DATE, 
    tipo VARCHAR(50), 
    FOREIGN KEY (pacchetto) REFERENCES PACCHETTO(ordine), 
    FOREIGN KEY (sala_piano, sala_numero) REFERENCES SALA(piano, numero) 
); 

CREATE TABLE PRENOTAZIONE ( 
    codice SERIAL PRIMARY KEY, 
    ordine TIMESTAMP, 
    tipologia VARCHAR(255), 
    sala_piano INTEGER, 
    sala_numero INTEGER, 
    annullata BOOLEAN, 
    giorno DATE, 
    tipo VARCHAR(50), 
    FOREIGN KEY (ordine, tipologia) REFERENCES PACCHETTO(ordine, tipologia), 
    FOREIGN KEY (sala_piano, sala_numero) REFERENCES SALA(piano, numero) 
); 

-------------------------------------------------------------------------------------------------

CREATE TABLE LAVORA_A (
    tecnico CHAR(16),
    canzone VARCHAR(255),
    PRIMARY KEY (tecnico, canzone),
    FOREIGN KEY (tecnico) REFERENCES TECNICO(codice_fiscale),
    FOREIGN KEY (canzone) REFERENCES CANZONE(nome_del_file)
); 
 