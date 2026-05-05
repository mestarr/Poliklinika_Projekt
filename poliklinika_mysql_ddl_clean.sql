DROP DATABASE IF EXISTS poliklinika;
CREATE DATABASE poliklinika;

USE poliklinika;

-- Model uskladen s akademskom kritikom: jedan izvor istine po koraku u glavnom toku
-- (termin -> pregled -> pregled_usluga -> racun); termin s uslugom i ordinacijom;
-- stavka_racuna vezana na pregled_usluga ili samo na uslugu; statusi u stupcu + CHECK;
-- bez hijerarhije sifarnik_usluga; zaposlenik samo na ordinaciju (odjel preko nje);
-- privitak opcenito (tocno jedan roditelj: pregled, nalaz, uputnica ili racun).

CREATE TABLE pacijent (
  id_pacijent BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  oib CHAR(11) NOT NULL,
  mbo VARCHAR(30) NOT NULL,
  ime VARCHAR(100) NOT NULL,
  prezime VARCHAR(100) NOT NULL,
  spol CHAR(1) NOT NULL DEFAULT 'm',
  datum_rodjenja DATE NOT NULL,
  broj_mobitela VARCHAR(50) NOT NULL,
  email_adresa VARCHAR(100) NOT NULL,
  adresa_stanovanja VARCHAR(255) NOT NULL,
  grad VARCHAR(100) NOT NULL,
  biljeska VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_pacijent),
  UNIQUE KEY uq_oib_pacijenta (oib),
  UNIQUE KEY uq_mbo_pacijenta (mbo),
  CONSTRAINT chk_spol_pacijenta CHECK (spol IN ('m', 'ž', 'o'))
);

CREATE TABLE odjel (
  id_odjel BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(50) NOT NULL,
  naziv VARCHAR(200) NOT NULL,
  opis VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_odjel),
  UNIQUE KEY uq_sifra_odjela (sifra)
);

CREATE TABLE ordinacija (
  id_ordinacija BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_odjel BIGINT UNSIGNED NOT NULL,
  sifra VARCHAR(50) NOT NULL,
  naziv VARCHAR(200) NOT NULL,
  opis VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_ordinacija),
  UNIQUE KEY uq_sifra_ordinacije (sifra),
  KEY idx_ordinacija_odjel (id_odjel),
  CONSTRAINT fk_ordinacija_odjel
    FOREIGN KEY (id_odjel) REFERENCES odjel (id_odjel)
    ON DELETE RESTRICT
);

CREATE TABLE specijalizacija (
  id_specijalizacija BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(50) NOT NULL,
  naziv VARCHAR(150) NOT NULL,
  opis VARCHAR(1000) DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_specijalizacija),
  UNIQUE KEY uq_sifra_specijalizacije (sifra)
);

CREATE TABLE zaposlenik (
  id_zaposlenik BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(50) NOT NULL,
  ime VARCHAR(100) NOT NULL,
  prezime VARCHAR(100) NOT NULL,
  email VARCHAR(100) DEFAULT '-',
  telefon VARCHAR(50) DEFAULT '-',
  titula VARCHAR(100) DEFAULT 'lijecnik',
  id_specijalizacija BIGINT UNSIGNED NOT NULL,
  id_ordinacija BIGINT UNSIGNED NOT NULL,
  datum_zaposlenja DATE NOT NULL,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_zaposlenik),
  UNIQUE KEY uq_sifra_zaposlenika (sifra),
  KEY idx_zaposlenik_specijalizacija (id_specijalizacija),
  KEY idx_zaposlenik_ordinacija (id_ordinacija),
  CONSTRAINT fk_zaposlenik_specijalizacija
    FOREIGN KEY (id_specijalizacija) REFERENCES specijalizacija (id_specijalizacija)
    ON DELETE RESTRICT,
  CONSTRAINT fk_zaposlenik_ordinacija
    FOREIGN KEY (id_ordinacija) REFERENCES ordinacija (id_ordinacija)
    ON DELETE RESTRICT
);

