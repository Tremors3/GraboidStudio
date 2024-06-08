------------------------------------- ARTISTA -------------------------------------

-- ELENCARE LE PRODUZIONI COMPOSTE DA UN DETERMINATO ARTISTA
-- Vengono elencate tutte le informazioni sulle produzioni composte da un determinato artista.

SELECT * FROM produzione WHERE artista = 'SoloXYZ';

-- A2) ELENCARE GLI ARTISTI CHE HANNO PARTECIPATO ALLA CREAZIONE DI UNA CANZONE
-- Data una certa canzone vengono mostrate le informazioni degli artisti che hanno partecipato ad essa.

-- fare giro turistico produzioni e canzoni in questa query
SELECT * FROM solista WHERE artista IN (
    SELECT p.solista FROM partecipazione as p WHERE p.canzone = 1
)

-- A3) VISUALIZZARE UN ELENCO DELLE PRENOTAZIONI EFFETTUATE TRA TUTTI GLI ORDINI DATO UN ARTISTA
-- Vengono visualizzati i dettagli delle prenotazioni effettuate da un artista.

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
)
------------------------------------- TECNICO -------------------------------------

--T1) ELENCARE LE CANZONI A CUI LAVORA UN TECNICO
--Viene visualizzato un elenco di canzoni a cui lavora un tecnico, viene richiesto di visualizzare il titolo,
--la produzione di cui fa parte se è in una produzione, la lunghezza, data di registrazione, testo.


--T2) INSERIRE I DATI DI UNA CANZONE
--Inserimento informazioni generali della canzone titolo, lunghezza, data di registrazione, testo, e il file
--associato contenente il nome, il percorso di sistema e l’estensione.

INSERT INTO Canzone (titolo, produzione, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione) VALUES ...;

--T3) CREAZIONE DI UNA PRODUZIONE
--Inserimento del titolo, viene indicato l’artista che la possiede e viene impostato lo stato di "produzione",
--la data di inizio.

INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES ...;

--T4) PUBBLICAZIONE DI UNA PRODUZIONE
--Viene impostata per una data produzione lo stato di "pubblicazione" che va ad indicare l’immutabilità di essa e viene impostata la data di termine delle registrazioni.

UPDATE PRODUZIONE as p
SET stato = 'Pubblicazione', data_fine = CURRENT_DATE
WHERE codice = 2;

--T5) INSERIRE UNA CANZONE IN UNA PRODUZIONE
--Una volta terminata la registrazione di una Canzone essa può inserita nella Produzione di cui fa parte.

UPDATE canzone
SET produzione = 2 
WHERE codice = 2 AND (
    (SELECT stato FROM PRODUZIONE WHERE codice = 2) != 'Pubblicazione'
);

------------------------------------- FUNZIONA  -------------------------------------

SELECT titolo, produzione, lunghezza_in_secondi, data_di_registrazione, testo FROM LAVORA_A
JOIN CANZONE on LAVORA_A.canzone = CANZONE.codice
WHERE  LAVORA_A.tecnico = 'TCNAUD85M01H501Z';







------------------------------------- OPERATORE -------------------------------------

-- O1) CREARE UN ORDINE -- procedura
-- L’operatore registra gli ordini previo accordo con il cliente tramite chiamata telefonica.

-- O2) ELENCO INFORMAZIONI DI UN DATO ORDINE
-- Vengono visualizzate tutte le informazioni di interesse di un dato ordine.
-- controllare se prende i campi s.codice, s.timestamp, s.artista, s.annullato, s.operatore
SELECT s.codice, s.timestamp, s.artista, s.annullato, s.operatore, p.stato, p.metodo, p.costo_totale
FROM pagamento AS p
JOIN (
    SELECT o.codice, o.timestamp, o.artista, o.annullato, o.operatore
    FROM ordine AS o
    WHERE o.codice = 1
) AS s ON s.codice = p.ordine

-- O3) ANNULLARE UN ORDINE
-- L’operatore può annullare un ordine se il cliente lo richiede o non paga dopo aver chiamato l’operatore.

