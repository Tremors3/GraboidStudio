-- Inserimento record per la tabella ARTISTA
INSERT INTO ARTISTA (nome_arte, data_di_registrazione) VALUES
('BandA', '2020-01-15'),
('BandB', '2019-04-20'),
('SingerX', '2019-05-20'),
('SingerY', '2018-11-10'),
('DJZ', '2021-07-30'),
('GroupC', '2021-02-14'),
('SoloArtistD', '2017-03-22');

-- Inserimento record per la tabella GRUPPO
INSERT INTO GRUPPO (artista, data_formazione) VALUES
('BandA', '2018-03-25'),
('BandB', '2017-06-15'),
('GroupC', '2020-09-05');

-- Inserimento record per la tabella SOLISTA
INSERT INTO SOLISTA (artista, codice_fiscale, nome, cognome, data_di_nascita, gruppo, data_adesione) VALUES
('SingerX', 'CF12345678901234', 'Alex', 'Rossi', '1990-06-15', NULL, NULL),
('SingerY', 'CF23456789012345', 'Elena', 'Verdi', '1992-07-18', NULL, NULL),
('DJZ', 'CF34567890123456', 'Marco', 'Bianchi', '1985-11-20', NULL, NULL),
('BandA', 'CF45678901234567', 'Luca', 'Bianchi', '1985-11-20', 'BandA', '2018-03-25'),
('BandB', 'CF56789012345678', 'Gianni', 'Rossi', '1988-04-12', 'BandB', '2017-06-15'),
('GroupC', 'CF67890123456789', 'Marta', 'Neri', '1991-09-25', 'GroupC', '2020-09-05');

-- Inserimento record per la tabella PARTECIPAZIONE_PASSATA
INSERT INTO PARTECIPAZIONE_PASSATA (gruppo, solista, data_adesione, data_fine_adesione) VALUES
('BandA', 'CF12345678901234', '2018-03-25', '2019-04-10'),
('BandB', 'CF23456789012345', '2017-06-15', '2018-07-22'),
('GroupC', 'CF34567890123456', '2020-09-05', '2021-08-30');

-- Inserimento record per la tabella EMAIL_A
INSERT INTO EMAIL_A (email, artista) VALUES
('contact@banda.com', 'BandA'),
('info@singerx.com', 'SingerX'),
('hello@bandb.com', 'BandB'),
('contact@singery.com', 'SingerY'),
('djz@music.com', 'DJZ'),
('groupc@music.com', 'GroupC'),
('soloartistd@music.com', 'SoloArtistD');

-- Inserimento record per la tabella TELEFONO_A
INSERT INTO TELEFONO_A (numero, artista) VALUES
('1234567890', 'BandA'),
('0987654321', 'SingerX'),
('1112223334', 'BandB'),
('2223334445', 'SingerY'),
('3334445556', 'DJZ'),
('4445556667', 'GroupC'),
('5556667778', 'SoloArtistD');

-- Inserimento record per la tabella TIPO_PRODUZIONE
INSERT INTO TIPO_PRODUZIONE (nome) VALUES
('Album'), 
('Singolo'), 
('EP'), 
('Live'), 
('Compilation');

-- Inserimento record per la tabella PRODUZIONE
INSERT INTO PRODUZIONE (codice, titolo, data_inizio, data_fine, stato, tipo_produzione) VALUES
(1, 'AlbumA', '2021-01-01', '2021-05-01', 'completato', 'Album'),
(2, 'SingoloX', '2021-06-01', '2021-06-15', 'completato', 'Singolo'),
(3, 'EP1', '2020-09-01', '2020-09-30', 'completato', 'EP'),
(4, 'Live in Concert', '2019-03-01', '2019-03-15', 'completato', 'Live'),
(5, 'Best of Compilation', '2021-11-01', '2021-12-01', 'completato', 'Compilation'),
(6, 'New Album', '2022-01-01', '2022-04-01', 'in produzione', 'Album'),
(7, 'Second EP', '2022-05-01', '2022-06-01', 'completato', 'EP');

-- Inserimento record per la tabella GENERE
INSERT INTO GENERE (nome) VALUES
('Rock'), 
('Pop'), 
('Jazz'), 
('Hip-Hop'), 
('Electronic');

-- Inserimento record per la tabella GENERE_PRODUZIONE
INSERT INTO GENERE_PRODUZIONE (genere, produzione) VALUES
('Rock', 1),
('Pop', 2),
('Jazz', 3),
('Rock', 4),
('Pop', 5),
('Hip-Hop', 6),
('Electronic', 7);

