# Poliklinika - Baza podataka (Tim 13)

Informacijski sustav poliklinike - MySQL baza podataka s hrvatskim nazivima tablica i kolona.

---

## Sadrzaj repozitorija

| Datoteka/folder | Opis |
|---|---|
| `poliklinika_mysql_ddl_clean.sql` | DDL skripta - kreira bazu i sve tablice |
| `demo-csv/` | Demo CSV podaci (trenutno s engleskim headerima) |
| `demo-csv.zip` | Isti demo CSV podaci u zip formatu |
| `opis_baze_poliklinika.md` | Tekstualni opis modela baze |
| `PoliklinikaProjekt.pdf` | ER model i specifikacija projekta |

---

## Preduvjeti

Treba ti:

- MySQL Server (npr. kroz XAMPP)
- DBeaver (ili drugi SQL klijent)

Preporuceni alati:

- XAMPP: [https://www.apachefriends.org/](https://www.apachefriends.org/)
- DBeaver: [https://dbeaver.io/download/](https://dbeaver.io/download/)

---

## Postavljanje baze

### 1) Pokreni MySQL

Ako koristis XAMPP: otvori XAMPP Control Panel i klikni `Start` za `MySQL`.

### 2) Spoji se iz DBeaver-a

1. Otvori DBeaver
2. Lijevi panel -> desni klik na `localhost` -> `Connect`
3. Standardne postavke:
   - Host: `localhost`
   - Port: `3306`
   - Username: `root`
   - Password: prazno (ako je default XAMPP)

### 3) Pokreni SQL skriptu

1. `File -> Open File`
2. Odaberi `poliklinika_mysql_ddl_clean.sql`
3. Provjeri da je aktivna konekcija `localhost` (ne `<none>`)
4. Pokreni cijeli script: `Alt + X` (`Execute SQL Script`)

Skripta:

- brise staru bazu `poliklinika` (ako postoji)
- kreira novu bazu `poliklinika`
- kreira sve tablice, kljuceve i FK veze

### 4) Provjera

U lijevom panelu: desni klik na `Databases` -> `Refresh` (F5).

Trebas vidjeti bazu `poliklinika` s ovih 25 tablica:

```
pacijent
odjel
ordinacija
specijalizacija
zaposlenik
usluga
cijena_usluge
uputnica
raspored_djelatnika
termin_pacijenta
pregled
pregled_usluga
dijagnoza
pregled_dijagnoza
tip_nalaza
nalaz
laboratorijski_parametar
laboratorijski_rezultat
terapija
preporuceni_lijek
nacin_placanja
racun
stavka_racuna
uplata
privitak
```

> Napomena: ranija verzija sheme imala je 30 tablica. Pet tablica je
> uklonjeno tijekom refaktoringa (`sifarnik_usluga`, `sifarnik_statusa_termina`,
> `status_pregleda`, `status_nalaza`, `status_racuna`) - statusi se sada
> prate stupcem `status` + CHECK constraintom u relevantnim tablicama, a
> hijerarhija usluga nije potrebna. Tablica `privitak_pregleda` zamijenjena
> je opcom tablicom `privitak` koja se moze vezati na pregled, nalaz,
> uputnicu ili racun.

---

## Uvoz demo podataka (trenutno stanje)

`demo-csv` datoteke su trenutno spremljene s engleskim nazivima tablica i kolona (npr. `patient.csv`, `first_name`, `invoice_item.csv`).

Zbog toga postoji mismatch prema trenutnoj SQL shemi koja je na hrvatskim nazivima (npr. `pacijent`, `ime`, `stavka_racuna`).

To znaci:

- SQL shema je ispravna i spremna
- CSV uvoz je moguc, ali uz rucno mapiranje kolona u DBeaver-u
- plan je uskladiti `demo-csv` s hrvatskim nazivima u sljedecem koraku

---

## Napomene za tim

- Koristimo hrvatski naming standard (`snake_case`, ASCII znakovi)
- Primarni kljucevi su `BIGINT UNSIGNED AUTO_INCREMENT`
- Datum: `YYYY-MM-DD`, datetime: `YYYY-MM-DD HH:MM:SS`
- Valuta je `EUR`
- Skripta je predvidena za MySQL 8.x
