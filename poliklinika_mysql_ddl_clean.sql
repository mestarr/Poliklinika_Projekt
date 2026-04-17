DROP DATABASE IF EXISTS poliklinika;
CREATE DATABASE poliklinika;

USE poliklinika;


CREATE TABLE pacijent (
  id_pacijent BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  oib CHAR(11) NOT NULL,
  mbo VARCHAR(30) NOT NULL ,
  ime VARCHAR(100) NOT NULL,
  prezime VARCHAR(100) NOT NULL,
  spol CHAR(1) NOT NULL DEFAULT 'm',
  datum_rodjenja DATE NOT NULL,
  broj_mobitela VARCHAR(50) NOT NULL ,
  email_adresa VARCHAR(100) NOT NULL,
  adresa_stanovanja VARCHAR(255) NOT NULL,
  grad VARCHAR(100) NOT NULL ,
  biljeska VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_pacijent),
  UNIQUE KEY uq_oib_pacijenta (oib),
  INDEX idx_oib_pacijenta (oib),
  UNIQUE KEY uq_mbo_pacijenta (mbo),
  INDEX idx_mbo_pacijenta (mbo),
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
  UNIQUE KEY uq_sifra_odjela (sifra),
  KEY idx_sifra_odjela (sifra)
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
  UNIQUE KEY uq_sifra_ureda (sifra),
  KEY idx_sifra_ureda (sifra),
  KEY idx_ured_odjel (id_odjel),
  CONSTRAINT fk_ured_odjel
    FOREIGN KEY (id_odjel) REFERENCES odjel (id_odjel)
     ON DELETE RESTRICT
) ;

CREATE TABLE specijalizacija (
  id_specijalizacija BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(50) NOT NULL UNIQUE,
  naziv VARCHAR(150) NOT NULL,
  opis VARCHAR(1000) DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_specijalizacija),
  UNIQUE KEY uq_sifra_specijalizacije (sifra),
  KEY idx_sifra_specijalizacije (sifra)
);


CREATE TABLE zaposlenik (
  id_zaposlenik BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(50) NOT NULL UNIQUE,
  ime VARCHAR(100) NOT NULL,
  prezime VARCHAR(100) NOT NULL,
  email VARCHAR(100) DEFAULT '-',
  telefon VARCHAR(50) DEFAULT '-',
  titula VARCHAR(100) DEFAULT 'liječnik',
  id_specijalizacija BIGINT UNSIGNED NOT NULL,
  id_odjel BIGINT UNSIGNED NOT NULL,
  id_ordinacija BIGINT UNSIGNED NOT NULL,
  datum_zaposlenja DATE NOT NULL,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_zaposlenik),
  UNIQUE KEY uq_sifra_zaposlenika (sifra),
  KEY idx_zaposlenik_id_specijalizacija (id_specijalizacija),
  KEY idx_zaposlenik_id_odjel (id_odjel),
  KEY idx_zaposlenik_ordinacija_id (id_ordinacija),
  CONSTRAINT fk_zaposlenik_specijalizacija
    FOREIGN KEY (id_specijalizacija) REFERENCES specijalizacija (id_specijalizacija)
    ON DELETE RESTRICT,
  CONSTRAINT fk_zaposlenik_odjel
    FOREIGN KEY (id_odjel) REFERENCES odjel (id_odjel)
    ON  DELETE RESTRICT,
  CONSTRAINT fk_zaposlenik_ordinacija
    FOREIGN KEY (id_ordinacija) REFERENCES ordinacija (id_ordinacija)
    ON  DELETE RESTRICT
);


CREATE TABLE sifarnik_usluga (
  id_sifarnik_usluga BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(50) NOT NULL,
  naziv VARCHAR(100) NOT NULL,
  id_parent_sifarnik_usluga BIGINT UNSIGNED NULL DEFAULT NULL,
  opis VARCHAR(500) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_sifarnik_usluga),
  UNIQUE KEY uq_sifra_sifarnika_usluga (sifra),
  KEY idx_sifra_sifarnika_usluga (sifra),
  CONSTRAINT fk_parent_sifarnik_usluga
    FOREIGN KEY (id_parent_sifarnik_usluga) REFERENCES sifarnik_usluga (id_sifarnik_usluga)
    ON DELETE CASCADE
);

