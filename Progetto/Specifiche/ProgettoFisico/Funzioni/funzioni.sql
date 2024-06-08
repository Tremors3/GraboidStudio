-- A deterministic function must return the same value on two distinct invocations if the arguments provided to the two invocations are the same
--You must specify this keyword if you intend to invoke the function in the expression of a function-based index, in a virtual column definition, or from the query of a materialized view that is marked REFRESH FAST or ENABLE QUERY REWRITE. When the database encounters a deterministic function, it tries to use previously calculated results when possible rather than reexecuting the function. If you change the function, then you must manually rebuild all dependent function-based indexes and materialized views. 

/* CALCOLA L'ETA DELL'ARTISTA
 *
 */
CREATE FUNCTION CalcolaEtaArtista(codice_fiscale VARCHAR(16)) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE data_nascita DATE;
    DECLARE eta INT;

    SELECT data_di_nascita INTO data_nascita
    FROM SOLISTA
    WHERE codice_fiscale = codice_fiscale;

    SET eta = TIMESTAMPDIFF(YEAR, data_nascita, CURDATE());

    RETURN eta;
END;

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
SELECT ControllaTipoOrdine(5);

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
SELECT CalcolaCostoTotale(10);