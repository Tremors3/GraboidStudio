-- Popolamento della tabella ARTISTA
INSERT INTO ARTISTA (nome_arte, data_di_registrazione) VALUES
('BandABC', '2020-01-15'),
('SoloXYZ', '2019-07-23'),
('Group123', '2018-11-30');

-- Popolamento della tabella GRUPPO
INSERT INTO GRUPPO (artista, data_formazione) VALUES
('BandABC', '2020-01-15'),
('Group123', '2018-11-30');

-- Popolamento della tabella SOLISTA
INSERT INTO SOLISTA (artista, codice_fiscale, nome, cognome, data_di_nascita, gruppo, data_adesione) VALUES
('SoloXYZ', 'RSSMRA85M01H501Z', 'Mario', 'Rossi', '1985-03-01', NULL, NULL),
('SoloABC', 'VCTFNC90A01H501X', 'Francesco', 'Verdi', '1990-01-01', 'BandABC', '2020-01-20'),
('SoloDEF', 'BNCLRA92D01H501Y', 'Laura', 'Bianchi', '1992-04-01', 'Group123', '2018-12-05');

-- Popolamento della tabella PARTECIPAZIONE_PASSATA
INSERT INTO PARTECIPAZIONE_PASSATA (gruppo, solista, data_adesione, data_fine_adesione) VALUES
('BandABC', 'SoloXYZ', '2020-01-20', '2021-01-20');

-- Popolamento della tabella EMAIL_A
INSERT INTO EMAIL_A (email, artista) VALUES
('bandabc@example.com', 'BandABC'),
('soloxyz@example.com', 'SoloXYZ'),
('group123@example.com', 'Group123');

-- Popolamento della tabella TELEFONO_A
INSERT INTO TELEFONO_A (numero, artista) VALUES
('1234567890', 'BandABC'),
('0987654321', 'SoloXYZ'),
('1122334455', 'Group123');

-- Popolamento della tabella TIPO_PRODUZIONE
INSERT INTO TIPO_PRODUZIONE (nome) VALUES
('Album'), ('Singolo'), ('EP');

-- Popolamento della tabella GENERE
INSERT INTO GENERE (nome) VALUES
('Rock'), ('Pop'), ('Jazz');

-- Popolamento della tabella PRODUZIONE
INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
('Album 1', 'BandABC', '2020-02-01', '2020-06-01', 'Completo', 'Album', 'Rock'),
('Singolo 1', 'SoloXYZ', '2019-08-01', '2019-08-15', 'Completo', 'Singolo', 'Pop'),
('EP 1', 'Group123', '2018-12-01', '2019-01-01', 'Completo', 'EP', 'Jazz');

-- Popolamento della tabella CANZONE
INSERT INTO CANZONE (titolo, produzione, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione) VALUES
('Canzone 1', 1, 'Testo della canzone 1', '2020-02-10', 180, 'canzone1.mp3', '/musica/bandabc', 'mp3'),
('Canzone 2', 2, 'Testo della canzone 2', '2019-08-05', 210, 'canzone2.mp3', '/musica/soloxyz', 'mp3'),
('Canzone 3', 3, 'Testo della canzone 3', '2018-12-10', 240, 'canzone3.mp3', '/musica/group123', 'mp3');

-- Popolamento della tabella PARTECIPAZIONE
INSERT INTO PARTECIPAZIONE (solista, canzone, titolo_produzione, artista_produzione) VALUES
('SoloABC', 1, 'Album 1', 'BandABC'),
('SoloXYZ', 2, 'Singolo 1', 'SoloXYZ'),
('SoloDEF', 3, 'EP 1', 'Group123');

-- Popolamento della tabella PRODUTTORE
INSERT INTO PRODUTTORE (solista) VALUES
('SoloABC'), ('SoloXYZ');

-- Popolamento della tabella CONDURRE
INSERT INTO CONDURRE (produttore, produzione) VALUES
('SoloABC', 1), ('SoloXYZ', 2);

-- Popolamento della tabella OPERATORE
INSERT INTO OPERATORE (codice_fiscale, nome, cognome, data_di_nascita, data_di_assunzione, iban) VALUES
('OPRXYZ85M01H501Z', 'Marco', 'Neri', '1985-03-01', '2010-01-01', 'IT60X0542811101000000123456'),
('OPRABC90A01H501X', 'Giulia', 'Rossi', '1990-01-01', '2015-01-01', 'IT60X0542811101000000654321');

