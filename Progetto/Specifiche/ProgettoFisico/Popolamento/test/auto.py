import random

import psycopg2
from faker import Faker
import random

# Crea un'istanza di Faker
fake = Faker()

# Connessione al database PostgreSQL
c = psycopg2.connect(
    dbname="test",
    user="postgres",
    password="",
    host="localhost",
    port="5432"
)
cu = c.cursor()


def truncate_table(table_name):
    try:
        cu.execute(f"TRUNCATE TABLE {table_name} CASCADE;")
        print(f"Tabelle {table_name} svuotate.")
    except Exception as e:
        c.rollback()
        print(f"Errore durante lo svuotamento di {table_name}: {e}")

def clean_database():
    tables_to_clean = [
        'LAVORA_A',
        'TELEFONO_T',
        'EMAIL_T',
        'TECNICO',
        'TIPO_TECNICO',
        'FASCIA_ORARIA',
        'ORARIA',
        'PAGAMENTO',
        'METODO',
        'ORDINE',
        'SALA',
        'PRENOTAZIONE',
        'ORARIO',
        'PACCHETTO',
        'TIPOLOGIA',
        'TELEFONO_O',
        'EMAIL_O',
        'OPERATORE',
        'CANZONE',
        'PRODUTTORE',
        'CONDURRE',
        'PRODUZIONE',
        'GENERI',
        'TIPO_PRODUZIONE',
        'PARTECIPAZIONE',
        'GRUPPO',
        'ARTISTA',
        'SOLISTA',
        'PARTECIPAZIONE_PASSATA'
    ]
    
    for table_name in tables_to_clean:
        truncate_table(table_name)
    
    # Committa le modifiche e chiude la connessione
    c.commit()
    c.close()
    print("Database pulito")

