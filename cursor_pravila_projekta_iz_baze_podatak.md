# Pravila projekta iz baze podataka
_Exported on 4/8/2026 at 21:03:04 GMT+2 from Cursor (3.0.12)_

---

**User**

@Pravila projekta iz Baza podataka I.md_files/mermaid.min.js.Download  @Pravila projekta iz Baza podataka I.md.html  mozes li ovo vidjeti 

---

**Cursor**

Pregledavam oba fajla da potvrdim pristup i sadržaj.



Da, **mogu ih “vidjeti”** u smislu da su u tvom workspaceu i da mogu čitati sadržaj — s jednom razlikom:

### `Pravila projekta iz Baza podataka I.md.html`
Ovo je **spremljena HTML stranica** (komentar kaže da je s Moodlea: `moodle.srce.hr`, dokument *Pravila projekta iz Baza podataka I*). Uključuje VS Code / Markdown PDF stilove (CSS), syntax highlighting temu i dalje sadržaj pravila projekta u HTML obliku. Na ovaj fajl mogu normalno čitati cijeli sadržaj po dijelovima.

### `Pravila projekta iz Baza podataka I.md_files/mermaid.min.js.Download`
Ovo je **minificirana Mermaid biblioteka** (JavaScript), vrlo velika — oko **2,96 milijuna znakova** u jednom “bloku”, tipično praktički **jedna duga linija**. Zbog toga alat za čitanje ne može učitati cijeli fajl odjednom, ali znam da postoji i što je: lokalna kopija `mermaid.min.js` koju preglednik koristi za crtanje dijagrama u tom HTML-u.

Ako želiš, mogu iz HTML-a izvući **konkretan tekst pravila** (naslovi, rokovi, zahtjevi) ili provjeriti **kako je Mermaid uključen** (`script src`, itd.) — samo reci što ti treba.

---

**User**

Dali mozes vidjeti jesu  li dobro napravljeni ove datoteke za projekt treba li jos sto nadopuniti ? Evo ti datoteke: @tim13/opis_baze_poliklinika.md @tim13/poliklinika_mysql_ddl_clean.sql @tim13/demo-csv.zip 

---

**Cursor**

Let me read the project files.

Let me check the CSV files inside the zip.

Let me read a few key CSV files to check consistency with the SQL.

Sve tri datoteke sam pregledao u detalje. Evo kompletni pregled:

---

## SQL DDL — Greške koje sprječavaju izvršavanje

### 1. Nedostaje `;` nakon `CREATE DATABASE`

```1:3:tim13/poliklinika_mysql_ddl_clean.sql
CREATE DATABASE IF NOT EXISTS poliklinika

USE poliklinika;
```
→ `CREATE DATABASE IF NOT EXISTS poliklinika;`

---

### 2. `department` — nedostaje zarez + višak zareza na kraju

```39:41:tim13/poliklinika_mysql_ddl_clean.sql
  UNIQUE KEY uq_department_code (code)
  KEY idx_department_code (code),
);
```
Problem: nema zareza iza `UNIQUE KEY` linije, a ima višak zareza iza zadnjeg `KEY` (trailing comma).

---

### 3. `office` — pogrešno ime kolone u UNIQUE KEY

```53:53:tim13/poliklinika_mysql_ddl_clean.sql
  UNIQUE KEY uq_office_code (office_code),
```
Kolona se zove `code`, ne `office_code`. Isto mora biti `(code)`.

---

### 4. `specialization` — višak zareza na kraju

```71:72:tim13/poliklinika_mysql_ddl_clean.sql
  KEY idx_specialization_code (code),
);
```
Trailing comma ispred `)` je sintaksna greška.

---

### 5. `service` — tri pogrešna naziva kolona

```135:141:tim13/poliklinika_mysql_ddl_clean.sql
  UNIQUE KEY uq_service_code (service_code),
  KEY idx_service_code (code),
  KEY idx_service_category_id (service_category_id),
  KEY idx_service_department_id (department_id),
  CONSTRAINT fk_service_category
    FOREIGN KEY (service_category_id) REFERENCES service_category (id)
```
- `service_code` → treba `code`
- `service_category_id` (dva puta) → treba `category_id`

---

### 6. `service_price` — pogrešno ime kolone u KEY

```161:161:tim13/poliklinika_mysql_ddl_clean.sql
  KEY idx_service_price_valid_from (valid_from),
```
Kolona se zove `date_from`, ne `valid_from`.

---

### 7. `referral` — višak zareza na kraju

```180:181:tim13/poliklinika_mysql_ddl_clean.sql
    ON DELETE CASCADE,
) ;
```
Trailing comma iza zadnje constraint.

---

### 8. `appointment_status` — nedostaje zarez + višak zareza na kraju

```193:195:tim13/poliklinika_mysql_ddl_clean.sql
  UNIQUE KEY uq_appointment_status_code (code)
  KEY idx_appointment_status_code (code),
);
```
Isti problem kao kod `department`.

---

### 9. `employee_schedule` — višak zareza na kraju

```213:214:tim13/poliklinika_mysql_ddl_clean.sql
    ON DELETE RESTRICT,
) ;
```

---

### 10. `diagnosis` — pogrešno ime kolone u UNIQUE KEY

```328:328:tim13/poliklinika_mysql_ddl_clean.sql
  UNIQUE KEY uq_diagnosis_code (diagnosis_code)
```
Kolona se zove `code`, ne `diagnosis_code`.

---

## CSV demo podaci — Problemi s konzistencijom

### 1. Cijene se ne poklapaju između tablica

`service_price.price` (40, 47, 54, 61...) ≠ `invoice_item.unit_price` (50, 60, 70, 80...) ≠ `examination_service.price` (40, 47, 54...).

`examination_service` koristi cijene iz `service_price` — to je ispravno.  
`invoice_item` ima drugačije cijene (50, 60, 70...) koje nisu nigdje definirane — **podaci su nekonzistentni**.

### 2. Svi pregledi imaju status `3` (IN_PROGRESS)

Svi pregledi imaju `examination_status_id = 3`, a imaju gotove račune. Logičnije bi bilo `status = DONE` za završene preglede.

### 3. Napomene/opisi su identični za svaki zapis

Sve uputnice, termini, pregledi imaju isti tekst. Prihvatljivo za demo, ali malo banalno — ako profesor bude pratio tok podataka, odmah se vidi da je generirano.

---

## Manji dizajn problem (nije bug, ali vrijedi znati)

- U komentarima na dnu SQL-a tablice se zovu `therapy_recommendation`, ali stvarno ime tablice je `therapy` — neslaganje u komentarima (redovi 631-644)
- `referral_number` nema `UNIQUE KEY` — dva identična broja uputnice bila bi moguća
- `finding` koristi `ON DELETE CASCADE` prema `patient` — brisanje pacijenta obriše i sve nalaze. Za medicinsku bazu to je rizično; razmisli o `RESTRICT`

---

## Sažetak

| Kategorija | Broj problema |
|---|---|
| SQL sintaksne greške (ne može se pokrenuti) | **10** |
| CSV nekonzistentni podaci | **3** |
| Dizajn prijedlozi | **3** |

Hoćeš da popravim SQL DDL direktno ili samo pokazujem gdje treba mijenjati?