-- Popolamento della tabella EMAIL_O
INSERT INTO EMAIL_O (email, operatore) VALUES
('marconeri@example.com', 'OPRXYZ85M01H501Z'),
('giuliarossi@example.com', 'OPRABC90A01H501X');

-- Popolamento della tabella TELEFONO_O
INSERT INTO TELEFONO_O (numero, operatore) VALUES
('3331234567', 'OPRXYZ85M01H501Z'),
('3347654321', 'OPRABC90A01H501X');

-- Popolamento della tabella ORDINE
INSERT INTO ORDINE (timestamp, artista, annullato, operatore) VALUES
('2023-01-01 10:00:00', 'BandABC', FALSE, 'OPRXYZ85M01H501Z'),
('2023-01-02 11:00:00', 'SoloXYZ', FALSE, 'OPRABC90A01H501X');

-- Popolamento della tabella METODO
INSERT INTO METODO (nome) VALUES
('Carta di Credito'), ('PayPal'), ('Bonifico Bancario');

-- Popolamento della tabella PAGAMENTO
INSERT INTO PAGAMENTO (ordine, stato, costo_totale, metodo) VALUES
(1, 'Completato', 150.00, 'Carta di Credito'),
(2, 'Completato', 200.00, 'PayPal');

-- Popolamento della tabella TIPOLOGIA
INSERT INTO TIPOLOGIA (nome, valore, n_giorni) VALUES
('Standard', 50.00, 1), ('Premium', 100.00, 3);

-- Popolamento della tabella PACCHETTO
INSERT INTO PACCHETTO (ordine, tipologia, n_giorni_prenotati_totali) VALUES
(1, 'Standard', 1),
(2, 'Premium', 3);

-- Popolamento della tabella ORARIO
INSERT INTO ORARIO (ordine, n_ore_prenotate_totali, valore) VALUES
(1, 10, 500.00),
(2, 20, 1000.00);

-- Popolamento della tabella SALA
INSERT INTO SALA (piano, numero) VALUES
(1, 101), (2, 202);

-- Popolamento della tabella PRENOTAZIONE
INSERT INTO PRENOTAZIONE (annullata, giorno, tipo, pacchetto, sala_piano, sala_numero) VALUES
(FALSE, '2023-01-10', 'Registrazione', 1, 1, 101),
(FALSE, '2023-01-15', 'Missaggio', 2, 2, 202);

-- Popolamento della tabella ORARIA
INSERT INTO ORARIA (prenotazione) VALUES
(1), (2);

-- Popolamento della tabella FASCIA_ORARIA
INSERT INTO FASCIA_ORARIA (oraria, orario_inizio, orario_fine) VALUES
(1, '10:00:00', '12:00:00'),
(2, '14:00:00', '16:00:00');

-- Popolamento della tabella TIPO_TECNICO
INSERT INTO TIPO_TECNICO (nome) VALUES
('Audio Engineer'), ('Producer');

-- Popolamento della tabella TECNICO
INSERT INTO TECNICO (codice_fiscale, sala_piano, sala_numero, tipo_tecnico, nome, cognome, data_di_nascita, data_di_assunzione, iban) VALUES
('TCNAUD85M01H501Z', 1, 101, 'Audio Engineer', 'Luca', 'Verdi', '1985-03-01', '2010-01-01', 'IT60X0542811101000000123456'),
('TCNPRO90A01H501X', 2, 202, 'Producer', 'Sara', 'Bianchi', '1990-01-01', '2015-01-01', 'IT60X0542811101000000654321');

-- Popolamento della tabella EMAIL_T
INSERT INTO EMAIL_T (email, tecnico) VALUES
('lucaverdi@example.com', 'TCNAUD85M01H501Z'),
('sarabianchi@example.com', 'TCNPRO90A01H501X');

-- Popolamento della tabella TELEFONO_T
INSERT INTO TELEFONO_T (numero, tecnico) VALUES
('3331122334', 'TCNAUD85M01H501Z'),
('3344455667', 'TCNPRO90A01H501X');

-- Popolamento della tabella LAVORA_A
INSERT INTO LAVORA_A (tecnico, canzone) VALUES
('TCNAUD85M01H501Z', 1),
('TCNPRO90A01H501X', 2);