CREATE TABLE usluga (
  id_usluga BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(50) NOT NULL,
  naziv VARCHAR(200) NOT NULL,
  id_odjel BIGINT UNSIGNED NOT NULL,
  opis VARCHAR(2000) NOT NULL DEFAULT '-',
  trajanje_pregleda_minute INT NOT NULL DEFAULT 0,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_usluga),
  UNIQUE KEY uq_sifra_usluge (sifra),
  KEY idx_usluga_odjel (id_odjel),
  CONSTRAINT fk_usluga_odjel
    FOREIGN KEY (id_odjel) REFERENCES odjel (id_odjel)
    ON DELETE RESTRICT
);

CREATE TABLE cijena_usluge (
  id_cijena_usluge BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_usluga BIGINT UNSIGNED NOT NULL,
  datum_od DATE NOT NULL,
  datum_do DATE NOT NULL DEFAULT '9999-12-31',
  iznos DECIMAL(18,2) NOT NULL,
  valuta CHAR(3) NOT NULL DEFAULT 'EUR',
  porezna_stopa DECIMAL(5,2) NOT NULL DEFAULT 0,
  napomena VARCHAR(500) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_cijena_usluge),
  KEY idx_cijena_usluge_usluga (id_usluga),
  CONSTRAINT fk_cijena_usluge_usluga
    FOREIGN KEY (id_usluga) REFERENCES usluga (id_usluga)
    ON DELETE RESTRICT
);

CREATE TABLE uputnica (
  id_uputnica BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pacijent BIGINT UNSIGNED NOT NULL,
  broj_uputnice VARCHAR(100) NOT NULL,
  datum_uputnice DATE NOT NULL,
  opis VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_uputnica),
  KEY idx_uputnica_pacijent (id_pacijent),
  CONSTRAINT fk_uputnica_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id_pacijent)
    ON DELETE CASCADE
);

CREATE TABLE raspored_djelatnika (
  id_raspored_djelatnika BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_djelatnik BIGINT UNSIGNED NOT NULL,
  datum DATE NOT NULL,
  vrijeme_od TIME NOT NULL,
  vrijeme_do TIME NOT NULL,
  biljeska VARCHAR(500) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_raspored_djelatnika),
  KEY idx_raspored_djelatnika_zaposlenik (id_djelatnik),
  KEY idx_raspored_djelatnik_datum (datum),
  CONSTRAINT chk_raspored_djelatnik_vremenski_raspon CHECK (vrijeme_od <= vrijeme_do),
  CONSTRAINT fk_raspored_djelatnika_djelatnik
    FOREIGN KEY (id_djelatnik) REFERENCES zaposlenik (id_zaposlenik)
    ON DELETE RESTRICT
);

CREATE TABLE termin_pacijenta (
  id_termin_pacijenta BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pacijent BIGINT UNSIGNED NOT NULL,
  id_uputnica BIGINT UNSIGNED NULL,
  id_zaposlenik BIGINT UNSIGNED NOT NULL,
  id_usluga BIGINT UNSIGNED NOT NULL,
  id_ordinacija BIGINT UNSIGNED NOT NULL,
  status_termina VARCHAR(30) NOT NULL DEFAULT 'ZAKAZAN',
  vrijeme_odrzavanja DATETIME NOT NULL,
  procjenjeno_trajanje_pregleda_minute INT NOT NULL DEFAULT 0,
  razlog_dolaska VARCHAR(1000) NOT NULL DEFAULT '-',
  razlog_otkazivanja VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_termin_pacijenta),
  KEY idx_termin_pacijenta_pacijent (id_pacijent),
  KEY idx_termin_pacijenta_uputnica (id_uputnica),
  KEY idx_termin_pacijenta_zaposlenik (id_zaposlenik),
  KEY idx_termin_pacijenta_usluga (id_usluga),
  KEY idx_termin_pacijenta_ordinacija (id_ordinacija),
  CONSTRAINT chk_status_termina CHECK (status_termina IN (
    'ZAKAZAN', 'OTKAZAN', 'DOLAZAK', 'NEMA_DOLASKA', 'ZAVRSEN'
  )),
  CONSTRAINT fk_termin_pacijenta_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id_pacijent)
    ON DELETE RESTRICT,
  CONSTRAINT fk_termin_pacijenta_uputnica
    FOREIGN KEY (id_uputnica) REFERENCES uputnica (id_uputnica)
    ON DELETE RESTRICT,
  CONSTRAINT fk_termin_pacijenta_zaposlenik
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id_zaposlenik)
    ON DELETE RESTRICT,
  CONSTRAINT fk_termin_pacijenta_usluga
    FOREIGN KEY (id_usluga) REFERENCES usluga (id_usluga)
    ON DELETE RESTRICT,
  CONSTRAINT fk_termin_pacijenta_ordinacija
    FOREIGN KEY (id_ordinacija) REFERENCES ordinacija (id_ordinacija)
    ON DELETE RESTRICT
);