-- Inserimento record per la tabella CANZONE
INSERT INTO CANZONE (titolo, produzione, artista, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione) VALUES
('CanzoneA1', 1, 'BandA', 'Testo della CanzoneA1', '2021-02-01', 180, 'canzoneA1.mp3', '/music/banda', 'mp3'),
('CanzoneX1', 2, 'SingerX', 'Testo della CanzoneX1', '2021-06-05', 200, 'canzoneX1.mp3', '/music/singerx', 'mp3'),
('CanzoneB1', 3, 'BandB', 'Testo della CanzoneB1', '2020-09-10', 220, 'canzoneB1.mp3', '/music/bandb', 'mp3'),
('CanzoneY1', 4, 'SingerY', 'Testo della CanzoneY1', '2019-03-05', 240, 'canzoneY1.mp3', '/music/singery', 'mp3'),
('CanzoneZ1', 5, 'DJZ', 'Testo della CanzoneZ1', '2021-11-10', 180, 'canzoneZ1.mp3', '/music/djz', 'mp3'),
('CanzoneC1', 6, 'GroupC', 'Testo della CanzoneC1', '2022-02-01', 260, 'canzoneC1.mp3', '/music/groupc', 'mp3'),
('CanzoneD1', 7, 'SoloArtistD', 'Testo della CanzoneD1', '2022-05-10', 200, 'canzoneD1.mp3', '/music/soloartistd', 'mp3');

-- Inserimento record per la tabella PARTECIPAZIONE
INSERT INTO PARTECIPAZIONE (solista, canzone) VALUES
('CF56789012345678', 'canzoneA1.mp3'),
('CF12345678901234', 'canzoneX1.mp3'),
('CF67890123456789', 'canzoneB1.mp3'),
('CF23456789012345', 'canzoneY1.mp3'),
('CF34567890123456', 'canzoneZ1.mp3'),
('CF45678901234567', 'canzoneC1.mp3'),
('CF12345678901234', 'canzoneD1.mp3');

-- Inserimento record per la tabella PRODUTTORE
INSERT INTO PRODUTTORE (solista) VALUES
('CF12345678901234'),
('CF23456789012345'),
('CF34567890123456');

-- Inserimento record per la tabella CONDURRE
INSERT INTO CONDURRE (produttore, produzione) VALUES
('CF12345678901234', 1),
('CF23456789012345', 2),
('CF34567890123456', 3);

-- Inserimento record per la tabella OPERATORE
INSERT INTO OPERATORE (codice_fiscale, nome, cognome, data_di_nascita, data_di_assunzione, iban) VALUES
('CF11111111111111', 'Mario', 'Rossi', '1980-01-15', '2020-01-01', 'IT60X0542811101000000123456'),
('CF22222222222222', 'Anna', 'Verdi', '1985-02-20', '2019-03-01', 'IT60X0542811101000000654321'),
('CF33333333333333', 'Luigi', 'Bianchi', '1990-03-30', '2021-04-01', 'IT60X0542811101000000987654');

-- Inserimento record per la tabella EMAIL_O
INSERT INTO EMAIL_O (email, operatore) VALUES
('mario.rossi@studio.com', 'CF11111111111111'),
('anna.verdi@studio.com', 'CF22222222222222'),
('luigi.bianchi@studio.com', 'CF33333333333333');

-- Inserimento record per la tabella TELEFONO_O
INSERT INTO TELEFONO_O (numero, operatore) VALUES
('1231231234', 'CF11111111111111'),
('2342342345', 'CF22222222222222'),
('3453453456', 'CF33333333333333');

-- Inserimento record per la tabella ORDINE
INSERT INTO ORDINE (timestamp, artista, operatore, annullato) VALUES
('2023-01-01 10:00:00', 'BandA', 'CF11111111111111', FALSE),
('2023-02-01 11:00:00', 'SingerX', 'CF11111111111111', FALSE),
('2023-03-01 12:00:00', 'BandB', 'CF22222222222222', TRUE),
('2023-04-01 13:00:00', 'SingerY', 'CF22222222222222', FALSE),
('2023-05-01 14:00:00', 'DJZ', 'CF33333333333333', FALSE),
('2023-06-01 15:00:00', 'GroupC', 'CF33333333333333', FALSE),
('2023-07-01 16:00:00', 'SoloArtistD', 'CF11111111111111', FALSE);

-- Inserimento record per la tabella METODO
INSERT INTO METODO (nome) VALUES
('Carta di Credito'), 
('PayPal'), 
('Bonifico'), 
('Contanti');

-- Inserimento record per la tabella PAGAMENTO
INSERT INTO PAGAMENTO (ordine, metodo, stato, costo_totale) VALUES
('2023-01-01 10:00:00', 'Carta di Credito', 'completato', 1000.00),
('2023-02-01 11:00:00', 'PayPal', 'completato', 500.00),
('2023-03-01 12:00:00', 'Bonifico', 'annullato', 750.00),
('2023-04-01 13:00:00', 'Contanti', 'completato', 1200.00),
('2023-05-01 14:00:00', 'Carta di Credito', 'completato', 1500.00),
('2023-06-01 15:00:00', 'PayPal', 'completato', 800.00),
('2023-07-01 16:00:00', 'Bonifico', 'completato', 1100.00);

-- Inserimento record per la tabella TIPOLOGIA
INSERT INTO TIPOLOGIA (nome, valore, n_giorni) VALUES
('Standard', 500.00, 10),
('Premium', 1000.00, 20),
('Deluxe', 1500.00, 30),
('Basic', 300.00, 5);

