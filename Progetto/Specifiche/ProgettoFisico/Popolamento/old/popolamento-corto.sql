INSERT INTO ARTISTA (nome_arte, data_di_registrazione)
VALUES
('Artista1', '2023-01-01'),
('Artista2', '2023-02-01'),
('Artista3', '2023-03-01'),
('Artista4', '2023-04-01');

INSERT INTO GRUPPO (artista, data_formazione)
VALUES
('Artista1', '2022-01-01'),
('Artista2', '2022-02-01');

INSERT INTO SOLISTA (artista, codice_fiscale, nome, cognome, data_di_nascita, gruppo, data_adesione)
VALUES
('Artista3', 'CF1234567890', 'Nome1', 'Cognome1', '1990-01-01', 'Artista1', '2022-05-01'),
('Artista4', 'CF0987654321', 'Nome2', 'Cognome2', '1992-02-01', NULL, NULL);

INSERT INTO PARTECIPAZIONE_PASSATA (gruppo, solista, data_adesione, data_fine_adesione)
VALUES
('Artista1', 'Artista3', '2020-01-01', '2021-01-01');

INSERT INTO EMAIL_ARTISTA (email, artista)
VALUES
('artista1@example.com', 'Artista1'),
('artista2@example.com', 'Artista2');

INSERT INTO TELEFONO_ARTISTA (numero, artista)
VALUES
('1234567890', 'Artista1'),
('0987654321', 'Artista2');

INSERT INTO TIPO_PRODUZIONE (nome)
VALUES
('Album'), ('Singolo'), ('EP');

INSERT INTO PRODUZIONE (codice, titolo, data_inizio, data_fine, stato, tipo_produzione)
VALUES
(1, 'Produzione1', '2023-01-01', '2023-06-01', 'completato', 'Album'),
(2, 'Produzione2', '2023-02-01', '2023-07-01', 'in corso', 'Singolo');

INSERT INTO GENERE (nome)
VALUES
('Pop'), ('Rock'), ('Jazz');

INSERT INTO GENERE_PRODUZIONE (genere, produzione)
VALUES
('Pop', 1), ('Rock', 2);

INSERT INTO CANZONE (titolo, produzione, artista, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione)
VALUES
('Canzone1', 1, 'Artista1', 'Testo della Canzone1', '2023-01-15', 180, 'canzone1.mp3', '/musica/canzone1', 'mp3'),
('Canzone2', 2, 'Artista2', 'Testo della Canzone2', '2023-02-15', 200, 'canzone2.mp3', '/musica/canzone2', 'mp3');

INSERT INTO PARTECIPAZIONE (solista, canzone)
VALUES
('Artista3', 'Canzone1'),
('Artista4', 'Canzone2');

INSERT INTO PRODUTTORE (solista)
VALUES
('Artista3'),
('Artista4');

INSERT INTO CONDURRE (produttore, produzione)
VALUES
('Artista3', 1),
('Artista4', 2);

INSERT INTO OPERATORE (codice_fiscale, nome, cognome, data_di_nascita, data_di_assunzione, iban)
VALUES
('CF5432109876', 'Operatore1', 'Cognome1', '1985-05-05', '2022-01-01', 'IT60X0542811101000000123456'),
('CF6543210987', 'Operatore2', 'Cognome2', '1987-07-07', '2022-02-01', 'IT60X0542811101000000654321');

INSERT INTO EMAIL_OPERATORE (email, operatore)
VALUES
('operatore1@example.com', 'CF5432109876'),
('operatore2@example.com', 'CF6543210987');

INSERT INTO TELEFONO_OPERATORE (numero, operatore)
VALUES
('3216549870', 'CF5432109876'),
('9876543210', 'CF6543210987');

INSERT INTO ORDINE (timestamp, artista, operatore, annullato)
VALUES
('2023-05-01 10:00:00', 'Artista1', 'CF5432109876', FALSE),
('2023-05-02 11:00:00', 'Artista2', 'CF6543210987', TRUE);

INSERT INTO METODO (nome)
VALUES
('Carta di Credito'), ('PayPal'), ('Bonifico');

INSERT INTO PAGAMENTO (ordine, metodo, stato, costo_totale)
VALUES
('2023-05-01 10:00:00', 'Carta di Credito', 'completato', 100.00),
('2023-05-02 11:00:00', 'PayPal', 'fallito', 50.00);

INSERT INTO TIPOLOGIA (nome, valore, n_giorni)
VALUES
('Base', 200.00, 30), ('Premium', 500.00, 90);

INSERT INTO PACCHETTO (ordine, tipologia, n_giorni_prenotati_totali)
VALUES
('2023-05-01 10:00:00', 'Base', 30),
('2023-05-02 11:00:00', 'Premium', 90);

INSERT INTO ORARIO (ordine, n_ore_prenotate_totali, valore)
VALUES
('2023-05-01 10:00:00', 8, 80.00),
('2023-05-02 11:00:00', 10, 100.00);

INSERT INTO SALA (piano, numero)
VALUES
(1, 101), (2, 202);

INSERT INTO PRENOTAZIONE (codice, pacchetto, sala_piano, sala_numero, annullata, giorno, tipo)
VALUES
(1, '2023-05-01 10:00:00', 1, 101, FALSE, '2023-06-01', 'giornaliera'),
(2, '2023-05-02 11:00:00', 2, 202, TRUE, '2023-07-01', 'oraria');

INSERT INTO ORARIA (prenotazione)
VALUES
(2);

INSERT INTO FASCIA_ORARIA (oraria, orario_inizio, orario_fine)
VALUES
(2, '10:00:00', '12:00:00'),
(2, '14:00:00', '16:00:00');