UPDATE ORDINE
SET annullato = TRUE
WHERE codice = 1;

-- O4) CREARE UNA PRENOTAZIONE - procedura
-- L’operatore registra le prenotazioni previo accordo con il cliente tramite chiamata telefonica.

-- O5) ANNULLARE UNA PRENOTAZIONE
-- L’operatore può annullare una prenotazione previo accordo con il cliente tramite chiamata telefonica.

UPDATE PRENOTAZIONE
SET annullata = TRUE
WHERE codice = 1;

-- O6) VISUALIZZARE LE INFORMAZIONI RELATIVE AL PAGAMENTO DI UN ORDINE
-- Vengono visualizzate le informazioni nome, cognome del cliente, data in cui è stata effettuato l’ordine, lo stato "pagato", "da pagare", costo totale dell’ordine.

SELECT o.codice, s.nome, s.cognome, t.numero, o.timestamp
FROM ordine AS o
JOIN artista    AS a ON a.nome_arte = o.artista
JOIN solista    AS s ON a.nome_arte = s.artista
JOIN telefono_a AS t ON a.nome_arte = t.artista
JOIN PAGAMENTO  AS p ON p.ordine = o.codice


SELECT o.codice, a.nome_arte, t.numero, o.timestamp
FROM ORDINE AS o
JOIN ARTISTA    AS a ON a.nome_arte = o.artista
JOIN GRUPPO     AS g ON a.nome_arte = g.artista
JOIN TELEFONO_A AS t ON a.nome_arte = t.artista
JOIN PAGAMENTO  AS p ON p.ordine = o.codice


-- O7) ELENCARE GLI ORDINI CHE NON SONO ANCORA STATI PAGATI
-- Viene visualizzato un elenco di ordini non pagati e informazioni di chi ha fatto l’ordine: nome, cognome, telefono, data di effettuazione dell’ordine e il costo totale.
-- gli stati possibili sono 'Pagato', 'Da Pagare'                                        (╬▔皿▔)╯

-- Per i Solisti
SELECT p.ordine, sub.nome, sub.cognome, sub.numero, sub.timestamp
FROM PAGAMENTO AS p
JOIN ( 
    SELECT o.codice, s.nome, s.cognome, te.numero, o.timestamp
    FROM ORDINE AS o, ARTISTA AS a, SOLISTA AS s, TELEFONO_A AS te
    WHERE o.artista = a.nome_arte 
    AND s.artista = a.nome_arte
	AND te.artista = a.nome_arte
) as sub ON p.ordine = sub.codice WHERE p.stato = 'Da pagare'

-- Per i Gruppi
SELECT p.ordine, sub.nome_arte, sub.numero, sub.timestamp
FROM PAGAMENTO AS p
JOIN ( 
    SELECT a.nome_arte, o.codice, te.numero, o.timestamp
    FROM ORDINE AS o, ARTISTA AS a, GRUPPO AS g, TELEFONO_A AS te
    WHERE o.artista = a.nome_arte 
    AND g.artista = a.nome_arte
	AND te.artista = a.nome_arte
) as sub ON p.ordine = sub.codice WHERE p.stato = 'Da pagare'








-- O8) ELENCARE LE SALE DISPONIBILI
-- Viene visualizzato un elenco di tutte le sale libere per una certa data, ora di inizio e ora di fine

-- giornaliera è true, oraria è false

-- spiegazione query
-- in questo giorno 2023-02-04 sappiamo che esiste una prenotazione che tiene la sala 1 numero 1 occupata dalle ore '09:00:00' fino alle '12:00:00' e
-- dalle ore '13:00:00' fino alle '17:00:00'

-- abbiamo 5 sale in totale
-- nel popolamento siamo sicuri che quella sala non venga occupata da altre prenotazioni, inoltre le sale rimanenti sappiamo che sono tutte libere per quel giorno.
-- noi vogliamo che inserendo il giorno 2023-02-04 e l'ora di inizio 18:00:00 alle ore 23:00:00, ci venga mostrato in output il codice di questa sala e anche il codice delle altre sale 

