DROP DATABASE IF EXISTS poliklinika;
CREATE DATABASE poliklinika;

USE poliklinika;


CREATE TABLE pacijent (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  oib CHAR(11) NOT NULL,
  mbo CHAR(9) NOT NULL,
  ime VARCHAR(50) NOT NULL,
  prezime VARCHAR(100) NOT NULL,
  spol CHAR(1) NOT NULL DEFAULT 'm', /* m - muški, ž - ženski, o - ostali */
  datum_rodjenja DATE NOT NULL,
  broj_mobitela VARCHAR(20) NOT NULL,
  email_adresa VARCHAR(100) NOT NULL,
  adresa_stanovanja VARCHAR(255) NOT NULL,
  grad VARCHAR(100) NOT NULL,
  biljeska VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_oib_pacijenta (oib),
  UNIQUE KEY uq_mbo_pacijenta (mbo),
  UNIQUE KEY uq_email_adresa_pacijenta (email_adresa),
  CONSTRAINT chk_spol_pacijenta CHECK (spol IN ('m', 'ž', 'o'))
);

CREATE TABLE odjel (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra CHAR(3) NOT NULL,
  naziv VARCHAR(100) NOT NULL,
  opis VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sifra_odjela (sifra)
);

CREATE TABLE ordinacija (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_odjel INTEGER UNSIGNED NOT NULL,
  sifra CHAR(3) NOT NULL,
  naziv VARCHAR(100) NOT NULL,
  opis VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sifra_ordinacije (sifra),
  KEY idx_ordinacija_odjel (id_odjel),
  CONSTRAINT fk_ordinacija_odjel
    FOREIGN KEY (id_odjel) REFERENCES odjel (id)
    ON DELETE CASCADE
);

CREATE TABLE specijalizacija (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra CHAR(3) NOT NULL,
  naziv VARCHAR(100) NOT NULL,
  opis VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sifra_specijalizacije (sifra)
);

