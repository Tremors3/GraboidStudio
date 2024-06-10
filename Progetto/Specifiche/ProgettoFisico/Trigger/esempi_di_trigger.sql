SELECT * 
FROM information_schema.triggers 
WHERE event_object_table = 'prenotazione';

---------------------------------------------------------------------------------------------------

-- Spiegazione di SELECT 1
In SQL, SELECT 1 è usato per:

    Esistenza di una riga: Quando si vuole verificare se esiste almeno una riga che soddisfa una certa condizione.
    Ottimizzazione: È più efficiente di SELECT * perché non è necessario recuperare i dati delle colonne per fare questa verifica.

Ecco un esempio di come viene utilizzato:

sql

-- Verifica se esiste almeno un record in PRODUZIONE con codice specifico 123
SELECT 1
FROM PRODUZIONE
WHERE codice = 123;

Se esiste almeno una riga con codice = 123 nella tabella PRODUZIONE, questa query restituirà una riga con valore 1. Se non esiste alcuna riga che soddisfi la condizione, la query non restituirà alcun risultato.

---------------------------------------------------------------------------------------------------

-- TRIGGER: un ordine e una prenotazione possono essere annullati solo se il giorno a cui fanno riferimento non è antecedente al giorno in cui si fa la richiesta

-- creare un trigger per fare in modo che le fascie orarie non overleappino, guardare la query gia creata per costruirlo.