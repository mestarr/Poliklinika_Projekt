# Poliklinika – Baza podataka (Tim 13)

Informacijski sustav poliklinike — MySQL baza podataka s demo podacima.

---

## Sadržaj repozitorija

| Datoteka | Opis |
|---|---|
| `poliklinika_mysql_ddl_clean.sql` | DDL skripta — kreira sve tablice |
| `demo-csv.zip` | Demo CSV podaci za uvoz |
| `opis_baze_poliklinika.md` | Opis modela baze podataka |

---

## Preduvjeti

Treba ti jedno od sljedećeg:

- **XAMPP** (preporučeno) — [apachefriends.org](https://www.apachefriends.org/) — instalira MySQL lokalno
- **MySQL Server** — ako već imaš instaliran
- **DBeaver** (GUI alat) — [dbeaver.io](https://dbeaver.io/download/) — za pregled i rad s bazom

---

## Postavljanje baze

### Korak 1 — Pokreni MySQL server

Ako koristiš XAMPP: otvori **XAMPP Control Panel** → klikni **Start** pored **MySQL**.

### Korak 2 — Otvori DBeaver i poveži se

1. Otvori DBeaver
2. Lijevi panel → desni klik na **localhost** → **Connect**
   - Host: `localhost`
   - Port: `3306`
   - Username: `root`
   - Password: *(prazno ako koristiš XAMPP zadane postavke)*

### Korak 3 — Pokreni DDL skriptu

1. U DBeaver-u: gornji izbornik → **File → Open File**
2. Odaberi `poliklinika_mysql_ddl_clean.sql`
3. Gore u editoru provjeri da piše **`localhost`** kao aktivna konekcija (ne `<none>`)
4. Pokreni cijelu skriptu: **`Alt + X`** (ili `SQL Editor → Execute SQL Script`)

Skripta automatski:
- Briše staru bazu `poliklinika` ako postoji
- Kreira novu bazu `poliklinika`
- Kreira sve tablice s indeksima i FK vezama

### Korak 4 — Provjeri tablice

U lijevom panelu: desni klik na **Databases → Refresh** (F5)

Treba se pojaviti `poliklinika` s **25 tablica**:

```
appointment            examination_attachment   lab_parameter
appointment_status     examination_diagnosis    lab_result
department             examination_service      office
diagnosis              examination_status       patient
employee               finding                  payment
employee_schedule      finding_status           payment_method
finding_type           invoice                  recommended_medication
invoice_item           invoice_status           referral
service                service_category         service_price
specialization         therapy
```

---

## Uvoz demo podataka (opcionalno)

Demo CSV podaci nalaze se u `demo-csv.zip`. Raspakiraj zip i uvezi CSV datoteke u odgovarajuće tablice.

**Redoslijed uvoza je važan** zbog FK veza — uvozi tablice ovim redoslijedom:

```
1.  patient
2.  department
3.  specialization
4.  office
5.  employee
6.  service_category
7.  service
8.  service_price
9.  referral
10. appointment_status
11. employee_schedule
12. appointment
13. examination_status
14. examination
15. examination_service
16. diagnosis
17. examination_diagnosis
18. finding_type
19. finding_status
20. finding
21. lab_parameter
22. lab_result
23. therapy
24. recommended_medication
25. examination_attachment
26. payment_method
27. invoice_status
28. invoice
29. invoice_item
30. payment
```

**Uvoz u DBeaver-u:**
1. Desni klik na tablicu → **Import Data**
2. Odaberi CSV datoteku
3. Provjeri mapiranje kolona → **Finish**

---

## Napomene

- Skripta koristi `DROP DATABASE IF EXISTS poliklinika` na početku — svako pokretanje briše i rekreira bazu od nule
- Sve tablice koriste `BIGINT UNSIGNED AUTO_INCREMENT` za PK
- Valuta je `EUR`, format datuma `YYYY-MM-DD`
- Testirana na **MySQL 8.x**
