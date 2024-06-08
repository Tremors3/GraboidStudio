/*IMMUTABLE, STABLE, VOLATILE
 * https://www.postgresql.org/docs/current/xfunc-volatility.html
*/
---------------------------------------------------------------------------------------------------

/* AGGIUNGE UN ARTISTA
 * La funzione crea il record di un artista con i parametri passati come argomento.
 *
 * INPUT:   nome_arte               VARCHAR(50)
 * INPUT:   data_registrazione      DATE
 */
CREATE OR REPLACE FUNCTION AggiungiArtista(nome_arte VARCHAR(50), data_registrazione DATE) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO ARTISTA (nome_arte, data_di_registrazione)
    VALUES (nome_arte, data_registrazione);
END
$$;
SELECT AggiungiArtista('Tremore', '2024-06-08');

---------------------------------------------------------------------------------------------------

/* CALCOLA L'ETA DELL'ARTISTA
 * La funzione calcola l'età dell'artista del quale è stato fornito il codice fiscale.
 *
 * INPUT:   cd      INT
 * OUTPUT:  eta     DECIMAL
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