CREATE TABLE pregled (
  id_pregled BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_termin_pacijenta BIGINT UNSIGNED NOT NULL,
  id_zaposlenik_obavljen BIGINT UNSIGNED NULL DEFAULT NULL,
  status_pregleda VARCHAR(30) NOT NULL DEFAULT 'OTVOREN',
  vrijeme_odrzavanja_pregleda DATETIME NOT NULL,
  anamneza TEXT NOT NULL,
  zakljucak TEXT NOT NULL,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_pregled),
  KEY idx_pregled_termin (id_termin_pacijenta),
  KEY idx_pregled_zaposlenik_obavljen (id_zaposlenik_obavljen),
  CONSTRAINT chk_status_pregleda CHECK (status_pregleda IN ('OTVOREN', 'ZAVRSEN', 'STORNO')),
  CONSTRAINT fk_pregled_termin
    FOREIGN KEY (id_termin_pacijenta) REFERENCES termin_pacijenta (id_termin_pacijenta)
    ON DELETE RESTRICT,
  CONSTRAINT fk_pregled_zaposlenik_obavljen
    FOREIGN KEY (id_zaposlenik_obavljen) REFERENCES zaposlenik (id_zaposlenik)
    ON DELETE RESTRICT
);

CREATE TABLE pregled_usluga (
  id_pregled_usluga BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pregled BIGINT UNSIGNED NOT NULL,
  id_usluga BIGINT UNSIGNED NOT NULL,
  kolicina DECIMAL(18,2) NOT NULL DEFAULT 1,
  cijena DECIMAL(18,2) NOT NULL,
  popust DECIMAL(5,2) NOT NULL DEFAULT 0,
  porezna_stopa DECIMAL(5,2) NOT NULL DEFAULT 0,
  ukupni_iznos DECIMAL(18,2) NOT NULL DEFAULT 0,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_pregled_usluga),
  KEY idx_pregled_usluga_pregled (id_pregled),
  KEY idx_pregled_usluga_usluga (id_usluga),
  CONSTRAINT fk_pregled_usluga_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id_pregled)
    ON DELETE RESTRICT,
  CONSTRAINT fk_pregled_usluga_usluga
    FOREIGN KEY (id_usluga) REFERENCES usluga (id_usluga)
    ON DELETE RESTRICT
);

CREATE TABLE dijagnoza (
  id_dijagnoza BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(20) NOT NULL,
  naziv VARCHAR(500) NOT NULL,
  opis VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_dijagnoza),
  UNIQUE KEY uq_dijagnoza_sifra (sifra)
);

CREATE TABLE pregled_dijagnoza (
  id_pregled_dijagnoza BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pregled BIGINT UNSIGNED NOT NULL,
  id_dijagnoza BIGINT UNSIGNED NOT NULL,
  primarna_oznaka BIT(1) NOT NULL DEFAULT b'0',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_pregled_dijagnoza),
  KEY idx_pregled_dijagnoza_pregled (id_pregled),
  KEY idx_pregled_dijagnoza_dijagnoza (id_dijagnoza),
  CONSTRAINT fk_pregled_dijagnoza_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id_pregled)
    ON DELETE RESTRICT,
  CONSTRAINT fk_pregled_dijagnoza_dijagnoza
    FOREIGN KEY (id_dijagnoza) REFERENCES dijagnoza (id_dijagnoza)
    ON DELETE RESTRICT
);

CREATE TABLE tip_nalaza (
  id_tip_nalaza BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(20) NOT NULL,
  naziv VARCHAR(200) NOT NULL,
  opis VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_tip_nalaza),
  UNIQUE KEY uq_tip_nalaza_sifra (sifra)
);

