# Poliklinika — baza podataka (Tim 13)

MySQL shema poliklinike (hrvatski nazivi tablica i stupaca) i početni CSV za uvoz u mapu `podaci/`.

---

## Sadrzaj repozitorija

| Datoteka / mapa | Opis |
|---|---|
| `poliklinika_mysql_ddl_clean.sql` | DDL: brise/kreira bazu `poliklinika`, sve tablice, FK i CHECK ogranicenja |
| `podaci/` | 25 CSV datoteka (jedna po tablici); nazivi stupaca kao u DDL-u |
| `podaci.zip` | Arhiva mape `podaci/` |
| `scripts/generiraj_csv_podaci.py` | Python skripta za ponovno generiranje sadrzaja `podaci/` |
| `opis_baze_poliklinika.md` | Tekstualni opis modela |
| `PoliklinikaProjekt.pdf` | Zadatak / projektna dokumentacija |
| `eer_poliklinika.svg` | ER dijagram (vektor) |
| `ER.png` | ER dijagram (raster) |
| `ER_syntax.txt` | Biljeske uz ER sintaksu |

---

## Model ukratko

Glavni tijek u podacima: **termin** (`termin_pacijenta`) → **pregled** → **pregled_usluga** (obavljene usluge) → **stavka_racuna** vezana uz red pregleda, ili uz samu **usluga** ako racun nije vezan uz pregled. Statusi su u stupcima (`status_termina`, `status_pregleda`, …) uz CHECK u DDL-u, ne kao posebne status-tablice. Zaposlenik je vezan uz jednu **ordinaciju**; odjel se dobije preko ordinacije.

---

## Preduvjeti

- MySQL 8.x (npr. XAMPP)
- Klijent za SQL (preporuka: [DBeaver](https://dbeaver.io/download/))
- Za regeneriranje CSV-a: **Python 3** (bez dodatnih paketa)

---

## Postavljanje baze

### 1. Pokreni MySQL

U XAMPP-u: Control Panel → Start kod MySQL.

### 2. Spoji se u DBeaveru

- Host: `localhost`
- Port: `3306`
- Korisnik: `root`
- Lozinka: obično prazna na zadanoj XAMPP instalaciji

### 3. Izvedi DDL

1. `File` → `Open File` → `poliklinika_mysql_ddl_clean.sql`
2. Aktivna veza mora biti na bazu (ne `<none>`).
3. Izvedi cijelu skriptu (npr. `Alt + X`, Execute SQL Script).

Skripta **brise** postojecu bazu `poliklinika` ako postoji, pa je iz pocetka kreira.

### 4. Provjera

Osvjezi stablo baza (`F5`). Ocekuj bazu `poliklinika` i **25 tablica**:

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
privitak
stavka_racuna
uplata
```

---

## Uvoz podataka iz CSV (`podaci/`)

- Kodiranje: **UTF-8**.
- Svaka datoteka odgovara jednoj tablici (`pacijent.csv` → `pacijent`, …).
- **Prazno polje** u CSV-u tumaci se kao `NULL` pri uvozu (ovisi o klijentu — u DBeaveru mapiraj prazno na NULL).

### Napomena o podacima

Brojevi (OIB, MBO, racuni, uplate), putanje na disku u **privitak** i kontakt pacijenata (telefon, `@gmail.com`) namijenjeni su **podaci za razvoj / predaju projekta**. Za stvarnu upotrebu zamijeni vlastitim evidencijama.

Pri ručnom unosu ili vlastitim CSV-ima poštuj **CHECK** u DDL-u, npr.:

- `nalaz`: ili vezan uz `pregled`, ili samostalan s `id_pacijent` + `id_zaposlenik`
- `racun`: ili `id_pregled` ili `id_pacijent`, ne oboje
- `stavka_racuna`: ili `id_pregled_usluga` ili `id_usluga`
- `privitak`: točno jedan od četiri FK roditelja (pregled / nalaz / uputnica / racun)

### Redoslijed uvoza (radi FK)

1. pacijent  
2. odjel  
3. ordinacija  
4. specijalizacija  
5. zaposlenik  
6. usluga  
7. cijena_usluge  
8. uputnica  
9. raspored_djelatnika  
10. termin_pacijenta  
11. pregled  
12. pregled_usluga  
13. dijagnoza  
14. pregled_dijagnoza  
15. tip_nalaza  
16. nalaz  
17. laboratorijski_parametar  
18. laboratorijski_rezultat  
19. terapija  
20. preporuceni_lijek  
21. nacin_placanja  
22. racun  
23. privitak  
24. stavka_racuna  
25. uplata  

### Regeneriranje CSV-a

Iz korijena repozitorija:

```bash
python scripts/generiraj_csv_podaci.py
```

Zatim po zelji ponovo zapakiraj `podaci/` u `podaci.zip` (ili koristi zip iz repozitorija).

---

## Napomene za tim

- Konvencija imenovanja: hrvatski pojmovi, `snake_case` za tablice i stupce.
- Primarni kljucevi: `BIGINT UNSIGNED AUTO_INCREMENT`.
- Datum `YYYY-MM-DD`, vrijeme/datetime `YYYY-MM-DD HH:MM:SS`.
- Valuta u primjerima: **EUR**.
- DDL je ciljan na **MySQL 8.x** (CHECK se koristi dosljedno).
