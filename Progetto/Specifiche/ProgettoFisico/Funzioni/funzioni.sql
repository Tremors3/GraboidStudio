-- A deterministic function must return the same value on two distinct invocations if the arguments provided to the two invocations are the same
--You must specify this keyword if you intend to invoke the function in the expression of a function-based index, in a virtual column definition, or from the query of a materialized view that is marked REFRESH FAST or ENABLE QUERY REWRITE. When the database encounters a deterministic function, it tries to use previously calculated results when possible rather than reexecuting the function. If you change the function, then you must manually rebuild all dependent function-based indexes and materialized views. 
CREATE FUNCTION CalcolaEtaArtista(codice_fiscale VARCHAR(16))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE data_nascita DATE;
    DECLARE eta INT;

    SELECT data_di_nascita INTO data_nascita
    FROM SOLISTA
    WHERE codice_fiscale = codice_fiscale;

    SET eta = TIMESTAMPDIFF(YEAR, data_nascita, CURDATE());

    RETURN eta;
END;

CREATE FUNCTION CalcolaCostoTotale(ordine_id INT)
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE costo_totale DECIMAL(10, 2);
    -- to do

    RETURN costo_totale;
END;