CREATE TABLE nalaz (
  id_nalaz BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pregled BIGINT UNSIGNED NULL DEFAULT NULL,
  id_pacijent BIGINT UNSIGNED NULL DEFAULT NULL,
  id_zaposlenik BIGINT UNSIGNED NULL DEFAULT NULL,
  id_tip_nalaza BIGINT UNSIGNED NOT NULL,
  status_nalaza VARCHAR(30) NOT NULL DEFAULT 'NACRT',
  izdano_u DATETIME NOT NULL,
  sazetak VARCHAR(1000) NOT NULL DEFAULT '-',
  napomena TEXT NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_nalaz),
  KEY idx_nalaz_pacijent (id_pacijent),
  KEY idx_nalaz_tip (id_tip_nalaza),
  KEY idx_nalaz_pregled (id_pregled),
  KEY idx_nalaz_zaposlenik (id_zaposlenik),
  CONSTRAINT chk_status_nalaza CHECK (status_nalaza IN (
    'NACRT', 'UPISAN', 'VERIFIKACIJA', 'IZDAN', 'STORNO'
  )),
  CONSTRAINT chk_nalaz_pregled_ili_samostalan CHECK (
    (id_pregled IS NOT NULL AND id_pacijent IS NULL AND id_zaposlenik IS NULL)
    OR
    (id_pregled IS NULL AND id_pacijent IS NOT NULL AND id_zaposlenik IS NOT NULL)
  ),
  CONSTRAINT fk_nalaz_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id_pacijent)
    ON DELETE CASCADE,
  CONSTRAINT fk_nalaz_tip
    FOREIGN KEY (id_tip_nalaza) REFERENCES tip_nalaza (id_tip_nalaza)
    ON DELETE RESTRICT,
  CONSTRAINT fk_nalaz_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id_pregled)
    ON DELETE RESTRICT,
  CONSTRAINT fk_nalaz_zaposlenik
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id_zaposlenik)
    ON DELETE RESTRICT
);

CREATE TABLE laboratorijski_parametar (
  id_laboratorijski_parametar BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(20) NOT NULL,
  naziv VARCHAR(200) NOT NULL,
  opis VARCHAR(1000) NOT NULL DEFAULT '-',
  jedinica VARCHAR(50) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_laboratorijski_parametar),
  UNIQUE KEY uq_laboratorijski_parametar_sifra (sifra)
);

CREATE TABLE laboratorijski_rezultat (
  id_laboratorijski_rezultat BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_nalaz BIGINT UNSIGNED NOT NULL,
  id_laboratorijski_parametar BIGINT UNSIGNED NOT NULL,
  uzorkovano_u DATETIME NULL,
  izmjereno_u DATETIME NULL,
  rezultat_tekst VARCHAR(1000) NOT NULL DEFAULT '-',
  rezultat_broj DECIMAL(18,6) NOT NULL DEFAULT 0,
  referentni_min DECIMAL(18,6) NOT NULL DEFAULT 0,
  referentni_max DECIMAL(18,6) NOT NULL DEFAULT 0,
  oznaka_odstupanja SMALLINT NOT NULL DEFAULT 0,
  opis_odstupanja VARCHAR(255) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_laboratorijski_rezultat),
  KEY idx_laboratorijski_rezultat_nalaz (id_nalaz),
  KEY idx_laboratorijski_rezultat_parametar (id_laboratorijski_parametar),
  CONSTRAINT fk_laboratorijski_rezultat_nalaz
    FOREIGN KEY (id_nalaz) REFERENCES nalaz (id_nalaz)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_laboratorijski_rezultat_parametar
    FOREIGN KEY (id_laboratorijski_parametar) REFERENCES laboratorijski_parametar (id_laboratorijski_parametar)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE terapija (
  id_terapija BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pregled BIGINT UNSIGNED NOT NULL,
  id_nalaz BIGINT UNSIGNED NULL,
  preporuceno_u DATETIME NOT NULL,
  tekst_preporuke TEXT NOT NULL,
  potrebna_kontrola_flag BIT(1) NOT NULL DEFAULT b'0',
  datum_kontrole DATE NULL,
  napomena VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_terapija),
  KEY idx_terapija_pregled (id_pregled),
  KEY idx_terapija_nalaz (id_nalaz),
  CONSTRAINT fk_terapija_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id_pregled)
    ON DELETE RESTRICT,
  CONSTRAINT fk_terapija_nalaz
    FOREIGN KEY (id_nalaz) REFERENCES nalaz (id_nalaz)
    ON DELETE RESTRICT
);

