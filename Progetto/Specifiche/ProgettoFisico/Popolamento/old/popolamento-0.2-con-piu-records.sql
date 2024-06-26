-- Popolamento della tabella ARTISTA
INSERT INTO ARTISTA (nome_arte, data_di_registrazione) VALUES
('BandABC', '2020-01-15'),
('SoloXYZ', '2019-07-23'),
('Group123', '2018-11-30'),
('DuoLMN', '2021-02-14'),
('SoloPQR', '2017-05-18'),
('TrioUVW', '2019-09-25'),
('BandDEF', '2020-03-10'),
('SoloGHI', '2018-06-20'),
('GroupJKL', '2019-04-12'),
('DuoMNO', '2021-07-22');

-- Popolamento della tabella GRUPPO
INSERT INTO GRUPPO (artista, data_formazione) VALUES
('BandABC', '2020-01-15'),
('Group123', '2018-11-30'),
('DuoLMN', '2021-02-14'),
('TrioUVW', '2019-09-25'),
('BandDEF', '2020-03-10'),
('GroupJKL', '2019-04-12'),
('DuoMNO', '2021-07-22');

-- Popolamento della tabella SOLISTA
INSERT INTO SOLISTA (artista, codice_fiscale, nome, cognome, data_di_nascita, gruppo, data_adesione) VALUES
('SoloXYZ', 'RSSMRA85M01H501Z', 'Mario', 'Rossi', '1985-03-01', NULL, NULL),
('SoloABC', 'VCTFNC90A01H501X', 'Francesco', 'Verdi', '1990-01-01', 'BandABC', '2020-01-20'),
('SoloDEF', 'BNCLRA92D01H501Y', 'Laura', 'Bianchi', '1992-04-01', 'Group123', '2018-12-05'),
('SoloPQR', 'RSSMNB85M01H501Z', 'Giovanni', 'Russo', '1987-07-10', NULL, NULL),
('SoloGHI', 'MRTPLN90A01H501X', 'Anna', 'Mariani', '1990-05-01', 'BandDEF', '2020-03-15'),
('SoloJKL', 'CNCMRS92D01H501Y', 'Marco', 'Cannavaro', '1992-08-01', 'GroupJKL', '2019-04-15'),
('SoloSTU', 'FRTRLA89L01H501Z', 'Lucia', 'Ferrari', '1989-11-12', 'TrioUVW', '2019-10-01');

-- Popolamento della tabella PARTECIPAZIONE_PASSATA
INSERT INTO PARTECIPAZIONE_PASSATA (gruppo, solista, data_adesione, data_fine_adesione) VALUES
('BandABC', 'SoloXYZ', '2020-01-20', '2021-01-20'),
('Group123', 'SoloDEF', '2018-12-05', '2020-01-10'),
('TrioUVW', 'SoloSTU', '2019-10-01', '2020-05-25');

-- Popolamento della tabella EMAIL_A
INSERT INTO EMAIL_A (email, artista) VALUES
('bandabc@example.com', 'BandABC'),
('soloxyz@example.com', 'SoloXYZ'),
('group123@example.com', 'Group123'),
('duolmn@example.com', 'DuoLMN'),
('solopqr@example.com', 'SoloPQR'),
('triouvw@example.com', 'TrioUVW'),
('banddef@example.com', 'BandDEF'),
('sologhi@example.com', 'SoloGHI'),
('groupjkl@example.com', 'GroupJKL'),
('duomno@example.com', 'DuoMNO');

-- Popolamento della tabella TELEFONO_A
INSERT INTO TELEFONO_A (numero, artista) VALUES
('1234567890', 'BandABC'),
('0987654321', 'SoloXYZ'),
('1122334455', 'Group123'),
('2233445566', 'DuoLMN'),
('3344556677', 'SoloPQR'),
('4455667788', 'TrioUVW'),
('5566778899', 'BandDEF'),
('6677889900', 'SoloGHI'),
('7788990011', 'GroupJKL'),
('8899001122', 'DuoMNO');

-- Popolamento della tabella TIPO_PRODUZIONE
INSERT INTO TIPO_PRODUZIONE (nome) VALUES
('Album'), ('Singolo'), ('EP'), ('Compilation');

-- Popolamento della tabella GENERE
INSERT INTO GENERE (nome) VALUES
('Rock'), ('Pop'), ('Jazz'), ('Classical'), ('Hip Hop'), ('Electronic');

