------------------------------------- ARTISTA -------------------------------------

-- ELENCARE LE PRODUZIONI COMPOSTE DA UN DETERMINATO ARTISTA
-- Vengono elencate tutte le informazioni sulle produzioni composte da un determinato artista.

SELECT * FROM produzione AS p WHERE p.artista = "ID_ARTISTA";

-- A2) ELENCARE GLI ARTISTI CHE HANNO PARTECIPATO ALLA CREAZIONE DI UNA CANZONE
-- Data una certa canzone vengono mostrate le informazioni degli artisti che hanno partecipato ad essa.

-- fare giro turistico produzioni e canzoni in questa query

SELECT *
FROM solista as s
JOIN (
    SELECT p.solista
    FROM partecipazione AS p
    WHERE p.canzone = 'ID_canzone'
) AS subquery
ON s.artista = subquery.solista;


-- A3) VISUALIZZARE UN ELENCO DELLE PRENOTAZIONI EFFETTUATE TRA TUTTI GLI ORDINI DATO UN ARTISTA
-- Vengono visualizzati i dettagli delle prenotazioni effettuate da un artista.

-- bisogna capire cosa esce in output, se è necessario fare un group by p.oraria
(select p.codice, p.giorno, p.annullata
from prenotazione as p
JOIN (
    SELECT oraria.prenotazione
    FROM ordine AS o
    JOIN orario ON o.ordine = orario.ordine
    JOIN oraria ON oraria.orario = orario.ordine
    WHERE o.artista = 'ID_ARTISTA'
) AS subquery ON p.codice = subquery.prenotazione
)
union 
(select p.codice, p.giorno, p.annullata
from prenotazione as p
join (
    SELECT pacchetto.ordine
    FROM ordine AS o
    JOIN pacchetto
    ON pacchetto.ordine = o.codice
    WHERE o.artista = 'ID_ARTISTA'
) AS subquery ON p.codice = subquery.ordine
)

------------------------------------- TECNICO -------------------------------------


--T1) ELENCARE LE CANZONI A CUI LAVORA UN TECNICO
--Viene visualizzato un elenco di canzoni a cui lavora un tecnico, viene richiesto di visualizzare il titolo,
--la produzione di cui fa parte se è in una produzione, la lunghezza, data di registrazione, testo.

SELECT titolo, produzione, lunghezza, data_registrazione, testo FROM CANZONE, LAVORA_A, TECNICO
WHERE CANZONE.codice = 'codice' AND CANZONE.codice = LAVORA_A.canzone AND LAVORA_A.tecnico = TECNICO.codice_fiscale;




--T2) INSERIRE I DATI DI UNA CANZONE
--Inserimento informazioni generali della canzone titolo, lunghezza, data di registrazione, testo, e il file
--associato contenente il nome, il percorso di sistema e l’estensione.

INSERT INTO Canzone (titolo, produzione, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione) VALUES ...;

--T3) CREAZIONE DI UNA PRODUZIONE
--Inserimento del titolo, viene indicato l’artista che la possiede e viene impostato lo stato di "produzione",
--la data di inizio.

INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES ...;


--T4) PUBBLICAZIONE DI UNA PRODUZIONE
--Viene impostata per una data produzione lo stato di "pubblicazione" che va ad indicare l’immutabilità di
--essa e viene impostata la data di termine delle registrazioni.

UPDATE PRODUZIONE
SET stato = 'Pubblicazione'
WHERE codice = '<codice>';

--T5) INSERIRE UNA CANZONE IN UNA PRODUZIONE
--Una volta terminata la registrazione di una Canzone essa può inserita nella Produzione di cui fa parte.

UPDATE CANZONE 
SET produzione = '<codice>' 
WHERE codice = '<codice>' AND (SELECT stato FROM PRODUZIONE WHERE PRODUZIONE.codice = '<codice>') != 'Pubblicazione';









------------------------------------- OPERATORE -------------------------------------




-- O1) CREARE UN ORDINE
-- L’operatore registra gli ordini previo accordo con il cliente tramite chiamata telefonica.

-- O2) ELENCO INFORMAZIONI DI UN DATO ORDINE
-- Vengono visualizzate tutte le informazioni di interesse di un dato ordine.

-- O3) ANNULLARE UN ORDINE
-- L’operatore può annullare un ordine se il cliente lo richiede o non paga dopo aver chiamato l’operatore.

-- O4) CREARE UNA PRENOTAZIONE
-- L’operatore registra le prenotazioni previo accordo con il cliente tramite chiamata telefonica.

-- O5) ANNULLARE UNA PRENOTAZIONE
-- L’operatore può annullare una prenotazione previo accordo con il cliente tramite chiamata telefonica.

-- O6) VISUALIZZARE LE INFORMAZIONI RELATIVE AL PAGAMENTO DI UN ORDINE
-- Vengono visualizzate le informazioni nome, cognome del cliente, data in cui è stata effettuato l’ordine,
-- lo stato "pagato", "da pagare", costo totale dell’ordine.

-- O7) ELENCARE GLI ORDINI CHE NON SONO ANCORA STATI PAGATI
-- Viene visualizzato un elenco di ordini non pagati e informazioni di chi ha fatto l’ordine: nome, cognome,
-- telefono, data di effettuazione dell’ordine.

-- O8) ELENCARE LE SALE DISPONIBILI
-- Viene visualizzato un elenco di tutte le sale libere per una certa data/ora.







