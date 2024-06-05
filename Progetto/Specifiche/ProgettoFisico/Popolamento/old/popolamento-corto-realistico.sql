-- Inserimento record per la tabella ARTISTA
INSERT INTO ARTISTA (nome_arte, data_di_registrazione) VALUES
('BandA', '2020-01-15'),
('SingerX', '2019-05-20');

-- Inserimento record per la tabella GRUPPO
INSERT INTO GRUPPO (artista, data_formazione) VALUES
('BandA', '2018-03-25');

-- Inserimento record per la tabella SOLISTA
INSERT INTO SOLISTA (artista, codice_fiscale, nome, cognome, data_di_nascita, gruppo, data_adesione) VALUES
('SingerX', 'CF12345678901234', 'Alex', 'Rossi', '1990-06-15', NULL, NULL),
('BandA', 'CF56789012345678', 'Luca', 'Bianchi', '1985-11-20', 'BandA', '2018-03-25');

-- Inserimento record per la tabella PARTECIPAZIONE_PASSATA
INSERT INTO PARTECIPAZIONE_PASSATA (gruppo, solista, data_adesione, data_fine_adesione) VALUES
('BandA', 'CF12345678901234', '2018-03-25', '2019-04-10');

-- Inserimento record per la tabella EMAIL_A
INSERT INTO EMAIL_A (email, artista) VALUES
('contact@banda.com', 'BandA'),
('info@singerx.com', 'SingerX');

-- Inserimento record per la tabella TELEFONO_A
INSERT INTO TELEFONO_A (numero, artista) VALUES
('1234567890', 'BandA'),
('0987654321', 'SingerX');

-- Inserimento record per la tabella TIPO_PRODUZIONE
INSERT INTO TIPO_PRODUZIONE (nome) VALUES
('Album'), ('Singolo'), ('EP');

-- Inserimento record per la tabella PRODUZIONE
INSERT INTO PRODUZIONE (codice, titolo, data_inizio, data_fine, stato, tipo_produzione) VALUES
(1, 'AlbumA', '2021-01-01', '2021-05-01', 'completato', 'Album'),
(2, 'SingoloX', '2021-06-01', '2021-06-15', 'completato', 'Singolo');

-- Inserimento record per la tabella GENERE
INSERT INTO GENERE (nome) VALUES
('Rock'), ('Pop'), ('Jazz');

-- Inserimento record per la tabella GENERE_PRODUZIONE
INSERT INTO GENERE_PRODUZIONE (genere, produzione) VALUES
('Rock', 1),
('Pop', 2);

-- Inserimento record per la tabella CANZONE
INSERT INTO CANZONE (titolo, produzione, artista, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione) VALUES
('CanzoneA1', 1, 'BandA', 'Testo della CanzoneA1', '2021-02-01', 180, 'canzoneA1.mp3', '/music/banda', 'mp3'),
('CanzoneX1', 2, 'SingerX', 'Testo della CanzoneX1', '2021-06-05', 200, 'canzoneX1.mp3', '/music/singerx', 'mp3');

-- Inserimento record per la tabella PARTECIPAZIONE
INSERT INTO PARTECIPAZIONE (solista, canzone) VALUES
('CF56789012345678', 'canzoneA1.mp3'),
('CF12345678901234', 'canzoneX1.mp3');

-- Inserimento record per la tabella PRODUTTORE
INSERT INTO PRODUTTORE (solista) VALUES
('CF12345678901234');

-- Inserimento record per la tabella CONDURRE
INSERT INTO CONDURRE (produttore, produzione) VALUES
('CF12345678901234', 1);

-- Inserimento record per la tabella OPERATORE
INSERT INTO OPERATORE (codice_fiscale, nome, cognome, data_di_nascita, data_di_assunzione, iban) VALUES
('CF11111111111111', 'Mario', 'Rossi', '1980-01-15', '2020-01-01', 'IT60X0542811101000000123456');