(
    SELECT s.numero, s.piano
    FROM SALA s
    WHERE (s.numero, s.piano) NOT IN (
        -- tutte le chiave primarie delle sale che sono occupate in un dato giorno in una determinata fascia oraria
        SELECT DISTINCT p.sala_numero, p.sala_piano
        FROM PRENOTAZIONE p
        JOIN ORARIA o ON o.prenotazione = p.codice
        JOIN FASCIA_ORARIA f ON f.oraria = o.prenotazione
        WHERE p.annullata = FALSE
        AND p.tipo = FALSE 
        AND p.giorno = '2023-02-04'
        AND not (f.orario_inizio BETWEEN '18:00:00' and '23:00:00')
        AND not( f.orario_fine  BETWEEN '18:00:00' and '23:00:00')
        )
)
EXCEPT -- rimuovi le sale che sono occupate per tutto il giorno da una prenotazione giornaliera nel giorno dato in input
(
    SELECT sala_numero, sala_piano
    FROM PRENOTAZIONE
    WHERE annullata = FALSE AND tipo = TRUE AND giorno = '2023-02-04'
);




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
        (f.orario_inizio < '20:00:00' AND f.orario_fine > '20:00:00') OR
        (f.orario_inizio < '23:00:00' AND f.orario_fine > '23:00:00') OR
        (f.orario_inizio >= '20:00:00' AND f.orario_fine <= '23:00:00')
    )
)
EXCEPT
SELECT sala_numero, sala_piano
FROM PRENOTAZIONE
WHERE annullata = FALSE AND tipo = TRUE AND giorno = '2023-02-04';

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
        (f.orario_inizio < '18:00:00' AND f.orario_fine > '18:00:00') OR
        (f.orario_inizio < '23:00:00' AND f.orario_fine > '23:00:00') OR
        (f.orario_inizio >= '18:00:00' AND f.orario_fine <= '23:00:00')
    )
)
EXCEPT
SELECT sala_numero, sala_piano
FROM PRENOTAZIONE
WHERE annullata = FALSE AND tipo = TRUE AND giorno = '2023-02-04';

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
        (f.orario_inizio < '10:00:00' AND f.orario_fine > '10:00:00') OR
        (f.orario_inizio < '12:00:00' AND f.orario_fine > '12:00:00') OR
        (f.orario_inizio >= '10:00:00' AND f.orario_fine <= '12:00:00')
    )
)
EXCEPT
SELECT sala_numero, sala_piano
FROM PRENOTAZIONE
WHERE annullata = FALSE AND tipo = TRUE AND giorno = '2023-02-04';


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
        (f.orario_inizio < '12:00:00' AND f.orario_fine > '12:00:00') OR
        (f.orario_inizio < '13:00:00' AND f.orario_fine > '13:00:00') OR
        (f.orario_inizio >= '12:00:00' AND f.orario_fine <= '13:00:00')
    )
)
EXCEPT
SELECT sala_numero, sala_piano
FROM PRENOTAZIONE
WHERE annullata = FALSE AND tipo = TRUE AND giorno = '2023-02-04';


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
        (f.orario_inizio < '12:00:00' AND f.orario_fine > '12:00:00') OR
        (f.orario_inizio < '14:00:00' AND f.orario_fine > '14:00:00') OR
        (f.orario_inizio >= '12:00:00' AND f.orario_fine <= '14:00:00')
    )
)
EXCEPT
SELECT sala_numero, sala_piano
FROM PRENOTAZIONE
WHERE annullata = FALSE AND tipo = TRUE AND giorno = '2023-02-04';

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
        (f.orario_inizio < '11:00:00' AND f.orario_fine > '11:00:00') OR
        (f.orario_inizio < '13:00:00' AND f.orario_fine > '13:00:00') OR
        (f.orario_inizio >= '11:00:00' AND f.orario_fine <= '13:00:00')
    )
)
EXCEPT
SELECT sala_numero, sala_piano
FROM PRENOTAZIONE
WHERE annullata = FALSE AND tipo = TRUE AND giorno = '2023-02-04';