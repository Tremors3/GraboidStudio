------------------------------------- ARTISTA -------------------------------------

-- ELENCARE LE PRODUZIONI COMPOSTE DA UN DETERMINATO ARTISTA
-- Vengono elencate tutte le informazioni sulle produzioni composte da un determinato artista.

SELECT * FROM produzione AS p WHERE p.artista = 'SoloXYZ';

-- A2) ELENCARE GLI ARTISTI CHE HANNO PARTECIPATO ALLA CREAZIONE DI UNA CANZONE
-- Data una certa canzone vengono mostrate le informazioni degli artisti che hanno partecipato ad essa.

-- fare giro turistico produzioni e canzoni in questa query
SELECT *
FROM solista as s
JOIN (
    SELECT p.solista
    FROM partecipazione AS p
    WHERE p.canzone = 123
) AS subquery
ON s.artista = subquery.solista;


-- A3) VISUALIZZARE UN ELENCO DELLE PRENOTAZIONI EFFETTUATE TRA TUTTI GLI ORDINI DATO UN ARTISTA
-- Vengono visualizzati i dettagli delle prenotazioni effettuate da un artista.

(
    select p.codice, p.giorno, p.annullata
    from prenotazione as p
    JOIN (  
        SELECT oraria.prenotazione
        FROM ordine
        JOIN orario ON ordine.codice = orario.ordine
        JOIN oraria ON oraria.orario = orario.ordine
        WHERE ordine.artista = 'SoloXYZ'
    ) AS subquery ON p.codice = subquery.prenotazione
)
union 
(
    select p.codice, p.giorno, p.annullata
    from prenotazione as p
    join (
        SELECT pacchetto.ordine
        FROM ordine AS o
        JOIN pacchetto ON pacchetto.ordine = o.codice
        WHERE o.artista = 'SoloXYZ'
    ) AS subquery ON p.codice = subquery.ordine
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
FROM pagamento as p
join (
    SELECT o.codice, o.timestamp, o.artista, o.annullato, o.operatore
    FROM ordine as o
    WHERE o.codice = 1
) as s on s.codice = p.ordine

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
SELECT p.ordine, sub.nome, sub.cognome, sub.numero, sub.timestamp
FROM PAGAMENTO AS p
JOIN ( 
    SELECT o.codice, s.nome, s.cognome, te.numero, o.timestamp
    FROM ORDINE AS o, ARTISTA AS a, SOLISTA AS s, TELEFONO_A AS te
    WHERE o.artista = a.nome_arte 
    AND s.artista = a.nome_arte
	AND te.artista = a.nome_arte
) as sub ON p.ordine = sub.codice

SELECT sub.nome_arte, p.ordine, sub.numero, sub.timestamp
FROM PAGAMENTO AS p
JOIN ( 
    SELECT a.nome_arte, o.codice, te.numero, o.timestamp
    FROM ORDINE AS o, ARTISTA AS a, GRUPPO AS g, TELEFONO_A AS te
    WHERE o.artista = a.nome_arte 
    AND g.artista = a.nome_arte
	AND te.artista = a.nome_arte
) as sub ON p.ordine = sub.codice

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
-- Viene visualizzato un elenco di tutte le sale libere per una certa data/ora.

-- fare join oraria e con fascia oraria, per una certa da e ora "between"
SELECT numero, piano FROM SALA
WHERE (numero, piano) != (SELECT sala_numero, sala_piano FROM PRENOTAZIONE WHERE giorno != YYYY-MM-DD)

-- come diamine si fa...
SELECT numero, piano FROM SALA
WHERE numero != subquery.sala_numero && piano != subquery.piano (SELECT sala_numero, sala_piano FROM PRENOTAZIONE WHERE giorno != YYYY-MM-DD) as subquery