CREATE TABLE zaposlenik (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra CHAR(10) NOT NULL,
  ime VARCHAR(50) NOT NULL,
  prezime VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  telefon VARCHAR(50) NOT NULL,
  titula VARCHAR(50) NOT NULL DEFAULT 'lijecnik',
  id_specijalizacija INTEGER UNSIGNED NOT NULL,
  id_ordinacija INTEGER UNSIGNED NULL,
  datum_zaposlenja DATE NOT NULL,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sifra_zaposlenika (sifra),
  UNIQUE KEY uq_email_zaposlenika (email),
  UNIQUE KEY uq_telefon_zaposlenika (telefon),
  KEY idx_zaposlenik_specijalizacija (id_specijalizacija),
  KEY idx_zaposlenik_ordinacija (id_ordinacija),
  CONSTRAINT fk_zaposlenik_specijalizacija
    FOREIGN KEY (id_specijalizacija) REFERENCES specijalizacija (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_zaposlenik_ordinacija
    FOREIGN KEY (id_ordinacija) REFERENCES ordinacija (id)
    ON DELETE SET NULL 
);

CREATE TABLE usluga (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra CHAR(3) NOT NULL,
  naziv VARCHAR(200) NOT NULL,
  opis VARCHAR(2000) NOT NULL DEFAULT '-',
  id_odjel INTEGER UNSIGNED  NULL,
  trajanje_pregleda_minute INT NOT NULL DEFAULT 0,
  aktivna BOOLEAN NOT NULL DEFAULT TRUE,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sifra_usluge (sifra),
  KEY idx_usluga_odjel (id_odjel),
  CONSTRAINT fk_usluga_odjel
    FOREIGN KEY (id_odjel) REFERENCES odjel (id)
    ON DELETE SET NULL 
);

CREATE TABLE cijena_usluge (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_usluga INTEGER UNSIGNED NOT NULL,
  datum_od DATE NOT NULL,
  datum_do DATE NOT NULL DEFAULT '9999-12-31',
  iznos DECIMAL(18,2) NOT NULL,
  valuta CHAR(3) NOT NULL DEFAULT 'EUR',
  porezna_stopa DECIMAL(5,2) NOT NULL DEFAULT 0,
  napomena VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_cijena_usluge_usluga (id_usluga),
  CONSTRAINT fk_cijena_usluge_usluga
    FOREIGN KEY (id_usluga) REFERENCES usluga (id)
    ON DELETE CASCADE
);


CREATE TABLE raspored_djelatnika (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_djelatnik INTEGER UNSIGNED NOT NULL,
  datum DATE NOT NULL,
  vrijeme_od TIME NOT NULL,
  vrijeme_do TIME NOT NULL,
  biljeska VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_raspored_djelatnika_zaposlenik (id_djelatnik),
  KEY idx_raspored_djelatnik_datum (datum),
  CONSTRAINT chk_raspored_djelatnik_vremenski_raspon CHECK (vrijeme_od <= vrijeme_do),
  CONSTRAINT fk_raspored_djelatnika_djelatnik
    FOREIGN KEY (id_djelatnik) REFERENCES zaposlenik (id)
    ON DELETE CASCADE
);

CREATE TABLE termin_pacijenta (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pacijent INTEGER UNSIGNED NOT NULL,
  id_zaposlenik INTEGER UNSIGNED NULL,
  id_ordinacija INTEGER UNSIGNED NOT NULL,
  status_termina VARCHAR(30) NOT NULL DEFAULT 'ZAKAZAN',
  vrijeme_odrzavanja DATETIME NOT NULL,
  procjenjeno_trajanje_pregleda_minute INT NOT NULL DEFAULT 0,
  razlog_dolaska VARCHAR(1000) NOT NULL DEFAULT '-',
  razlog_otkazivanja VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_termin_pacijenta_pacijent (id_pacijent),
  KEY idx_termin_pacijenta_zaposlenik (id_zaposlenik),
  KEY idx_termin_pacijenta_ordinacija (id_ordinacija),
  CONSTRAINT chk_status_termina CHECK (status_termina IN (
    'ZAKAZAN', 'OTKAZAN', 'DOLAZAK', 'NEMA_DOLASKA', 'ZAVRSEN'
  )),
  CONSTRAINT fk_termin_pacijenta_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_termin_pacijenta_zaposlenik
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_termin_pacijenta_ordinacija
    FOREIGN KEY (id_ordinacija) REFERENCES ordinacija (id)
    ON DELETE RESTRICT
);

CREATE TABLE termin_pacijenta_usluga (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_termin_pacijenta INTEGER UNSIGNED NOT NULL,
  id_usluga INTEGER UNSIGNED NOT NULL,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_termin_pacijenta_usluga (id_termin_pacijenta, id_usluga),
  KEY idx_tpu_termin (id_termin_pacijenta),
  KEY idx_tpu_usluga (id_usluga),
  CONSTRAINT fk_tpu_termin
    FOREIGN KEY (id_termin_pacijenta) REFERENCES termin_pacijenta (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_tpu_usluga
    FOREIGN KEY (id_usluga) REFERENCES usluga (id)
    ON DELETE RESTRICT
);



CREATE TABLE pregled (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_termin_pacijenta INTEGER UNSIGNED NOT NULL,
  id_pacijent INTEGER UNSIGNED NOT NULL,
  id_zaposlenik INTEGER UNSIGNED NULL DEFAULT NULL,
  status_pregleda VARCHAR(30) NOT NULL DEFAULT 'OTVOREN',
  vrijeme_odrzavanja_pregleda DATETIME NOT NULL,
  anamneza TEXT,
  zakljucak TEXT,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_pregled_termin (id_termin_pacijenta),
  KEY idx_pregled_pacijent (id_pacijent),
  KEY idx_pregled_zaposlenik (id_zaposlenik),
  CONSTRAINT chk_status_pregleda CHECK (status_pregleda IN ('OTVOREN', 'ZAVRSEN', 'STORNO')),
  CONSTRAINT fk_pregled_termin
    FOREIGN KEY (id_termin_pacijenta) REFERENCES termin_pacijenta (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_pregled_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_pregled_zaposlenik
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id)
    ON DELETE SET NULL
);

CREATE TABLE pregled_usluga (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pregled INTEGER UNSIGNED NOT NULL,
  id_usluga INTEGER UNSIGNED NOT NULL,
  kolicina DECIMAL(18,2) NOT NULL DEFAULT 1,
  cijena DECIMAL(18,2) NOT NULL,
  popust DECIMAL(5,2) NOT NULL DEFAULT 0,
  porezna_stopa DECIMAL(5,2) NOT NULL DEFAULT 0,
  ukupni_iznos DECIMAL(18,2) NOT NULL DEFAULT 0,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_pregled_usluga_pregled (id_pregled),
  KEY idx_pregled_usluga_usluga (id_usluga),
  CONSTRAINT fk_pregled_usluga_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_pregled_usluga_usluga
    FOREIGN KEY (id_usluga) REFERENCES usluga (id)
    ON DELETE RESTRICT
);

CREATE TABLE dijagnoza (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra CHAR(3) NOT NULL,
  naziv VARCHAR(255) NOT NULL,
  opis VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_dijagnoza_sifra (sifra)
);

CREATE TABLE pregled_dijagnoza (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pregled INTEGER UNSIGNED NOT NULL,
  id_dijagnoza INTEGER UNSIGNED NOT NULL,
  primarna_oznaka boolean not null default true,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_pregled_dijagnoza_pregled (id_pregled),
  KEY idx_pregled_dijagnoza_dijagnoza (id_dijagnoza),
  CONSTRAINT fk_pregled_dijagnoza_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_pregled_dijagnoza_dijagnoza
    FOREIGN KEY (id_dijagnoza) REFERENCES dijagnoza (id)
    ON DELETE RESTRICT
);

CREATE TABLE tip_nalaza (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(20) NOT NULL,
  naziv VARCHAR(200) NOT NULL,
  opis VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_tip_nalaza_sifra (sifra)
);

CREATE TABLE nalaz (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pregled INTEGER UNSIGNED NOT NULL,
  id_pacijent INTEGER UNSIGNED NOT NULL,
  id_zaposlenik INTEGER UNSIGNED  NULL,
  status_nalaza VARCHAR(30) NOT NULL DEFAULT 'NACRT',
  izdano_u DATETIME NOT NULL,
  sazetak VARCHAR(1000) NOT NULL DEFAULT '-',
  napomena TEXT,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_nalaz_pacijent (id_pacijent),
  KEY idx_nalaz_pregled (id_pregled),
  KEY idx_nalaz_zaposlenik (id_zaposlenik),
  CONSTRAINT chk_status_nalaza CHECK (status_nalaza IN (
    'NACRT', 'UPISAN', 'VERIFIKACIJA', 'IZDAN', 'STORNO'
  )),
  CONSTRAINT fk_nalaz_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_nalaz_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_nalaz_zaposlenik
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id)
    ON DELETE SET NULL
);

CREATE TABLE laboratorijski_parametar (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra CHAR(10) NOT NULL,
  naziv VARCHAR(100) NOT NULL,
  opis VARCHAR(1000) NOT NULL DEFAULT '-',
  jedinica VARCHAR(50) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_laboratorijski_parametar_sifra (sifra)
);

CREATE TABLE laboratorijski_rezultat (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_nalaz INTEGER UNSIGNED NOT NULL,
  id_laboratorijski_parametar INTEGER UNSIGNED NULL,
  uzorkovano_u DATETIME NOT NULL,
  izmjereno_u DATETIME NOT NULL,
  rezultat_tekst VARCHAR(1000) NOT NULL DEFAULT '-',
  rezultat_broj DECIMAL(18,6) NOT NULL DEFAULT 0,
  referentni_min DECIMAL(18,6) NOT NULL DEFAULT 0,
  referentni_max DECIMAL(18,6) NOT NULL DEFAULT 0,
  oznaka_odstupanja SMALLINT NOT NULL DEFAULT 0,
  opis_odstupanja VARCHAR(255) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_laboratorijski_rezultat_nalaz (id_nalaz),
  KEY idx_laboratorijski_rezultat_parametar (id_laboratorijski_parametar),
  CONSTRAINT fk_laboratorijski_rezultat_nalaz
    FOREIGN KEY (id_nalaz) REFERENCES nalaz (id)
     ON DELETE CASCADE,
  CONSTRAINT fk_laboratorijski_rezultat_parametar
    FOREIGN KEY (id_laboratorijski_parametar) REFERENCES laboratorijski_parametar (id)
    ON DELETE SET NULL
);

CREATE TABLE terapija (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pregled INTEGER UNSIGNED NOT NULL,
  id_nalaz INTEGER UNSIGNED NULL,
  preporuceno_u DATETIME NOT NULL,
  tekst_preporuke TEXT NOT NULL,
  potrebna_kontrola BOOLEAN NOT NULL DEFAULT FALSE,
  datum_kontrole DATE NULL,
  napomena VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_terapija_pregled (id_pregled),
  KEY idx_terapija_nalaz (id_nalaz),
  CONSTRAINT fk_terapija_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_terapija_nalaz
    FOREIGN KEY (id_nalaz) REFERENCES nalaz (id)
    ON DELETE SET NULL
);

CREATE TABLE preporuceni_lijek (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_terapija INTEGER UNSIGNED NOT NULL,
  naziv_lijeka VARCHAR(200) NOT NULL,
  doziranje VARCHAR(100) NOT NULL DEFAULT '-',
  uputa VARCHAR(1000) NOT NULL DEFAULT '-',
  trajanje_dana INT NOT NULL DEFAULT 0,
  napomena VARCHAR(500) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_preporuceni_lijek_terapija (id_terapija),
  CONSTRAINT fk_preporuceni_lijek_terapija
    FOREIGN KEY (id_terapija) REFERENCES terapija (id)
    ON DELETE CASCADE
);

CREATE TABLE nacin_placanja (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(10) NOT NULL,
  naziv VARCHAR(100) NOT NULL,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_nacin_placanja_sifra (sifra)
);

CREATE TABLE racun (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  broj_racuna VARCHAR(50) NOT NULL,
  id_pacijent INTEGER UNSIGNED NULL DEFAULT NULL,
  id_pregled INTEGER UNSIGNED NULL DEFAULT NULL,
  status_racuna VARCHAR(30) NOT NULL DEFAULT 'NACRT',
  datum_izdavanja DATE NOT NULL,
  datum_dospijeca DATE NULL,
  valuta CHAR(3) NOT NULL DEFAULT 'EUR',
  ukupno_bez_poreza DECIMAL(18,2) NOT NULL DEFAULT 0,
  ukupni_porez DECIMAL(18,2) NOT NULL DEFAULT 0,
  ukupni_popust DECIMAL(18,2) NOT NULL DEFAULT 0,
  ukupno_za_placanje DECIMAL(18,2) NOT NULL DEFAULT 0,
  napomena VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_broj_racuna (broj_racuna),
  KEY idx_racun_pacijent (id_pacijent),
  KEY idx_racun_pregled (id_pregled),
  CONSTRAINT chk_status_racuna CHECK (status_racuna IN ('NACRT', 'IZDAN', 'PLACEN', 'STORNO')),

  CONSTRAINT fk_racun_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_racun_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id)
    ON DELETE CASCADE
);

