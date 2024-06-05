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
2. Ripetizione dei dati da tabella a tabella in cascata.
3. Avere un codice univoco fa comodo; è più simile ad un caso reale.