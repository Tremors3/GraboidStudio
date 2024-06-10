/* CALCOLA L'ETA DELL'ARTISTA
 * La funzione calcola l'età dell'artista del quale è stato fornito il codice fiscale.
 *
 * INPUT:   cd      INT
 * OUTPUT:  età     DECIMAL
 */
CREATE OR REPLACE FUNCTION CalcolaEtaArtista(cd VARCHAR(16)) RETURNS INT LANGUAGE plpgsql AS $$
DECLARE
    data_nascita DATE;
BEGIN
    SELECT data_di_nascita INTO data_nascita FROM SOLISTA WHERE codice_fiscale = cd;
	return (date_part('year', CURRENT_DATE) - date_part('year', data_nascita));
END
$$;
SELECT CalcolaEtaArtista('VCTFNC90A01H501X');

---------------------------------------------------------------------------------------------------

/* CONTROLLA IL TIPO DI UN ORDINE
 * La funzione controlla il tipo di un ordine.
 * Un ordine può essere di tipo Orario o di tipo Giornaliero.
 * 
 * INPUT:   ordine_id   INT
 * OUTPUT:
 *          TRUE        BOOL        :se orario
 *          FALSE       BOOL        :se giornaliero
 */
CREATE OR REPLACE FUNCTION ControllaTipoOrdine(ordine_id INT) RETURNS boolean LANGUAGE plpgsql AS $$
DECLARE
    tupla INT;
BEGIN
	SELECT codice INTO tupla FROM ordine, orario WHERE codice = ordine_id AND codice = ordine;
    IF (tupla) IS NOT NULL THEN RETURN TRUE; ELSE RETURN FALSE; END IF;
END
$$;
SELECT ControllaTipoOrdine(1);

/* CALCOLA IL COSTO TOTALE DI UN ORDINE
 * La funzione calcola il costo totale dato il codice univoco di un ordine.
 * Il calcolo del costo totale cambia a seconda della tipologia dell'ordine.
 * 
 * INPUT:   ordine_id       INT
 * OUTPUT:  costo_totale    DECIMAL
 */
CREATE OR REPLACE FUNCTION CalcolaCostoTotale(ordine_id INT) RETURNS DECIMAL(10, 2) LANGUAGE plpgsql AS $$
DECLARE
    costo_totale DECIMAL(10, 2);
BEGIN
    -- controllo la tipologia dell'ordine
    IF ControllaTipoOrdine(ordine_id)
    THEN -- se di tipo Orario
        SELECT n_ore_prenotate_totali * valore INTO costo_totale
        FROM ordine, orario WHERE codice = ordine_id AND codice = ordine;
    ELSE -- se di tipo Pacchetto
        SELECT t.valore INTO costo_totale FROM ordine AS o, pacchetto AS p, tipologia AS t 
        WHERE o.codice = ordine_id AND o.codice = p.ordine AND p.tipologia = t.nome;
    END IF;
    RETURN costo_totale;
END
$$;
SELECT CalcolaCostoTotale(6);

---------------------------------------------------------------------------------------------------

/* CONTA NUMERO DI CANZONI
 * La funzione conta il numero di canzoni della produzione di cui è fornito il codice.
 * 
 * INPUT:   codice_produzione   INTEGER
 * OUTPUT:  numero_canzoni      INTEGER
 */
CREATE OR REPLACE FUNCTION conta_canzoni_di_una_produzione(codice_produzione INTEGER) RETURNS INTEGER AS $$
DECLARE
    numero_canzoni INTEGER;
BEGIN
    -- Conta il numero di canzoni per la produzione specificata
    SELECT COUNT(*) INTO numero_canzoni
    FROM canzone WHERE produzione = codice_produzione;

    RETURN numero_canzoni;
END;
$$ LANGUAGE plpgsql;
SELECT conta_canzoni_di_una_produzione(1);

/* CALCOLA LUNGHEZZA CANZONI DI UNA PRODUZIONE
 * Dato il codice di una produzione, la funzione calcola la 
 * lunghezza media in secondi delle sue canzoni.
 * 
 * INPUT:   codice_produzione   INTEGER
 * OUTPUT:  lunghezza_media     NUMERIC
 */
CREATE OR REPLACE FUNCTION calcola_lunghezza_media_canzoni_di_una_produzione(codice_produzione INTEGER) RETURNS NUMERIC AS $$
DECLARE
    lunghezza_in_secondi_totale INTEGER;
    numero_canzoni INTEGER;
    lunghezza_in_secondi_media NUMERIC;
BEGIN
    -- Calcola la somma delle lunghezze delle canzoni per la produzione specificata
    SELECT SUM(lunghezza_in_secondi) INTO lunghezza_in_secondi_totale
    FROM canzone
    WHERE produzione = codice_produzione;

    
    SELECT conta_canzoni_di_una_produzione(codice_produzione) INTO numero_canzoni;
    -- Calcola la lunghezza media delle canzoni
    IF numero_canzoni > 0 THEN
        lunghezza_in_secondi_media := lunghezza_in_secondi_totale / numero_canzoni;
    ELSE
        -- Se non ci sono canzoni, la lunghezza media è 0
        lunghezza_in_secondi_media := 0;  
    END IF;

    RETURN lunghezza_in_secondi_media;
END;
$$ LANGUAGE plpgsql;
SELECT calcola_lunghezza_media_canzoni_di_una_produzione(1);