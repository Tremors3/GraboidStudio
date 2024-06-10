-------------------------------------------------------------------------------------------------

La chiave primaria di ORDINE non ha molto senso:
"timestamp" la rende già univoca, non ha senso comprendere nella chiave anche "Artista".

-------------------------------------------------------------------------------------------------

https://stackoverflow.com/questions/43263924/sql-foreign-key-references-a-composite-primary-key
COSTRAINT UNIVOCI AL POSTO DI CHIAVI PRIMARIE:

AGGIUNTA DEI CODICI
1. PRODUZIONE
2. CANZONE
3. PARTECIPAZIONE
4. ORDINE
5. PACCHETTO

DIPENDENZE DELL'AGGIUNTA DEI CODICI
1. CONDURRE
2. PAGAMENTO
3. PACCHETTO
4. PRENOTAZIONE
5. LAVORA_A
6. ORARIO

MOTIVI
1. Complicazione delle query.
2. ~(NON CERTO) Ripetizione dei dati da tabella a tabella in cascata.
3. Avere un codice univoco fa comodo; è più simile ad un caso reale.

-------------------------------------------------------------------------------------------------

Abbiamo scelto di sostituire alcune chiavi primarie composte con un codice seriale per semplificare significativamente le query. Questo approccio ci consente di evitare chiavi composte molto lunghe, rendendo più agevole la gestione delle tabelle. Per mantenere l'unicità originariamente garantita dalle chiavi primarie composte, abbiamo convertito questi attributi in vincoli UNIQUE, come mostrato di seguito.

Consideriamo l'esempio:

CREATE TABLE CANZONE (
    -- Nuovo codice seriale
    codice SERIAL PRIMARY KEY,

    -- Attributi che componevano la vecchia chiave primaria
    titolo VARCHAR(255) NOT NULL, 
    produzione INTEGER NOT NULL,

    -- Unicità della vecchia chiave primaria mantenuta
    CONSTRAINT unique_canzone UNIQUE (titolo, produzione),

    ...
);

Abbiamo applicato questa tecnica alle seguenti tabelle: PRODUZIONE, CANZONE, PARTECIPAZIONE, ORDINE, PACCHETTO. Le tabelle dipendenti sono state aggiornate per riferirsi ai nuovi codici seriali, mantenendo l'integrità referenziale del database. Tali tabelle sono: CONDURRE, PAGAMENTO, PACCHETTO, PRENOTAZIONE, LAVORA_A, ORARIO.