CREATE TABLE usluga (
  id_usluga BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(50) NOT NULL,
  naziv VARCHAR(200) NOT NULL,
  id_sifarnik_usluga BIGINT UNSIGNED NOT NULL,
  id_odjel BIGINT UNSIGNED NOT NULL,
  opis VARCHAR(2000) NOT NULL DEFAULT '-',
  trajanje_pregleda_minute INT NOT NULL DEFAULT 0,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_usluga),
  UNIQUE KEY uq_sifra_usluge (sifra),
  KEY idx_sifra_usluge (sifra),
  KEY idx_sifarnik_usluga_id (id_sifarnik_usluga),
  KEY idx_odjel_id (id_odjel),
  CONSTRAINT fk_sifarnik_usluga
    FOREIGN KEY (id_sifarnik_usluga) REFERENCES sifarnik_usluga (id_sifarnik_usluga)
     ON DELETE RESTRICT,
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
  KEY idx_cijena_usluge_usluga_id (id_usluga),
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
  KEY idx_uputnica_pacijent_id (id_pacijent),
  CONSTRAINT fk_uputnica_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id_pacijent)
    ON DELETE CASCADE
) ;


CREATE TABLE sifarnik_statusa_termina (
  id_status_termina BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(20) NOT NULL,
  naziv VARCHAR(100) NOT NULL,
  opis VARCHAR(500) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_status_termina),
  UNIQUE KEY uq_status_termina (sifra),
  KEY idx_sifarnik_status_termina (sifra)
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
) ;

CREATE TABLE termin_pacijenta (
  id_termin_pacijenta BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pacijent BIGINT UNSIGNED NOT NULL,
  id_uputnica BIGINT UNSIGNED NULL,
  id_zaposlenik BIGINT UNSIGNED NOT NULL,
  id_status_termina BIGINT UNSIGNED NOT NULL,
  vrijeme_odrzavanja DATETIME NOT NULL,
  procjenjeno_trajanje_pregleda_minute INT NOT NULL DEFAULT 0,
  razlog_dolaska VARCHAR(1000) NOT NULL DEFAULT '-',
  razlog_otkazivanja VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_termin_pacijenta),
  KEY idx_termin_pacijenta_pacijent_id (id_pacijent),
  KEY idx_termin_pacijenta_uputnica_id (id_uputnica),
  KEY idx_termin_pacijenta_zaposlenik_id (id_zaposlenik),
  KEY idx_termin_pacijenta_status_id (id_status_termina),
  CONSTRAINT fk__termin_pacijenta_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id_pacijent)
    ON DELETE RESTRICT,
  CONSTRAINT fk_termin_pacijenta_uputnica
    FOREIGN KEY (id_uputnica) REFERENCES uputnica (id_uputnica)
     ON DELETE RESTRICT,
  CONSTRAINT fk_termin_pacijenta_zaposlenik
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id_zaposlenik)
     ON DELETE RESTRICT,
  CONSTRAINT fk_termin_pacijenta_status
    FOREIGN KEY (id_status_termina) REFERENCES sifarnik_statusa_termina (id_status_termina)
     ON DELETE RESTRICT
) ;