CREATE TABLE preporuceni_lijek (
  id_preporuceni_lijek BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_terapija BIGINT UNSIGNED NOT NULL,
  naziv_lijeka VARCHAR(200) NOT NULL,
  doziranje VARCHAR(100) NOT NULL DEFAULT '-',
  uputa VARCHAR(1000) NOT NULL DEFAULT '-',
  trajanje_dana INT NOT NULL DEFAULT 0,
  napomena VARCHAR(500) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_preporuceni_lijek),
  KEY idx_preporuceni_lijek_terapija (id_terapija),
  CONSTRAINT fk_preporuceni_lijek_terapija
    FOREIGN KEY (id_terapija) REFERENCES terapija (id_terapija)
    ON DELETE RESTRICT
);

CREATE TABLE nacin_placanja (
  id_nacin_placanja BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(50) NOT NULL,
  naziv VARCHAR(100) NOT NULL,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_nacin_placanja),
  UNIQUE KEY uq_nacin_placanja_sifra (sifra)
);

CREATE TABLE racun (
  id_racun BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  broj_racuna VARCHAR(50) NOT NULL,
  id_pacijent BIGINT UNSIGNED NULL DEFAULT NULL,
  id_pregled BIGINT UNSIGNED NULL DEFAULT NULL,
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
  PRIMARY KEY (id_racun),
  UNIQUE KEY uq_broj_racuna (broj_racuna),
  KEY idx_racun_pacijent (id_pacijent),
  KEY idx_racun_pregled (id_pregled),
  CONSTRAINT chk_status_racuna CHECK (status_racuna IN ('NACRT', 'IZDAN', 'PLACEN', 'STORNO')),
  CONSTRAINT chk_racun_pacijent_izvor CHECK (
    (id_pregled IS NOT NULL AND id_pacijent IS NULL)
    OR (id_pregled IS NULL AND id_pacijent IS NOT NULL)
  ),
  CONSTRAINT fk_racun_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id_pacijent)
    ON DELETE RESTRICT,
  CONSTRAINT fk_racun_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id_pregled)
    ON DELETE RESTRICT
);

CREATE TABLE privitak (
  id_privitak BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pregled BIGINT UNSIGNED NULL DEFAULT NULL,
  id_nalaz BIGINT UNSIGNED NULL DEFAULT NULL,
  id_uputnica BIGINT UNSIGNED NULL DEFAULT NULL,
  id_racun BIGINT UNSIGNED NULL DEFAULT NULL,
  tip_privitka VARCHAR(30) NOT NULL DEFAULT 'PDF',
  naziv_datoteke VARCHAR(255) NOT NULL,
  mime_tip VARCHAR(100) NOT NULL DEFAULT '-',
  velicina_u_bajtovima BIGINT NOT NULL DEFAULT 0,
  putanja_datoteke VARCHAR(500) NOT NULL,
  napomena VARCHAR(500) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_privitak),
  KEY idx_privitak_pregled (id_pregled),
  KEY idx_privitak_nalaz (id_nalaz),
  KEY idx_privitak_uputnica (id_uputnica),
  KEY idx_privitak_racun (id_racun),
  CONSTRAINT chk_privitak_tocno_jedan_roditelj CHECK (
    (id_pregled IS NOT NULL AND id_nalaz IS NULL AND id_uputnica IS NULL AND id_racun IS NULL)
    OR (id_pregled IS NULL AND id_nalaz IS NOT NULL AND id_uputnica IS NULL AND id_racun IS NULL)
    OR (id_pregled IS NULL AND id_nalaz IS NULL AND id_uputnica IS NOT NULL AND id_racun IS NULL)
    OR (id_pregled IS NULL AND id_nalaz IS NULL AND id_uputnica IS NULL AND id_racun IS NOT NULL)
  ),
  CONSTRAINT fk_privitak_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id_pregled)
    ON DELETE CASCADE,
  CONSTRAINT fk_privitak_nalaz
    FOREIGN KEY (id_nalaz) REFERENCES nalaz (id_nalaz)
    ON DELETE CASCADE,
  CONSTRAINT fk_privitak_uputnica
    FOREIGN KEY (id_uputnica) REFERENCES uputnica (id_uputnica)
    ON DELETE CASCADE,
  CONSTRAINT fk_privitak_racun
    FOREIGN KEY (id_racun) REFERENCES racun (id_racun)
    ON DELETE CASCADE
);

