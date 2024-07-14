------------------------------------- ARTISTA -------------------------------------

/* A1) ELENCARE LE PRODUZIONI COMPOSTE DA UN DETERMINATO ARTISTA
 * Vengono elencate tutte le informazioni sulle produzioni composte da un determinato artista.
 */ [CONTROLLATA - INDICE ] : "L'indice viene anche ignorato dall'ottimizzatore"
SELECT * FROM produzione AS p WHERE artista = 'SoloXYZ'
ORDER BY p.titolo;

/* A2) ELENCARE GLI ARTISTI CHE HANNO PARTECIPATO ALLA CREAZIONE DI UNA CANZONE
 * Data una certa canzone vengono mostrate le informazioni degli artisti che hanno partecipato ad essa.
 */ [CONTROLLATA  - (TANTE CANZONI)]
SELECT * FROM solista WHERE artista IN (
    SELECT p.solista FROM partecipazione as p WHERE p.canzone = 1
); 

/* A3) VISUALIZZARE UN ELENCO DELLE PRENOTAZIONI EFFETTUATE TRA TUTTI GLI ORDINI DATO UN ARTISTA
 * Vengono visualizzati i dettagli delle prenotazioni effettuate da un artista.
 */ [CONTROLLATA  - NON SERVE INDICE]
(
    SELECT codice, giorno, annullata FROM prenotazione
    WHERE codice IN (
        SELECT oraria.prenotazione
        FROM ordine
        JOIN orario ON ordine.codice = orario.ordine
        JOIN oraria ON oraria.orario = orario.ordine
        WHERE ordine.artista = 'SoloXYZ'
    )
)
union
(
    SELECT codice, giorno, annullata FROM prenotazione
    WHERE pacchetto IN (
        SELECT pa.ordine  
        FROM ordine AS o
        JOIN pacchetto AS pa ON o.codice = pa.ordine
        WHERE o.artista = 'SoloXYZ'
    )
);
------------------------------------- TECNICO -------------------------------------

/* T1) ELENCARE LE CANZONI A CUI LAVORA UN TECNICO
 * Viene visualizzato un elenco di canzoni a cui lavora un tecnico; viene richiesto di visualizzare il titolo,
 * la produzione di cui fa parte se è in una produzione, la lunghezza, data di registrazione, testo.
 */
SELECT titolo, produzione, lunghezza_in_secondi, data_di_registrazione, testo FROM LAVORA_A
JOIN CANZONE on LAVORA_A.canzone = CANZONE.codice
WHERE LAVORA_A.tecnico = 'TCNAUD85M01H501Z';

/* T2) INSERIRE I DATI DI UNA CANZONE
 * Inserimento informazioni generali della canzone titolo, lunghezza, data di registrazione, testo, e il file
 * associato contenente il nome, il percorso di sistema e l’estensione.
 */
INSERT INTO Canzone (titolo, produzione, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione) VALUES ...;

/* T3) CREAZIONE DI UNA PRODUZIONE
 * Inserimento del titolo, viene indicato l’artista che la possiede e viene impostato lo stato di "produzione",
 * la data di inizio.
 */
INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES ...;

/* T4) PUBBLICAZIONE DI UNA PRODUZIONE
 * Viene impostata per una data produzione lo stato di "Pubblicazione" che va ad indicare l’immutabilità di 
 * essa e viene impostata la data di termine delle registrazioni.
 */
UPDATE PRODUZIONE as p
SET stato = 'Pubblicazione', data_fine = CURRENT_DATE
WHERE codice = 2;

/* T5) INSERIRE UNA CANZONE IN UNA PRODUZIONE
 * Una volta terminata la registrazione di una Canzone essa può inserita nella Produzione di cui fa parte.
 */
UPDATE canzone
SET produzione = 2 
WHERE codice = 2 AND (
    (SELECT stato FROM PRODUZIONE WHERE codice = 2) != 'Pubblicazione'
);

------------------------------------- OPERATORE -------------------------------------

/* O1) CREARE UN ORDINE
 * L’operatore registra gli ordini previo accordo con il cliente tramite chiamata telefonica.
 */
[IMPLEMENTATA TRAMITE PROCEDURA]

/* O2) ELENCO INFORMAZIONI DI UN DATO ORDINE
 * Vengono visualizzate tutte le informazioni di interesse di un dato ordine.
 */
SELECT s.codice, s.timestamp, s.artista, s.annullato, s.operatore, p.stato, p.metodo, p.costo_totale
FROM pagamento AS p
JOIN (
    SELECT o.codice, o.timestamp, o.artista, o.annullato, o.operatore
    FROM ordine AS o
    WHERE o.codice = 1
) AS s ON s.codice = p.ordine;

/* O3) ANNULLARE UN ORDINE
 * L’operatore può annullare un ordine se il cliente lo richiede o non paga dopo aver chiamato l’operatore.
 */
UPDATE ORDINE
SET annullato = TRUE
WHERE codice = 1;

