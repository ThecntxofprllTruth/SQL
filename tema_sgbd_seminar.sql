--Cerinta 1
CREATE OR REPLACE FUNCTION Nume_complet (
    p_angajat_id IN NUMBER
) RETURN VARCHAR2
IS
    v_nume_angajat VARCHAR2(100);
BEGIN
    SELECT nume || ' ' || prenume
    INTO v_nume_angajat
    FROM angajati
    WHERE angajat_id = p_angajat_id;
    RETURN v_nume_angajat;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Angajatul nu existã';
END;
/

--Cerinta 2
CREATE OR REPLACE PROCEDURE Dubleaza_salariu (
    p_departament_id IN NUMBER
)
IS
    v_nr_angajati NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_nr_angajati
    FROM angajati
    WHERE departament_id = p_departament_id;

    IF v_nr_angajati > 0 THEN
        UPDATE angajati
        SET salariu = salariu * 2
        WHERE departament_id = p_departament_id;

        DBMS_OUTPUT.PUT_LINE('Salariile angajatilor din departamentul ' || p_departament_id || ' au fost dublate.');
    ELSE

        DBMS_OUTPUT.PUT_LINE('Nu existã angaja?i în departamentul ' || p_departament_id || '.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;
/

--Cerinta 3 
CREATE OR REPLACE PROCEDURE Valoare_comenzi (
    p_anul IN NUMBER
)
IS
    v_total_valoare NUMBER := 0;
BEGIN
    FOR rec IN (
        SELECT id_comanda, data_comanda, valoare
        FROM comenzi
        WHERE EXTRACT(YEAR FROM data_comanda) = p_anul
    )
    LOOP
        v_total_valoare := v_total_valoare + rec.valoare;
        DBMS_OUTPUT.PUT_LINE('Comanda ' || rec.id_comanda || ' din data ' || TO_CHAR(rec.data_comanda, 'DD-MM-YYYY') || ' are valoarea: ' || rec.valoare);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Valoarea totalã a comenzilor din anul ' || p_anul || ' este: ' || v_total_valoare);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;
/

--Cerinta 4

CREATE OR REPLACE FUNCTION Calcul_vechime (
    p_angajat_id IN NUMBER
) RETURN NUMBER
IS
    v_vechime NUMBER;
BEGIN
    v_vechime := 0;

    SELECT EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_angajare)
    INTO v_vechime
    FROM angajati
    WHERE angajat_id = p_angajat_id;

    IF v_vechime IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Angajatul nu existã');
    END IF;

    RETURN v_vechime;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/
--apelare
DECLARE
    v_angajat_vechime NUMBER;
BEGIN
    v_angajat_vechime := Calcul_vechime(123);
    IF v_angajat_vechime IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Vechimea angajatului este: ' || v_angajat_vechime || ' ani');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Angajatul nu existã');
    END IF;
END;
/

--Cerinta 5
CREATE OR REPLACE PROCEDURE Vechime_angajati
IS
    CURSOR cur_angajati IS
        SELECT angajat_id, nume, prenume
        FROM angajati;
    
    v_angajat_id angajati.angajat_id%TYPE;
    v_nume angajati.nume%TYPE;
    v_prenume angajati.prenume%TYPE;
    v_vechime NUMBER;
BEGIN
    OPEN cur_angajati;
    LOOP
        FETCH cur_angajati INTO v_angajat_id, v_nume, v_prenume;
        EXIT WHEN cur_angajati%NOTFOUND;

        v_vechime := Calcul_vechime(v_angajat_id);
        IF v_vechime IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('Angajatul ' || v_nume || ' ' || v_prenume || ' cu ID-ul ' || v_angajat_id || ' are vechimea: ' || v_vechime || ' ani');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Angajatul ' || v_nume || ' ' || v_prenume || ' cu ID-ul ' || v_angajat_id || ' nu existã');
        END IF;
    END LOOP;
    CLOSE cur_angajati;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;
/




