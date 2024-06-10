CALCOLI E AGGREGAZIONI

    --Calcola la lunghezza media delle canzoni per una produzione.
   calculate_average_song_length(codice_produzione INTEGER) RETURNS INTEGER:

    -- Conta il numero di canzoni per una produzione.
   count_songs_in_production(codice_produzione INTEGER) RETURNS INTEGER:


CREATE OR REPLACE FUNCTION count_songs_in_production(codice_produzione INTEGER)
RETURNS INTEGER AS $$
DECLARE
    num_songs INTEGER;
BEGIN
    -- Conta il numero di canzoni per la produzione specificata
    SELECT COUNT(*)
    INTO num_songs
    FROM canzone
    WHERE produzione = codice_produzione;

    RETURN num_songs;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_average_song_length(codice_produzione INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    total_length INTEGER;
    num_songs INTEGER;
    avg_length NUMERIC;
BEGIN
    -- Calcola la somma delle lunghezze delle canzoni per la produzione specificata
    SELECT SUM(lunghezza_in_secondi)
    INTO total_length
    FROM canzone
    WHERE produzione = codice_produzione;

    -- Conta il numero di canzoni per la produzione specificata
    SELECT COUNT(*)
    INTO num_songs
    FROM canzone
    WHERE produzione = codice_produzione;

    -- Calcola la lunghezza media delle canzoni
    IF num_songs > 0 THEN
        avg_length := total_length / num_songs;
    ELSE
        avg_length := 0;  -- Se non ci sono canzoni, la lunghezza media è 0
    END IF;

    RETURN avg_length;
END;
$$ LANGUAGE plpgsql;