-- Popolamento della tabella PRODUZIONE
INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere) VALUES
('Album 1', 'BandABC', '2020-02-01', '2020-06-01', 'Completo', 'Album', 'Rock'),
('Singolo 1', 'SoloXYZ', '2019-08-01', '2019-08-15', 'Completo', 'Singolo', 'Pop'),
('EP 1', 'Group123', '2018-12-01', '2019-01-01', 'Completo', 'EP', 'Jazz'),
('Compilation 1', 'DuoLMN', '2021-03-01', '2021-04-01', 'Completo', 'Compilation', 'Classical'),
('Album 2', 'SoloPQR', '2017-06-01', '2017-10-01', 'Completo', 'Album', 'Hip Hop'),
('Singolo 2', 'TrioUVW', '2019-10-10', '2019-10-20', 'Completo', 'Singolo', 'Electronic'),
('EP 2', 'BandDEF', '2020-04-01', '2020-05-01', 'Completo', 'EP', 'Rock'),
('Album 3', 'SoloGHI', '2018-07-01', '2018-11-01', 'Completo', 'Album', 'Pop'),
('Singolo 3', 'GroupJKL', '2019-05-01', '2019-05-15', 'Completo', 'Singolo', 'Jazz'),
('EP 3', 'DuoMNO', '2021-08-01', '2021-09-01', 'Completo', 'EP', 'Classical');

-- Popolamento della tabella CANZONE
INSERT INTO CANZONE (titolo, produzione, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione) VALUES
('Canzone 1', 1, 'Testo della canzone 1', '2020-02-10', 180, 'canzone1.mp3', '/musica/bandabc', 'mp3'),
('Canzone 2', 2, 'Testo della canzone 2', '2019-08-05', 210, 'canzone2.mp3', '/musica/soloxyz', 'mp3'),
('Canzone 3', 3, 'Testo della canzone 3', '2018-12-10', 240, 'canzone3.mp3', '/musica/group123', 'mp3'),
('Canzone 4', 4, 'Testo della canzone 4', '2021-03-10', 200, 'canzone4.mp3', '/musica/duolmn', 'mp3'),
('Canzone 5', 5, 'Testo della canzone 5', '2017-07-01', 190, 'canzone5.mp3', '/musica/solopqr', 'mp3'),
('Canzone 6', 6, 'Testo della canzone 6', '2019-10-15', 220, 'canzone6.mp3', '/musica/triouvw', 'mp3'),
('Canzone 7', 7, 'Testo della canzone 7', '2020-04-05', 230, 'canzone7.mp3', '/musica/banddef', 'mp3'),
('Canzone 8', 8, 'Testo della canzone 8', '2018-07-15', 250, 'canzone8.mp3', '/musica/sologhi', 'mp3'),
('Canzone 9', 9, 'Testo della canzone 9', '2019-05-10', 260, 'canzone9.mp3', '/musica/groupjkl', 'mp3'),
('Canzone 10', 10, 'Testo della canzone 10', '2021-08-10', 270, 'canzone10.mp3', '/musica/duomno', 'mp3');

-- Popolamento della tabella PARTECIPAZIONE
INSERT INTO PARTECIPAZIONE (solista, canzone, titolo_produzione, artista_produzione) VALUES
('SoloABC', 1, 'Album 1', 'BandABC'),
('SoloXYZ', 2, 'Singolo 1', 'SoloXYZ'),
('SoloDEF', 3, 'EP 1', 'Group123'),
('SoloPQR', 4, 'Compilation 1', 'DuoLMN'),
('SoloGHI', 5, 'Album 2', 'SoloPQR'),
('SoloSTU', 6, 'Singolo 2', 'TrioUVW'),
('SoloJKL', 7, 'EP 2', 'BandDEF'),
('SoloGHI', 8, 'Album 3', 'SoloGHI'),
('SoloXYZ', 9, 'Singolo 3', 'GroupJKL'),
('SoloABC', 10, 'EP 3', 'DuoMNO');

-- Popolamento della tabella PRODUTTORE
INSERT INTO PRODUTTORE (solista) VALUES
('SoloABC'), ('SoloXYZ'), ('SoloDEF'), ('SoloPQR'), ('SoloGHI');

-- Popolamento della tabella CONDURRE
INSERT INTO CONDURRE (produttore, produzione) VALUES
('SoloABC', 1), ('SoloXYZ', 2), ('SoloDEF', 3), ('SoloPQR', 4), ('SoloGHI', 5);