-- Inserimento record per la tabella EMAIL_O
INSERT INTO EMAIL_O (email, operatore) VALUES
('mario.rossi@studio.com', 'CF11111111111111');

-- Inserimento record per la tabella TELEFONO_O
INSERT INTO TELEFONO_O (numero, operatore) VALUES
('1231231234', 'CF11111111111111');

-- Inserimento record per la tabella ORDINE
INSERT INTO ORDINE (timestamp, artista, operatore, annullato) VALUES
('2023-01-01 10:00:00', 'BandA', 'CF11111111111111', FALSE),
('2023-02-01 11:00:00', 'SingerX', 'CF11111111111111', FALSE);

-- Inserimento record per la tabella METODO
INSERT INTO METODO (nome) VALUES
('Carta di Credito'), ('PayPal'), ('Bonifico');

-- Inserimento record per la tabella PAGAMENTO
INSERT INTO PAGAMENTO (ordine, metodo, stato, costo_totale) VALUES
('2023-01-01 10:00:00', 'Carta di Credito', 'completato', 1000.00),
('2023-02-01 11:00:00', 'PayPal', 'completato', 500.00);

-- Inserimento record per la tabella TIPOLOGIA
INSERT INTO TIPOLOGIA (nome, valore, n_giorni) VALUES
('Standard', 500.00, 10),
('Premium', 1000.00, 20);

-- Inserimento record per la tabella PACCHETTO
INSERT INTO PACCHETTO (ordine, tipologia, n_giorni_prenotati_totali) VALUES
('2023-01-01 10:00:00', 'Standard', 10),
('2023-02-01 11:00:00', 'Premium', 20);

-- Inserimento record per la tabella ORARIO
INSERT INTO ORARIO (ordine, n_ore_prenotate_totali, valore) VALUES
('2023-01-01 10:00:00', 100, 2000.00);

-- Inserimento record per la tabella SALA
INSERT INTO SALA (piano, numero) VALUES
(1, 101),
(1, 102);

-- Inserimento record per la tabella PRENOTAZIONE
INSERT INTO PRENOTAZIONE (codice, pacchetto, sala_piano, sala_numero, annullata, giorno, tipo) VALUES
(1, '2023-01-01 10:00:00', 1, 101, FALSE, '2023-03-01', 'Standard'),
(2, '2023-02-01 11:00:00', 1, 102, FALSE, '2023-03-02', 'Premium');

-- Inserimento record per la tabella ORARIA
INSERT INTO ORARIA (prenotazione) VALUES
(1),
(2);

-- Inserimento record per la tabella FASCIA_ORARIA
INSERT INTO FASCIA_ORARIA (oraria, orario_inizio, orario_fine) VALUES
(1, '10:00:00', '12:00:00'),
(2, '14:00:00', '16:00:00');

-- Inserimento record per la tabella TIPO_TECNICO
INSERT INTO TIPO_TECNICO (nome) VALUES
('Audio'), ('Luci');

-- Inserimento record per la tabella TECNICO
INSERT INTO TECNICO (codice_fiscale, sala_piano, sala_numero, tipo_tecnico, nome, cognome, data_di_nascita, data_di_assunzione, iban) VALUES
('CF22222222222222', 1, 101, 'Audio', 'Giulia', 'Verdi', '1992-02-20', '2021-05-01', 'IT60X0542811101000000654321');

-- Inserimento record per la tabella EMAIL_T
INSERT INTO EMAIL_T (email, tecnico) VALUES
('giulia.verdi@studio.com', 'CF22222222222222');

-- Inserimento record per la tabella TELEFONO_T
INSERT INTO TELEFONO_T (numero, tecnico) VALUES
('3213214321', 'CF22222222222222');

-- Inserimento record per la tabella LAVORA_A
INSERT INTO LAVORA_A (tecnico, canzone) VALUES
('CF22222222222222', 'canzoneA1.mp3');