CREATE TABLE stavka_racuna (
  id_stavka_racuna BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_racun BIGINT UNSIGNED NOT NULL,
  id_pregled_usluga BIGINT UNSIGNED NULL DEFAULT NULL,
  id_usluga BIGINT UNSIGNED NULL DEFAULT NULL,
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
  PRIMARY KEY (id_stavka_racuna),
  KEY idx_stavka_racuna_racun (id_racun),
  KEY idx_stavka_racuna_pregled_usluga (id_pregled_usluga),
  KEY idx_stavka_racuna_usluga (id_usluga),
  CONSTRAINT chk_stavka_racuna_izvor CHECK (
    (id_pregled_usluga IS NOT NULL AND id_usluga IS NULL)
    OR (id_pregled_usluga IS NULL AND id_usluga IS NOT NULL)
  ),
  CONSTRAINT fk_stavka_racuna_racun
    FOREIGN KEY (id_racun) REFERENCES racun (id_racun)
    ON DELETE RESTRICT,
  CONSTRAINT fk_stavka_racuna_pregled_usluga
    FOREIGN KEY (id_pregled_usluga) REFERENCES pregled_usluga (id_pregled_usluga)
    ON DELETE RESTRICT,
  CONSTRAINT fk_stavka_racuna_usluga
    FOREIGN KEY (id_usluga) REFERENCES usluga (id_usluga)
    ON DELETE RESTRICT
);

CREATE TABLE uplata (
  id_uplata BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_racun BIGINT UNSIGNED NOT NULL,
  id_nacin_placanja BIGINT UNSIGNED NOT NULL,
  placeno_u DATETIME NOT NULL,
  iznos DECIMAL(18,2) NOT NULL DEFAULT 0,
  referenca_transakcije VARCHAR(100) NOT NULL DEFAULT '-',
  napomena VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_uplata),
  KEY idx_uplata_racun (id_racun),
  KEY idx_uplata_nacin_placanja (id_nacin_placanja),
  KEY idx_uplata_placeno_u (placeno_u),
  CONSTRAINT fk_uplata_racun
    FOREIGN KEY (id_racun) REFERENCES racun (id_racun)
    ON DELETE RESTRICT,
  CONSTRAINT fk_uplata_nacin_placanja
    FOREIGN KEY (id_nacin_placanja) REFERENCES nacin_placanja (id_nacin_placanja)
    ON DELETE RESTRICT
);

-- =========================================================
-- POVEZANOST TABLICA (usklađeno s FK-ovima u ovom DDL-u)
-- =========================================================
-- pacijent: uputnica, termin_pacijenta, nalaz (samo samostalan nalaz), racun (bez pregleda)
-- odjel: ordinacija, usluga
-- ordinacija: zaposlenik, termin_pacijenta
-- specijalizacija: zaposlenik
-- zaposlenik: raspored_djelatnika, termin_pacijenta, pregled (obavljeni), nalaz (samo samostalan)
-- usluga: cijena_usluge, termin_pacijenta, pregled_usluga, stavka_racuna (samo ako nema reda pregled_usluga)
-- uputnica: termin_pacijenta, privitak
-- termin_pacijenta: pregled (pacijent/planirani liječnik/vrijeme/usluga/ordinacija ovdje)
-- pregled: opcionalno id_zaposlenik_obavljen (NULL = isti kao u terminu); terapija, racun, pregled_usluga,
--          pregled_dijagnoza, privitak (opcionalno), nalaz (vezani nalaz)
-- dijagnoza: pregled_dijagnoza
-- tip_nalaza: nalaz
-- nalaz: laboratorijski_rezultat, terapija; ili uz pregled (bez pacijent/zaposlenik) ili samostalan
-- laboratorijski_parametar: laboratorijski_rezultat
-- terapija: preporuceni_lijek (pacijent/lijecnik preko id_pregled -> termin)
-- privitak: točno jedan od (pregled, nalaz, uputnica, racun) — opći model dokumenta
-- nacin_placanja: uplata
-- racun: stavka_racuna, uplata; pacijent NULL ako je vezan uz pregled (dohvat preko termina)
-- stavka_racuna: ili id_pregled_usluga (izvor za račun uz pregled) ili id_usluga (račun bez pregleda)