-- Popolamento della tabella OPERATORE
INSERT INTO OPERATORE (codice_fiscale, nome, cognome, data_di_nascita, data_di_assunzione, iban) VALUES
('OPRXYZ85M01H501Z', 'Marco', 'Neri', '1985-03-01', '2010-01-01', 'IT60X0542811101000000123456'),
('OPRABC90A01H501X', 'Giulia', 'Rossi', '1990-01-01', '2015-01-01', 'IT60X0542811101000000654321'),
('OPRPQR85M01H501Z', 'Luca', 'Bianchi', '1985-06-15', '2012-03-01', 'IT60X0542811101000000789101'),
('OPRDEF90A01H501X', 'Elena', 'Verdi', '1990-11-20', '2017-05-15', 'IT60X0542811101000000432198'),
('OPRGHI85M01H501Z', 'Chiara', 'Russo', '1985-09-25', '2013-08-20', 'IT60X0542811101000000543210');

-- Popolamento della tabella EMAIL_O
INSERT INTO EMAIL_O (email, operatore) VALUES
('marconeri@example.com', 'OPRXYZ85M01H501Z'),
('giuliarossi@example.com', 'OPRABC90A01H501X'),
('lucabianchi@example.com', 'OPRPQR85M01H501Z'),
('elenaverdi@example.com', 'OPRDEF90A01H501X'),
('chiararusso@example.com', 'OPRGHI85M01H501Z');

-- Popolamento della tabella TELEFONO_O
INSERT INTO TELEFONO_O (numero, operatore) VALUES
('3331234567', 'OPRXYZ85M01H501Z'),
('3347654321', 'OPRABC90A01H501X'),
('3358765432', 'OPRPQR85M01H501Z'),
('3369876543', 'OPRDEF90A01H501X'),
('3379988776', 'OPRGHI85M01H501Z');

-- Popolamento della tabella ORDINE
INSERT INTO ORDINE (timestamp, artista, annullato, operatore) VALUES
('2023-01-01 10:00:00', 'BandABC', FALSE, 'OPRXYZ85M01H501Z'),
('2023-01-02 11:00:00', 'SoloXYZ', FALSE, 'OPRABC90A01H501X'),
('2023-01-03 12:00:00', 'Group123', FALSE, 'OPRPQR85M01H501Z'),
('2023-01-04 13:00:00', 'DuoLMN', FALSE, 'OPRDEF90A01H501X'),
('2023-01-05 14:00:00', 'SoloPQR', FALSE, 'OPRGHI85M01H501Z'),
('2023-01-06 15:00:00', 'TrioUVW', FALSE, 'OPRXYZ85M01H501Z'),
('2023-01-07 16:00:00', 'BandDEF', FALSE, 'OPRABC90A01H501X'),
('2023-01-08 17:00:00', 'SoloGHI', FALSE, 'OPRPQR85M01H501Z'),
('2023-01-09 18:00:00', 'GroupJKL', FALSE, 'OPRDEF90A01H501X'),
('2023-01-10 19:00:00', 'DuoMNO', FALSE, 'OPRGHI85M01H501Z');

-- Popolamento della tabella METODO
INSERT INTO METODO (nome) VALUES
('Carta di Credito'), ('PayPal'), ('Bonifico Bancario'), ('Contanti');

-- Popolamento della tabella PAGAMENTO
INSERT INTO PAGAMENTO (ordine, stato, costo_totale, metodo) VALUES
(1, 'Completato', 150.00, 'Carta di Credito'),
(2, 'Completato', 200.00, 'PayPal'),
(3, 'Completato', 250.00, 'Bonifico Bancario'),
(4, 'Completato', 300.00, 'Contanti'),
(5, 'Completato', 350.00, 'Carta di Credito'),
(6, 'Completato', 400.00, 'PayPal'),
(7, 'Completato', 450.00, 'Bonifico Bancario'),
(8, 'Completato', 500.00, 'Contanti'),
(9, 'Completato', 550.00, 'Carta di Credito'),
(10, 'Completato', 600.00, 'PayPal');

-- Popolamento della tabella TIPOLOGIA
INSERT INTO TIPOLOGIA (nome, valore, n_giorni) VALUES
('Standard', 50.00, 1), ('Premium', 100.00, 3), ('Deluxe', 150.00, 5), ('Ultimate', 200.00, 7);

-- Popolamento della tabella PACCHETTO
INSERT INTO PACCHETTO (ordine, tipologia, n_giorni_prenotati_totali) VALUES
(1, 'Standard', 1),
(2, 'Premium', 3),
(3, 'Deluxe', 5),
(4, 'Ultimate', 7),
(5, 'Standard', 1),
(6, 'Premium', 3),
(7, 'Deluxe', 5),
(8, 'Ultimate', 7),
(9, 'Standard', 1),
(10, 'Premium', 3);