CREATE TABLE status_pregleda (
  id_status_pregleda BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(20) NOT NULL,
  naziv VARCHAR(100) NOT NULL,
  opis VARCHAR(500) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_status_pregleda),
  UNIQUE KEY uq_status_pregleda_sifra (sifra)
);
CREATE TABLE pregled (
  id_pregled BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_termin_pacijenta BIGINT UNSIGNED NOT NULL,
  id_pacijent BIGINT UNSIGNED NOT NULL,
  id_zaposlenik BIGINT UNSIGNED NOT NULL,
  id_status_pregleda BIGINT UNSIGNED NOT NULL,
  vrijeme_odrzavanja_pregleda DATETIME NOT NULL,
  anamneza TEXT NOT NULL,
  zakljucak TEXT NOT NULL,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_pregled),
  KEY idx_pregled_termin_id (id_termin_pacijenta),
  KEY idx_pregled_pacijent_id (id_pacijent),
  KEY idx_pregled_zaposlenik_id (id_zaposlenik),
  KEY idx_pregled_status_id (id_status_pregleda),
  CONSTRAINT fk_pregled_termin
    FOREIGN KEY (id_termin_pacijenta) REFERENCES termin_pacijenta (id_termin_pacijenta)
    ON DELETE RESTRICT,
  CONSTRAINT fk_pregled_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id_pacijent)
     ON DELETE RESTRICT,
  CONSTRAINT fk_pregled_zaposlenik
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id_zaposlenik)
     ON DELETE RESTRICT,
  CONSTRAINT fk_pregled_status
    FOREIGN KEY (id_status_pregleda) REFERENCES status_pregleda (id_status_pregleda)
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
  KEY idx_pregled_usluga_pregled_id (id_pregled),
  KEY idx_pregled_usluga_usluga_id (id_usluga),
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
) ;
CREATE TABLE pregled_dijagnoza (
  id_pregled_dijagnoza BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pregled BIGINT UNSIGNED NOT NULL,
  id_dijagnoza BIGINT UNSIGNED NOT NULL,
  primarna_oznaka BIT(1) NOT NULL DEFAULT b'0',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_pregled_dijagnoza),
  KEY idx_pregled_dijagnoza_pregled_id (id_pregled),
  KEY idx_pregled_dijagnoza_dijagnoza_id (id_dijagnoza),
  CONSTRAINT fk_pregled_dijagnoza_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id_pregled)
    ON DELETE RESTRICT,
  CONSTRAINT fk_pregled_dijagnoza_dijagnoza
    FOREIGN KEY (id_dijagnoza) REFERENCES dijagnoza (id_dijagnoza)
    ON DELETE RESTRICT
) ;
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
CREATE TABLE status_nalaza (
  id_status_nalaza BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(20) NOT NULL,
  naziv VARCHAR(100) NOT NULL,
  opis VARCHAR(500) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_status_nalaza),
  UNIQUE KEY uq_status_nalaza_sifra (sifra)
);
CREATE TABLE nalaz (
  id_nalaz BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pacijent BIGINT UNSIGNED NOT NULL,
  id_zaposlenik BIGINT UNSIGNED NOT NULL,
  id_tip_nalaza BIGINT UNSIGNED NOT NULL,
  id_status_nalaza BIGINT UNSIGNED NOT NULL,
  id_pregled BIGINT UNSIGNED NULL,
  izdano_u DATETIME NOT NULL,
  sazetak VARCHAR(1000) NOT NULL DEFAULT '-',
  napomena TEXT NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_nalaz),
  KEY idx_nalaz_pacijent_id (id_pacijent),
  KEY idx_nalaz_tip_id (id_tip_nalaza),
  KEY idx_nalaz_status_id (id_status_nalaza),
  KEY idx_nalaz_pregled_id (id_pregled),
  CONSTRAINT fk_nalaz_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id_pacijent)
    ON DELETE CASCADE,
  CONSTRAINT fk_nalaz_tip
    FOREIGN KEY (id_tip_nalaza) REFERENCES tip_nalaza (id_tip_nalaza)
    ON DELETE RESTRICT,
  CONSTRAINT fk_nalaz_status
    FOREIGN KEY (id_status_nalaza) REFERENCES status_nalaza (id_status_nalaza)
     ON DELETE RESTRICT,
  CONSTRAINT fk_nalaz_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id_pregled)
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
  UNIQUE KEY uq_laboratorijski_parametar_sifra (sifra),
  KEY idx_laboratorijski_parametar_sifra (sifra)
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
  KEY idx_laboratorijski_rezultat_nalaz_id (id_nalaz),
  KEY idx_laboratorijski_rezultat_parametar_id (id_laboratorijski_parametar),
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
  id_pacijent BIGINT UNSIGNED NOT NULL,
  id_zaposlenik BIGINT UNSIGNED NOT NULL,
  id_nalaz BIGINT UNSIGNED NULL,
  preporuceno_u DATETIME NOT NULL,
  tekst_preporuke TEXT NOT NULL,
  potrebna_kontrola_flag BIT(1) NOT NULL DEFAULT b'0',
  datum_kontrole DATE NULL,
  napomena VARCHAR(1000) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_terapija),
  KEY idx_terapija_pregled_id (id_pregled),
  KEY idx_terapija_pacijent_id (id_pacijent),
  KEY idx_terapija_zaposlenik_id (id_zaposlenik),
  KEY idx_terapija_nalaz_id (id_nalaz),
  CONSTRAINT fk_terapija_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id_pregled)
    ON  DELETE RESTRICT,
  CONSTRAINT fk_terapija_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id_pacijent)
    ON DELETE CASCADE,
  CONSTRAINT fk_terapija_zaposlenik
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id_zaposlenik)
    ON DELETE RESTRICT,
  CONSTRAINT fk_terapija_nalaz
    FOREIGN KEY (id_nalaz) REFERENCES nalaz (id_nalaz)
    ON DELETE RESTRICT
) ;
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
  KEY idx_preporuceni_lijek_terapija_id (id_terapija),
  CONSTRAINT fk_preporuceni_lijek_terapija
    FOREIGN KEY (id_terapija) REFERENCES terapija (id_terapija)
    ON DELETE RESTRICT
) ;
CREATE TABLE privitak_pregleda (
  id_privitak_pregleda BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pregled BIGINT UNSIGNED NOT NULL,
  tip_privitka VARCHAR(30) NOT NULL DEFAULT 'PDF',
  naziv_datoteke VARCHAR(255) NOT NULL,
  mime_tip VARCHAR(100) NOT NULL DEFAULT '-',
  velicina_u_bajtovima BIGINT NOT NULL DEFAULT 0,
  putanja_datoteke VARCHAR(500) NOT NULL,
  napomena VARCHAR(500) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_privitak_pregleda),
  KEY idx_privitak_pregleda_pregled_id (id_pregled),
  CONSTRAINT fk_privitak_pregleda_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id_pregled)
    ON DELETE CASCADE
);