/* O4) CREARE UNA PRENOTAZIONE
 * L’operatore registra le prenotazioni previo accordo con il cliente tramite chiamata telefonica.
 */
[IMPLEMENTATA TRAMITE PROCEDURA]

/* O5) ANNULLARE UNA PRENOTAZIONE
 * L’operatore può annullare una prenotazione previo accordo con il cliente tramite chiamata telefonica.
 */
UPDATE PRENOTAZIONE
SET annullata = TRUE
WHERE codice = 1;

/* O6) VISUALIZZARE LE INFORMAZIONI RELATIVE AL PAGAMENTO DI UN ORDINE
 * Vengono visualizzate le informazioni nome, cognome del cliente, data in cui è stata effettuato l’ordine, 
 * lo stato "pagato", "da pagare", costo totale dell’ordine.
 */

-- Caso del Solista
SELECT o.codice, s.nome, s.cognome, t.numero, o.timestamp
FROM ordine AS o
JOIN artista    AS a ON a.nome_arte = o.artista
JOIN solista    AS s ON a.nome_arte = s.artista
JOIN telefono_a AS t ON a.nome_arte = t.artista
JOIN PAGAMENTO  AS p ON p.ordine = o.codice;

-- Caso del Gruppo
SELECT o.codice, a.nome_arte, t.numero, o.timestamp
FROM ORDINE AS o
JOIN ARTISTA    AS a ON a.nome_arte = o.artista
JOIN GRUPPO     AS g ON a.nome_arte = g.artista
JOIN TELEFONO_A AS t ON a.nome_arte = t.artista
JOIN PAGAMENTO  AS p ON p.ordine = o.codice;

/* O7) ELENCARE GLI ORDINI CHE NON SONO ANCORA STATI PAGATI
 * Viene visualizzato un elenco di ordini non pagati e informazioni di chi ha fatto l’ordine: nome, cognome, 
 * telefono, data di effettuazione dell’ordine e il costo totale. Gli stati possibili sono 'Pagato', 'Da Pagare'.
 */

-- Caso del Solista
SELECT p.ordine, sub.nome, sub.cognome, sub.numero, sub.timestamp
FROM PAGAMENTO AS p
JOIN ( 
    SELECT o.codice, s.nome, s.cognome, te.numero, o.timestamp
    FROM ORDINE AS o, ARTISTA AS a, SOLISTA AS s, TELEFONO_A AS te
    WHERE o.artista = a.nome_arte 
    AND s.artista = a.nome_arte
	AND te.artista = a.nome_arte
) as sub ON p.ordine = sub.codice WHERE p.stato = 'Da pagare';

-- Caso del Gruppo
SELECT p.ordine, sub.nome_arte, sub.numero, sub.timestamp
FROM PAGAMENTO AS p
JOIN ( 
    SELECT a.nome_arte, o.codice, te.numero, o.timestamp
    FROM ORDINE AS o, ARTISTA AS a, GRUPPO AS g, TELEFONO_A AS te
    WHERE o.artista = a.nome_arte 
    AND g.artista = a.nome_arte
	AND te.artista = a.nome_arte
) as sub ON p.ordine = sub.codice WHERE p.stato = 'Da pagare';

/* O8) ELENCARE LE SALE DISPONIBILI
 * Viene visualizzato un elenco di tutte le sale libere per una certa data, ora di inizio e ora di fine
 */
(
    SELECT s.numero, s.piano
    FROM SALA s
    WHERE (s.numero, s.piano) NOT IN (

        SELECT DISTINCT p.sala_numero, p.sala_piano
        FROM PRENOTAZIONE p
        JOIN ORARIA o ON o.prenotazione = p.codice
        JOIN FASCIA_ORARIA f ON f.oraria = o.prenotazione
        WHERE p.annullata = FALSE
        AND p.tipo = FALSE 
        AND p.giorno = '2023-02-04'
        AND (
            (f.orario_inizio <= '<orario_inizio>' AND '<orario_inizio>' < f.orario_fine) OR -- [ 10:00 ( 11:00] )
            (f.orario_inizio < '<orario_fine>' AND '<orario_fine>' <= f.orario_fine) OR     -- ( [ 10:00 ) 11:00]
            ('<orario_inizio>' <= f.orario_inizio AND f.orario_fine <= '<orario_fine>')     -- ( [ 10:00 11:00] )
        )
    )
)
EXCEPT 
(
    SELECT sala_numero, sala_piano
    FROM PRENOTAZIONE
    WHERE annullata = FALSE AND tipo = TRUE AND giorno = '<giorno>'
);

/* DATI PROVA
 *  giorno '2023-02-04'
 *  orari_inizi['20:00:00', '18:00:00', '10:00:00', '12:00:00', '12:00:00', '11:00:00']
 *  orarifine['23:00:00', '23:00:00', '12:00:00', '13:00:00', '14:00:00', '13:00:00']
 */