-- Popolamento della tabella ORARIO
INSERT INTO ORARIO (ordine, n_ore_prenotate_totali, valore) VALUES
(1, 10, 500.00),
(2, 20, 1000.00),
(3, 30, 1500.00),
(4, 40, 2000.00),
(5, 10, 500.00),
(6, 20, 1000.00),
(7, 30, 1500.00),
(8, 40, 2000.00),
(9, 10, 500.00),
(10, 20, 1000.00);

-- Popolamento della tabella SALA
INSERT INTO SALA (piano, numero) VALUES
(1, 101), (2, 202), (3, 303), (4, 404), (5, 505);

-- Popolamento della tabella PRENOTAZIONE
INSERT INTO PRENOTAZIONE (annullata, giorno, tipo, pacchetto, sala_piano, sala_numero) VALUES
(FALSE, '2023-01-10', 'Registrazione', 1, 1, 101),
(FALSE, '2023-01-15', 'Missaggio', 2, 2, 202),
(FALSE, '2023-01-20', 'Mastering', 3, 3, 303),
(FALSE, '2023-01-25', 'Registrazione', 4, 4, 404),
(FALSE, '2023-01-30', 'Missaggio', 5, 5, 505),
(FALSE, '2023-02-04', 'Mastering', 6, 1, 101),
(FALSE, '2023-02-09', 'Registrazione', 7, 2, 202),
(FALSE, '2023-02-14', 'Missaggio', 8, 3, 303),
(FALSE, '2023-02-19', 'Mastering', 9, 4, 404),
(FALSE, '2023-02-24', 'Registrazione', 10, 5, 505);

-- Popolamento della tabella TECNICO
INSERT INTO TECNICO (codice_fiscale, sala_piano, sala_numero, ruolo, nome, cognome, data_di_nascita, data_di_assunzione, iban) VALUES
('TCNAUD85M01H501Z', 1, 101, 'Audio Engineer', 'Luca', 'Verdi', '1985-03-01', '2010-01-01', 'IT60X0542811101000000123456'),
('TCNPRO90A01H501X', 2, 202, 'Producer', 'Sara', 'Bianchi', '1990-01-01', '2015-01-01', 'IT60X0542811101000000654321'),
('TCNAUD92D01H501Y', 3, 303, 'Audio Engineer', 'Giovanni', 'Russo', '1992-04-01', '2012-02-01', 'IT60X0542811101000000765432'),
('TCNPRO88M01H501Z', 4, 404, 'Producer', 'Marco', 'Neri', '1988-05-15', '2013-05-01', 'IT60X0542811101000000543210'),
('TCNAUD90A01H501X', 5, 505, 'Audio Engineer', 'Elena', 'Verdi', '1990-11-20', '2016-03-01', 'IT60X0542811101000000987654');

-- Popolamento della tabella EMAIL_T
INSERT INTO EMAIL_T (email, tecnico) VALUES
('lucaverdi@example.com', 'TCNAUD85M01H501Z'),
('sarabianchi@example.com', 'TCNPRO90A01H501X'),
('giovannirusso@example.com', 'TCNAUD92D01H501Y'),
('marconeri@example.com', 'TCNPRO88M01H501Z'),
('elenaverdi@example.com', 'TCNAUD90A01H501X');

-- Popolamento della tabella TELEFONO_T
INSERT INTO TELEFONO_T (numero, tecnico) VALUES
('3331122334', 'TCNAUD85M01H501Z'),
('3344455667', 'TCNPRO90A01H501X'),
('3355544333', 'TCNAUD92D01H501Y'),
('3366677889', 'TCNPRO88M01H501Z'),
('3377788990', 'TCNAUD90A01H501X');

-- Popolamento della tabella LAVORA_A
INSERT INTO LAVORA_A (tecnico, canzone) VALUES
('TCNAUD85M01H501Z', 1),
('TCNPRO90A01H501X', 2),
('TCNAUD92D01H501Y', 3),
('TCNPRO88M01H501Z', 4),
('TCNAUD90A01H501X', 5),
('TCNAUD85M01H501Z', 6),
('TCNPRO90A01H501X', 7),
('TCNAUD92D01H501Y', 8),
('TCNPRO88M01H501Z', 9),
('TCNAUD90A01H501X', 10);