-- Inserimento record per la tabella PACCHETTO
INSERT INTO PACCHETTO (ordine, tipologia, n_giorni_prenotati_totali) VALUES
('2023-01-01 10:00:00', 'Standard', 10),
('2023-02-01 11:00:00', 'Premium', 20),
('2023-03-01 12:00:00', 'Deluxe', 30),
('2023-04-01 13:00:00', 'Basic', 5),
('2023-05-01 14:00:00', 'Standard', 10),
('2023-06-01 15:00:00', 'Premium', 20),
('2023-07-01 16:00:00', 'Deluxe', 30);

-- Inserimento record per la tabella ORARIO
INSERT INTO ORARIO (ordine, n_ore_prenotate_totali, valore) VALUES
('2023-01-01 10:00:00', 100, 2000.00),
('2023-02-01 11:00:00', 150, 3000.00),
('2023-03-01 12:00:00', 200, 4000.00),
('2023-04-01 13:00:00', 50, 1000.00),
('2023-05-01 14:00:00', 120, 2400.00),
('2023-06-01 15:00:00', 180, 3600.00),
('2023-07-01 16:00:00', 220, 4400.00);

-- Inserimento record per la tabella SALA
INSERT INTO SALA (piano, numero) VALUES
(1, 101),
(1, 102),
(2, 201),
(2, 202),
(3, 301),
(3, 302),
(3, 303);

-- Inserimento record per la tabella PRENOTAZIONE
INSERT INTO PRENOTAZIONE (codice, pacchetto, sala_piano, sala_numero, annullata, giorno, tipo) VALUES
(1, '2023-01-01 10:00:00', 1, 101, FALSE, '2023-03-01', 'Standard'),
(2, '2023-02-01 11:00:00', 1, 102, FALSE, '2023-03-02', 'Premium'),
(3, '2023-03-01 12:00:00', 2, 201, TRUE, '2023-03-03', 'Deluxe'),
(4, '2023-04-01 13:00:00', 2, 202, FALSE, '2023-03-04', 'Basic'),
(5, '2023-05-01 14:00:00', 3, 301, FALSE, '2023-03-05', 'Standard'),
(6, '2023-06-01 15:00:00', 3, 302, FALSE, '2023-03-06', 'Premium'),
(7, '2023-07-01 16:00:00', 3, 303, FALSE, '2023-03-07', 'Deluxe');

-- Inserimento record per la tabella ORARIA
INSERT INTO ORARIA (prenotazione) VALUES
(1),
(2),
(4),
(5),
(6),
(7);

-- Inserimento record per la tabella FASCIA_ORARIA
INSERT INTO FASCIA_ORARIA (oraria, orario_inizio, orario_fine) VALUES
(1, '10:00:00', '12:00:00'),
(2, '14:00:00', '16:00:00'),
(4, '09:00:00', '11:00:00'),
(5, '11:00:00', '13:00:00'),
(6, '15:00:00', '17:00:00'),
(7, '17:00:00', '19:00:00');

-- Inserimento record per la tabella TIPO_TECNICO
INSERT INTO TIPO_TECNICO (nome) VALUES
('Audio'), 
('Luci'), 
('Video'), 
('Stage Manager');

-- Inserimento record per la tabella TECNICO
INSERT INTO TECNICO (codice_fiscale, sala_piano, sala_numero, tipo_tecnico, nome, cognome, data_di_nascita, data_di_assunzione, iban) VALUES
('CF22222222222222', 1, 101, 'Audio', 'Giulia', 'Verdi', '1992-02-20', '2021-05-01', 'IT60X0542811101000000654321'),
('CF33333333333333', 1, 102, 'Luci', 'Marco', 'Neri', '1988-04-22', '2020-06-15', 'IT60X0542811101000000876543'),
('CF44444444444444', 2, 201, 'Video', 'Luca', 'Bianchi', '1991-07-25', '2019-07-10', 'IT60X0542811101000000321654'),
('CF55555555555555', 2, 202, 'Stage Manager', 'Sara', 'Rossi', '1985-09-30', '2018-09-01', 'IT60X0542811101000000543210'),
('CF66666666666666', 3, 301, 'Audio', 'Paolo', 'Verdi', '1990-11-20', '2021-01-01', 'IT60X0542811101000000987654');

-- Inserimento record per la tabella EMAIL_T
INSERT INTO EMAIL_T (email, tecnico) VALUES
('giulia.verdi@studio.com', 'CF22222222222222'),
('marco.neri@studio.com', 'CF33333333333333'),
('luca.bianchi@studio.com', 'CF44444444444444'),
('sara.rossi@studio.com', 'CF55555555555555'),
('paolo.verdi@studio.com', 'CF66666666666666');

-- Inserimento record per la tabella TELEFONO_T
INSERT INTO TELEFONO_T (numero, tecnico) VALUES
('1111111111', 'CF22222222222222'),
('2222222222', 'CF33333333333333'),
('3333333333', 'CF44444444444444'),
('4444444444', 'CF55555555555555'),
('5555555555', 'CF66666666666666');