'''
# Connessione al database PostgreSQL
conn = psycopg2.connect(
    dbname="test",
    user="postgres",
    password="",
    host="localhost",
    port="5432"
)
cursor = conn.cursor()

def insert_artista():
    nome_arte = fake.unique.name()
    data_di_registrazione = fake.date_this_decade()
    cursor.execute(
        """
        INSERT INTO ARTISTA (nome_arte, data_di_registrazione)
        VALUES (%s, %s)
        RETURNING nome_arte
        """,
        (nome_arte, data_di_registrazione)
    )
    return cursor.fetchone()[0]

def insert_gruppo(artista):
    data_formazione = fake.date_this_decade()
    cursor.execute(
        """
        INSERT INTO GRUPPO (artista, data_formazione)
        VALUES (%s, %s)
        """,
        (artista, data_formazione)
    )

def insert_solista(artista):
    codice_fiscale = fake.unique.ssn()
    nome = fake.first_name()
    cognome = fake.last_name()
    data_di_nascita = fake.date_of_birth(minimum_age=18, maximum_age=90)
    gruppo = random.choice([None, insert_gruppo(artista)])  # Lascia NULL per alcuni record
    data_adesione = fake.date_this_decade() if gruppo else None
    cursor.execute(
        """
        INSERT INTO SOLISTA (artista, codice_fiscale, nome, cognome, data_di_nascita, gruppo, data_adesione)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        RETURNING codice_fiscale
        """,
        (artista, codice_fiscale, nome, cognome, data_di_nascita, gruppo, data_adesione)
    )
    return cursor.fetchone()[0]

def insert_partecipazione_passata(gruppo, solista):
    data_adesione = fake.date_this_decade()
    data_fine_adesione = fake.date_between(start_date=data_adesione, end_date='today')
    cursor.execute(
        """
        INSERT INTO PARTECIPAZIONE_PASSATA (gruppo, solista, data_adesione, data_fine_adesione)
        VALUES (%s, %s, %s, %s)
        """,
        (gruppo, solista, data_adesione, data_fine_adesione)
    )

def insert_email_a(artista):
    email = fake.email()
    cursor.execute(
        """
        INSERT INTO EMAIL_A (email, artista)
        VALUES (%s, %s)
        """,
        (email, artista)
    )

def insert_telefono_a(artista):
    numero = fake.phone_number()
    cursor.execute(
        """
        INSERT INTO TELEFONO_A (numero, artista)
        VALUES (%s, %s)
        """,
        (numero, artista)
    )

# Funzione per inserire un tipo di produzione
def insert_tipo_produzione():
    # Scelte possibili per il campo 'nome' nella tabella TIPO_PRODUZIONE
    choices = ['Album', 'Singolo', 'EP']
    
    # Esegui la scelta casuale
    nome = random.choice(choices)
    
    cursor.execute(
        """
        INSERT INTO TIPO_PRODUZIONE (nome)
        VALUES (%s)
        RETURNING nome
        """,
        (nome,)
    )
    conn.commit()
    
    return cursor.fetchone()[0]
def insert_genere():
    generi = ['Rock', 'Pop', 'Jazz', 'Classical', 'Hip Hop', 'Electronic']
    nome = random.choice(generi)
    cursor.execute(
        """
        INSERT INTO GENERE (nome)
        VALUES (%s)
        RETURNING nome
        """,
        (nome,)
    )
    return cursor.fetchone()[0]

def insert_produzione(artista, tipo):
    titolo = fake.sentence(nb_words=3)
    data_inizio = fake.date_this_decade()
    data_fine = fake.date_between(start_date=data_inizio, end_date='today')
    stato = random.choice(['Pubblicato', 'Pubblicazione'])
    tipo_produzione = tipo
    genere = insert_genere()
    cursor.execute(
        """
        INSERT INTO PRODUZIONE (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        RETURNING titolo
        """,
        (titolo, artista, data_inizio, data_fine, stato, tipo_produzione, genere)
    )
    return cursor.fetchone()[0]

def insert_canzone(produzione):
    titolo = fake.sentence(nb_words=4)
    testo = fake.text()
    data_di_registrazione = fake.date_this_decade()
    lunghezza_in_secondi = random.randint(180, 300)
    nome_del_file = fake.file_name()
    percorso_di_sistema = fake.file_path()
    estensione = fake.file_extension()
    cursor.execute(
        """
        INSERT INTO CANZONE (titolo, produzione, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING titolo
        """,
        (titolo, produzione, testo, data_di_registrazione, lunghezza_in_secondi, nome_del_file, percorso_di_sistema, estensione)
    )
    return cursor.fetchone()[0]

def insert_partecipazione(solista, canzone):
    cursor.execute(
        """
        INSERT INTO PARTECIPAZIONE (solista, canzone)
        VALUES (%s, %s, %s)
        """,
        (solista, canzone)
    )

def insert_produttore(solista):
    cursor.execute(
        """
        INSERT INTO PRODUTTORE (solista)
        VALUES (%s)
        RETURNING solista
        """,
        (solista,)
    )
    return cursor.fetchone()[0]

def insert_condurre(produttore, produzione):
    cursor.execute(
        """
        INSERT INTO CONDURRE (produttore, produzione)
        VALUES (%s, %s)
        """,
        (produttore, produzione)
    )

def insert_operatore():
    codice_fiscale = fake.unique.ssn()
    nome = fake.first_name()
    cognome = fake.last_name()
    data_di_nascita = fake.date_of_birth(minimum_age=18, maximum_age=90)
    data_di_assunzione = fake.date_this_decade()
    iban = fake.iban()
    cursor.execute(
        """
        INSERT INTO OPERATORE (codice_fiscale, nome, cognome, data_di_nascita, data_di_assunzione, iban)
        VALUES (%s, %s, %s, %s, %s, %s)
        RETURNING codice_fiscale
        """,
        (codice_fiscale, nome, cognome, data_di_nascita, data_di_assunzione, iban)
    )
    return cursor.fetchone()[0]

def insert_email_o(operatore):
    email = fake.email()
    cursor.execute(
        """
        INSERT INTO EMAIL_O (email, operatore)
        VALUES (%s, %s)
        """,
        (email, operatore)
    )

def insert_telefono_o(operatore):
    numero = fake.phone_number()
    cursor.execute(
        """
        INSERT INTO TELEFONO_O (numero, operatore)
        VALUES (%s, %s)
        """,
        (numero, operatore)
    )

def insert_ordine(artista, operatore):
    timestamp = fake.date_time_this_decade()
    annullato = random.choice([True, False])
    cursor.execute(
        """
        INSERT INTO ORDINE (timestamp, artista, annullato, operatore)
        VALUES (%s, %s, %s, %s)
        RETURNING timestamp
        """,
        (timestamp, artista, annullato, operatore)
    )
    return cursor.fetchone()[0]

def insert_metodo():
    metodi_pagamento = ['Carta di Credito', 'PayPal', 'Bonifico Bancario', 'Contanti']
    nome = random.choice(metodi_pagamento)
    cursor.execute(
        """
        INSERT INTO METODO (nome)
        VALUES (%s)
        RETURNING nome
        """,
        (nome,)
    )
    return cursor.fetchone()[0]

def insert_pagamento(ordine):
    stato = random.choice(['Pagato', 'Da pagare'])
    costo_totale = 0
    metodo = insert_metodo()
    cursor.execute(
        """
        INSERT INTO PAGAMENTO (ordine, stato, costo_totale, metodo)
        VALUES (%s, %s, %s, %s)
        """,
        (ordine, stato, costo_totale, metodo)
    )
# Funzione per inserire le tipologie nel database e restituire il nome della tipologia inserita
def insert_tipologia(i):
    # Lista delle tipologie da inserire
    tipologie = [
        ('Giornaliero', 160.00, 1),
        ('Settimanale', 600.00, 7),
        ('Mensile', 2200.00, 30)
    ]
    
    cursor.execute(
        """
        INSERT INTO TIPOLOGIA (nome, valore, n_giorni)
        VALUES (%s, %s, %s)
        RETURNING nome
        """,
        (tipologie[i][0], tipologie[i][1], tipologie[i][2])
    )
    conn.commit()

def insert_pacchetto(ordine):
    tipologia = insert_tipologia()
    n_giorni_prenotati_totali = 0
    cursor.execute(
        """
        INSERT INTO PACCHETTO (ordine, tipologia, n_giorni_prenotati_totali)
        VALUES (%s, %s, %s)
        """,
        (ordine, tipologia, n_giorni_prenotati_totali)
    )

def insert_orario(ordine):
    n_ore_prenotate_totali = 0
    valore = round(random.uniform(20, 30), 2)
    cursor.execute(
        """
        INSERT INTO ORARIO (ordine, n_ore_prenotate_totali, valore)
        VALUES (%s, %s, %s)
        """,
        (ordine, n_ore_prenotate_totali, valore)
    )

def insert_sala(piano):
    piano = piano
    numero = random.randint(1, 10)
    cursor.execute(
        """
        INSERT INTO SALA (piano, numero)
        VALUES (%s, %s)
        RETURNING piano, numero
        """,
        (piano, numero)
    )
    return cursor.fetchone()

def insert_prenotazione(pacchetto, sala):
    annullata = random.choice([True, False])
    giorno = fake.date_this_year()
    if pacchetto is None:
        tipo = 0
    else:
        tipo = 1
    cursor.execute(
        """
        INSERT INTO PRENOTAZIONE (annullata, giorno, tipo, pacchetto, sala_piano, sala_numero)
        VALUES (%s, %s, %s, %s, %s, %s)
        """,
        (annullata, giorno, tipo, pacchetto, sala[0], sala[1])
    )

def insert_oraria(prenotazione, orario):
    cursor.execute(
        """
        INSERT INTO ORARIA (prenotazione, orario)
        VALUES (%s, %s)
        """,
        (prenotazione, orario)
    )

def insert_fascia_oraria(oraria):
    orario_inizio = fake.time()
    orario_fine = fake.time()
    cursor.execute(
        """
        INSERT INTO FASCIA_ORARIA (oraria, orario_inizio, orario_fine)
        VALUES (%s, %s, %s)
        """,
        (oraria, orario_inizio, orario_fine)
    )


def insert_tipo_tecnico():
    # Scelte possibili per il campo 'nome' nella tabella TIPO_TECNICO
    tipi = ['Fonico', 'Tecnico del Suono', 'Tecnico del Suono_AND_Fonico']

    for tipo in tipi:
        cursor.execute(
            """
            INSERT INTO TIPO_TECNICO (nome)
            VALUES (%s)
            RETURNING nome
            """,
            (tipo,)
        )
        tipo_inserito = cursor.fetchone()[0]


def insert_tecnico(sala):
    codice_fiscale = fake.unique.ssn()
    tipo_tecnico = 'Fonico' #random.choice(choices)  choices = ['Fonico', 'Tecnico del Suono', 'Tecnico del Suono_AND_Fonico']
    nome = fake.first_name()
    cognome = fake.last_name()
    data_di_nascita = fake.date_of_birth(minimum_age=18, maximum_age=90)
    data_di_assunzione = fake.date_this_decade()
    iban = fake.iban()
    cursor.execute(
        """
        INSERT INTO TECNICO (codice_fiscale, sala_piano, sala_numero, tipo_tecnico, nome, cognome, data_di_nascita, data_di_assunzione, iban)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING codice_fiscale
        """,
        (codice_fiscale, sala[0], sala[1], tipo_tecnico, nome, cognome, data_di_nascita, data_di_assunzione, iban)
    )
    return cursor.fetchone()[0]

def insert_email_t(tecnico):
    email = fake.email()
    cursor.execute(
        """
        INSERT INTO EMAIL_T (email, tecnico)
        VALUES (%s, %s)
        """,
        (email, tecnico)
    )


def insert_telefono_t(tecnico):
    numero = fake.phone_number()
    cursor.execute(
        """
        INSERT INTO TELEFONO_T (numero, tecnico)
        VALUES (%s, %s)
        """,
        (numero, tecnico)
    )

def insert_lavora_a(tecnico_id, canzone_id):
    cursor.execute(
        """
        INSERT INTO LAVORA_A (tecnico, canzone)
        VALUES (%s, %s)
        """,
        (tecnico_id, canzone_id)
    )
    return cursor.rowcount  # Restituisce il numero di righe inserite

# Esempio di popolamento del database mantenendo i vincoli di integrità referenziali

# Array per tenere traccia delle chiavi primarie
sale = []
tecnici = []
tipologie = []
prenotazioni = []
produzioni = []
singoli = []
ep = []
album = []
artisti = []
solisti = []
gruppi = []
canzoni = []
produttori = []
ordini = []
pacchetti = []
giornaliere = []
orari = []
orarie = []
fasce_orarie = []


# Esegui la pulizia del database
clean_database()




# Funzioni per il popolamento delle tabelle (già definite sopra)
# ...

# SALA: 41
for i in range(4):
    sala_id = insert_sala(i)
    sale.append(sala_id)

insert_tipo_tecnico()

# TECNICO: 6 (associazione tra tecnico e sala)
for sala_id in sale:
    for _ in range(1):  # ogni sala ha 1 tecnico
        tecnico_id = insert_tecnico(sala_id)
        tecnici.append(tecnico_id)

# TIPOLOGIA: 4
for _ in range(3):
    tipologia_id = insert_tipologia()
    tipologie.append(tipologia_id)

# ARTISTA: 224
for _ in range(224):
    artista_id = insert_artista()
    artisti.append(artista_id)

# SOLISTA: 194
for artista_id in artisti[:194]:
    solista_id = insert_solista(artista_id)
    solisti.append(solista_id)

# PRODUTTORE: 56
for artista_id in artisti[:56]:
    produttore_id = insert_produttore(artista_id)
    produttori.append(produttore_id)

# GRUPPO: 30
for artista_id in artisti[:30]:
    gruppo_id = insert_gruppo(artista_id)
    gruppi.append(gruppo_id)

# CANZONE: 256
for _ in range(256):
    canzone_id = insert_canzone(random.choice(produzioni))
    canzoni.append(canzone_id)

# PRODUZIONE: 84 (associazione tra artista e produzione)
c = 0
c = 0
for artista_id in artisti:
    if c < 60:
        produzione_id = insert_produzione(artista_id, 'Singolo')
        produzioni.append(produzione_id)
    elif c >= 60 and c < 74:
        produzione_id = insert_produzione(artista_id, 'EP')
        produzioni.append(produzione_id)
    else:
        produzione_id = insert_produzione(artista_id, 'Album')
        produzioni.append(produzione_id)

    for _ in range(3):  # Supponiamo 3 canzoni per produzione
        canzone_id = insert_canzone(produzione_id)
        canzoni.append(canzone_id)
        solista_id = random.choice(solisti)
        insert_partecipazione(solista_id, canzone_id)
    c += 1
        
# PARTECIPAZIONE: 96 (associazione tra canzone e solista)
for _ in range(96):
    insert_partecipazione(random.choice(solisti), random.choice(canzoni))

# CONDURRE: 90 (associazione tra produttore e produzione)
for _ in range(90):
    insert_condurre(random.choice(produttori), random.choice(produzioni))

# PRENOTAZIONE: 506 (associazione tra ordine e sala)
for ordine_id in ordini:
    for _ in range(506 // len(ordini)):
        prenotazione_id = insert_prenotazione(ordine_id, random.choice(sale))
        prenotazioni.append(prenotazione_id)

# ORDINE: 324
for _ in range(324):
    ordine_id = insert_ordine(random.choice(artisti), random.choice([1, 2]))
    ordini.append(ordine_id)

# PAGAMENTO: 324
for ordine_id in ordini:
    insert_pagamento(ordine_id)

# Genera PACCHETTO: 124
for i in range(124):
    ordine_id = ordini[i] 
    pacchetto_id = insert_pacchetto(ordine_id)
    pacchetti.append(pacchetto_id)

# ATTREZZATURA: 37
#for _ in range(37):
#    attrezzatura_id = insert_attrezzatura()
#    attrezzature.append(attrezzatura_id)

# GIORNALIERA: 306
for _ in range(306):
    giornaliera_id = insert_prenotazione(True, random.choice(sale))
    giornaliere.append(giornaliera_id)

# Genera ORARIO: 200
for i in range(124, 324):
    ordine_id = ordini[i]
    orario_id = insert_orario(ordine_id)
    orari.append(orario_id)


# ORARIA: 200
for i in range(200):
    oraria_id = insert_oraria(orari[i])
    orarie.append(oraria_id)

# FASCIA ORARIA: 360
for _ in range(360):
    fascia_oraria_id = insert_fascia_oraria()
    fasce_orarie.append(fascia_oraria_id)

# EMAIL_A: 224
for artista_id in artisti:
    insert_email_a(artista_id)

# TELEFONO_A: 240
for artista_id in artisti:
    insert_telefono_a(artista_id)

# EMAIL_O: 2
for operatore_id in range(1, 3):  # supponendo 2 operatori
    insert_email_o(operatore_id)

# TELEFONO_O: 2
for operatore_id in range(1, 3):  # supponendo 2 operatori
    insert_telefono_o(operatore_id)

# EMAIL_T: 6
for tecnico_id in tecnici:
    insert_email_t(tecnico_id)

# TELEFONO_T: 8
for tecnico_id in tecnici:
    insert_telefono_t(tecnico_id)

# Effettuazione (associazione tra tecnico e canzone)
for _ in range(324):
    insert_effettuazione(random.choice(tecnici), random.choice(canzoni))

# Assegnazione (associazione tra tecnico e sala)
for sala_id in sale:
    for _ in range(1):  # ogni sala ha 1 tecnico
        tecnico_id = insert_tecnico(sala_id)
        insert_assegnazione(tecnico_id, sala_id)

# Composizione (associazione tra artista e produzione)
for artista_id in artisti:
    produzione_id = random.choice(produzioni)
    insert_composizione(artista_id, produzione_id)

# Partecipazione Passata (associazione tra solista e gruppo)
for _ in range(16):
    gruppo_id = random.choice(gruppi)
    solista_id = random.choice(solisti)
    insert_partecipazione_passata(solista_id, gruppo_id)

# Partecipazione Corrente (associazione tra gruppo e solista)
for _ in range(120):
    gruppo_id = random.choice(gruppi)
    solista_id = random.choice(solisti)
    insert_partecipazione_corrente(solista_id, gruppo_id)

# Raccolta di (associazione tra produzione e canzone)
for produzione_id in produzioni:
    for _ in range(3):  # supponiamo 3 canzoni per produzione
        canzone_id = insert_canzone(produzione_id)
        insert_raccolta_di(produzione_id, canzone_id)

# Lavora a (associazione tra tecnico e canzone)
for _ in range(306):
    insert_lavora_a(random.choice(tecnici), random.choice(canzoni))



# Commit delle operazioni
conn.commit()

# Chiusura della connessione
cursor.close()
conn.close()

'''