CREATE TABLE stavka_racuna (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_racun INTEGER UNSIGNED NOT NULL,
  id_pregled_usluga INTEGER UNSIGNED NULL DEFAULT NULL,
  id_usluga INTEGER UNSIGNED NULL DEFAULT NULL,
  opis VARCHAR(500) NOT NULL DEFAULT '-',
  kolicina DECIMAL(18,2) NOT NULL DEFAULT 1,
  jedinicna_cijena DECIMAL(18,2) NOT NULL DEFAULT 0,
  stopa_popusta DECIMAL(5,2) NOT NULL DEFAULT 0,
  stopa_poreza DECIMAL(5,2) NOT NULL DEFAULT 0,
  iznos_bez_poreza DECIMAL(18,2) NOT NULL DEFAULT 0,
  iznos_poreza DECIMAL(18,2) NOT NULL DEFAULT 0,
  ukupan_iznos DECIMAL(18,2) NOT NULL DEFAULT 0,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_stavka_racuna_racun (id_racun),
  KEY idx_stavka_racuna_pregled_usluga (id_pregled_usluga),
  KEY idx_stavka_racuna_usluga (id_usluga),
  CONSTRAINT fk_stavka_racuna_racun
    FOREIGN KEY (id_racun) REFERENCES racun (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_stavka_racuna_pregled_usluga
    FOREIGN KEY (id_pregled_usluga) REFERENCES pregled_usluga (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_stavka_racuna_usluga
    FOREIGN KEY (id_usluga) REFERENCES usluga (id)
    ON DELETE SET NULL
);

CREATE TABLE uplata (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  id_racun INTEGER UNSIGNED NOT NULL,
  id_nacin_placanja INTEGER UNSIGNED NOT NULL,
  placeno_u DATETIME NOT NULL,
  iznos DECIMAL(18,2) NOT NULL DEFAULT 0,
  referenca_transakcije VARCHAR(100) NOT NULL DEFAULT '-',
  napomena VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_uplata_racun (id_racun),
  KEY idx_uplata_nacin_placanja (id_nacin_placanja),
  KEY idx_uplata_placeno_u (placeno_u),
  CONSTRAINT fk_uplata_racun
    FOREIGN KEY (id_racun) REFERENCES racun (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_uplata_nacin_placanja
    FOREIGN KEY (id_nacin_placanja) REFERENCES nacin_placanja (id)
    ON DELETE RESTRICT
);

-- =========================================================
-- POVEZANOST TABLICA (usklađeno s FK-ovima u ovom DDL-u)
-- =========================================================
-- pacijent:  termin_pacijenta, pregled, nalaz (samo samostalan nalaz), racun (bez pregleda)
-- odjel: ordinacija, usluga
-- ordinacija: zaposlenik, termin_pacijenta
-- specijalizacija: zaposlenik
-- zaposlenik: raspored_djelatnika, termin_pacijenta, pregled (obavljeni), nalaz (samo samostalan)
-- usluga: cijena_usluge, termin_pacijenta_usluga (M:N s terminom), pregled_usluga, stavka_racuna (samo ako nema reda pregled_usluga)
-- termin_pacijenta: termin_pacijenta_usluga (M:N s uslugom); pregled (opcionalno; walk-in pregled ima id_termin_pacijenta NULL)
-- pregled: obavezno id_pacijent (walk-in ili kopija s termina); opcionalno id_termin_pacijenta;
--          opcionalno id_zaposlenik_obavljen; terapija, racun, pregled_usluga, pregled_dijagnoza,
--           nalaz (vezani nalaz)
-- dijagnoza: pregled_dijagnoza
-- tip_nalaza: nalaz
-- nalaz: laboratorijski_rezultat, terapija; ili uz pregled (bez pacijent/zaposlenik) ili samostalan
-- laboratorijski_parametar: laboratorijski_rezultat
-- terapija: preporuceni_lijek (pacijent preko pregled.id_pacijent ili preko termina ako postoji)
-- nacin_placanja: uplata
-- racun: stavka_racuna, uplata; pacijent NULL ako je vezan uz pregled (pacijent na racunu: pregled.id_pacijent)
-- stavka_racuna: ili id_pregled_usluga (izvor za račun uz pregled) ili id_usluga (račun bez pregleda)