------------------------> Operazioni Artisti

-- Elencare le produzioni a cui ha partecipato un artista

SELECT P.titolo, P.tipo, P.data_uscita
FROM Partecipazione_Produzione PP
JOIN Produzione P ON PP.produzione = P.codice
WHERE PP.artista = 'ID_ARTISTA';

-- Elencare gli artisti che hanno partecipato alla creazione di una canzone

SELECT A.nome_arte, A.tipo
FROM Partecipazione_Canzone PC
JOIN Artista A ON PC.artista = A.codice
WHERE PC.canzone = 'ID_CANZONE';

-- Visualizzare le informazioni relative a una prenotazione

SELECT P.codice, P.pacchetto, P.sala, P.annullata, P.giorno, P.tipo
FROM Prenotazione P
WHERE P.codice = 'ID_PRENOTAZIONE';

------------------------> Operazioni Tecnici

-- Elencare i tecnici che hanno lavorato a una canzone

SELECT T.codice_fiscale, T.nome, T.cognome, T.data_di_nascita, T.data_di_assunzione, T.iban
FROM Lavora_A LA
JOIN Tecnico T ON LA.tecnico = T.codice_fiscale
WHERE LA.canzone = 'ID_CANZONE';

-- Elencare le canzoni a cui ha lavorato un tecnico

SELECT C.titolo, C.testo, C.data_registrazione, C.lunghezza
FROM Lavora_A LA
JOIN Canzone C ON LA.canzone = C.codice
WHERE LA.tecnico = 'ID_TECNICO';

------------------------> Operazioni Operatori

-- Elencare tutte le prenotazioni di un artista

SELECT PR.codice, PR.pacchetto, PR.sala, PR.annullata, PR.giorno, PR.tipo
FROM Prenotazione PR
JOIN Pacchetto PA ON PR.pacchetto = PA.ordine
JOIN Ordine O ON PA.ordine = O.codice
WHERE O.artista = 'ID_ARTISTA';

-- Visualizzare lo stato di un ordine

SELECT O.codice, O.metodo, O.stato, O.costo_totale
FROM Ordine O
WHERE O.codice = 'ID_ORDINE';

-- Elencare i metodi di pagamento disponibili

SELECT M.nome
FROM Metodo M;

-- Visualizzare le informazioni di una sala specifica

SELECT S.piano, S.numero
FROM Sala S
WHERE S.numero = 'NUMERO_SALA' AND S.piano = 'PIANO_SALA';

------------------------> Operazioni Comuni

-- Elencare tutte le prenotazioni effettuate in una sala specifica

SELECT PR.codice, PR.pacchetto, PR.annullata, PR.giorno, PR.tipo
FROM Prenotazione PR
WHERE PR.sala = 'NUMERO_SALA';

-- Visualizzare tutte le prenotazioni in una fascia oraria specifica

SELECT FA.oraria, FA.orario_inizio, FA.orario_fine
FROM Fascia_Oraria FA
JOIN Oraria O ON FA.oraria = O.prenotazione
WHERE FA.orario_inizio >= 'ORARIO_INIZIO' AND FA.orario_fine <= 'ORARIO_FINE';