CREATE TABLE nacin_placanja (
  id_nacin_placanja BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(50) NOT NULL ,
  naziv VARCHAR(100) NOT NULL,
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_nacin_placanja),
  UNIQUE KEY uq_nacin_placanja_sifra (sifra),
  KEY idx_nacin_placanja_sifra (sifra)
);
CREATE TABLE status_racuna (
  id_status_racuna BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sifra VARCHAR(20) NOT NULL,
  naziv VARCHAR(100) NOT NULL,
  opis VARCHAR(500) NOT NULL DEFAULT '-',
  vrijeme_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vrijeme_azuriranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_status_racuna),
  UNIQUE KEY uq_status_racuna_sifra (sifra)
);
CREATE TABLE racun (
  id_racun BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  broj_racuna VARCHAR(50) NOT NULL,
  id_pacijent BIGINT UNSIGNED NOT NULL,
  id_status_racuna BIGINT UNSIGNED NOT NULL,
  id_pregled BIGINT UNSIGNED NULL,
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
  KEY idx_racun_pacijent_id (id_pacijent),
  KEY idx_racun_status_id (id_status_racuna),
  KEY idx_racun_pregled_id (id_pregled),
  CONSTRAINT fk_racun_pacijent
    FOREIGN KEY (id_pacijent) REFERENCES pacijent (id_pacijent)
    ON DELETE RESTRICT,
  CONSTRAINT fk_racun_status
    FOREIGN KEY (id_status_racuna) REFERENCES status_racuna (id_status_racuna)
    ON DELETE RESTRICT,
  CONSTRAINT fk_racun_pregled
    FOREIGN KEY (id_pregled) REFERENCES pregled (id_pregled)
    ON DELETE RESTRICT
);

CREATE TABLE stavka_racuna (
  id_stavka_racuna BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_racun BIGINT UNSIGNED NOT NULL,
  id_usluga BIGINT UNSIGNED NOT NULL,
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
  KEY idx_stavka_racuna_racun_id (id_racun),
  KEY idx_stavka_racuna_usluga_id (id_usluga),
  CONSTRAINT fk_stavka_racuna_racun
    FOREIGN KEY (id_racun) REFERENCES racun (id_racun)
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
  KEY idx_uplata_racun_id (id_racun),
  KEY idx_uplata_nacin_placanja_id (id_nacin_placanja),
  KEY idx_uplata_placeno_u (placeno_u),
  CONSTRAINT fk_uplata_racun
    FOREIGN KEY (id_racun) REFERENCES racun (id_racun)
      ON DELETE RESTRICT,
  CONSTRAINT fk_uplata_nacin_placanja
    FOREIGN KEY (id_nacin_placanja) REFERENCES nacin_placanja (id_nacin_placanja)
    ON DELETE RESTRICT
);

-- =========================================================
-- POVEZANOST TABLICA
-- =========================================================
-- pacijent je povezan s: uputnica, termin_pacijenta, pregled, nalaz, terapija, racun
-- odjel je povezan s: ordinacija, zaposlenik, usluga, termin_pacijenta
-- ordinacija je povezan s: zaposlenik, raspored_djelatnika, termin_pacijenta
-- specijalizacija je povezan s: zaposlenik
-- zaposlenik je povezan s: raspored_djelatnika, termin_pacijenta, pregled, nalaz, terapija
-- sifarnik_usluga je povezan sa: usluga
-- usluga je povezan s: cijena_usluge, pregled_usluga, stavka_racuna
-- uputnica je povezan s: termin_pacijenta
-- sifarnik_statusa_termina je povezan s: termin_pacijenta
-- termin_pacijenta je povezan s: pregled
-- status_pregleda je povezan s: pregled
-- pregled je povezan s: nalaz, terapija, racun, pregled_usluga, pregled_dijagnoza, privitak_pregleda
-- dijagnoza je povezan s: pregled_dijagnoza
-- tip_nalaza je povezan s: nalaz
-- status_nalaza je povezan s: nalaz
-- nalaz je povezan s: laboratorijski_rezultat, terapija
-- laboratorijski_parametar je povezan s: laboratorijski_rezultat
-- terapija je povezan s: preporuceni_lijek
-- privitak_pregleda je povezan s: pregled
-- nacin_placanja je povezan s: uplata
-- status_racuna je povezan s: racun
-- racun je povezan s: stavka_racuna, uplata
