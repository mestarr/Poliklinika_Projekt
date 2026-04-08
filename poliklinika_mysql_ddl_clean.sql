DROP DATABASE IF EXISTS poliklinika;
CREATE DATABASE poliklinika;

USE poliklinika;


-- Tablica: patient -> osnovni podaci o pacijentu
CREATE TABLE patient (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator pacijenta (PK)
  oib CHAR(11) NOT NULL, -- OIB pacijenta
  mbo VARCHAR(30) NOT NULL , -- MBO osiguranika
  first_name VARCHAR(100) NOT NULL, -- Ime pacijenta
  last_name VARCHAR(100) NOT NULL, -- Prezime pacijenta
  gender CHAR(1) NOT NULL DEFAULT 'm', -- Spol pacijenta (m/f/o)
  date_of_birth DATE NOT NULL, -- Datum rodenja pacijenta
  phone VARCHAR(50) NOT NULL , -- Kontakt telefon pacijenta
  email VARCHAR(100) NOT NULL, -- Kontakt e-mail pacijenta
  address VARCHAR(255) NOT NULL, -- Adresa pacijenta
  city VARCHAR(100) NOT NULL , -- Grad pacijenta
  note VARCHAR(1000) NOT NULL DEFAULT '-', -- Napomena o pacijentu
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_patient_oib (oib),
  INDEX idx_patient_oib (oib),
  UNIQUE KEY uq_patient_mbo (mbo),
  INDEX idx_patient_mbo (mbo),
  CONSTRAINT chk_patient_gender CHECK (gender IN ('m', 'f', 'o'))
);

-- Tablica: department -> organizacijske jedinice poliklinike
CREATE TABLE department (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator odjela (PK)
  code VARCHAR(50) NOT NULL, -- Sifra odjela
  name VARCHAR(200) NOT NULL, -- Naziv odjela
  description VARCHAR(1000) NOT NULL DEFAULT '-', -- Opis odjela
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_department_code (code),
  KEY idx_department_code (code)
);

-- Tablica: office -> ordinacije/kabineti unutar odjela
CREATE TABLE office (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator ordinacije (PK)
  department_id BIGINT UNSIGNED NOT NULL, -- Odjel kojem ordinacija pripada (FK -> department.id)
  code VARCHAR(50) NOT NULL, -- Sifra ordinacije
  name VARCHAR(200) NOT NULL, -- Naziv ordinacije
  description VARCHAR(1000) NOT NULL DEFAULT '-', -- Opis ordinacije
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_office_code (code),
  KEY idx_office_code (code),
  KEY idx_office_department_id (department_id),
  CONSTRAINT fk_office_department
    FOREIGN KEY (department_id) REFERENCES department (id)
     ON DELETE RESTRICT
) ;

-- Tablica: specialization -> sifrarnik specijalizacija
CREATE TABLE specialization (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator specijalizacije (PK)
  code VARCHAR(50) NOT NULL, -- Sifra specijalizacije
  name VARCHAR(150) NOT NULL, -- Naziv specijalizacije
  description VARCHAR(1000) NOT NULL DEFAULT '-', -- Opis specijalizacije
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_specialization_code (code),
  KEY idx_specialization_code (code)
);

-- Tablica: employee -> zaposlenici poliklinike
CREATE TABLE employee (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator zaposlenika (PK)
  employee_code VARCHAR(50) NOT NULL, -- Interna sifra zaposlenika
  first_name VARCHAR(100) NOT NULL, -- Ime zaposlenika
  last_name VARCHAR(100) NOT NULL, -- Prezime zaposlenika
  email VARCHAR(100) NOT NULL DEFAULT '-', -- E-mail zaposlenika
  phone VARCHAR(50) NOT NULL DEFAULT '-', -- Telefon zaposlenika
  title VARCHAR(100) NOT NULL DEFAULT 'liječnik', -- Titula/zvanje zaposlenika
  specialization_id BIGINT UNSIGNED NOT NULL, -- Specijalizacija zaposlenika (FK -> specialization.id)
  department_id BIGINT UNSIGNED NOT NULL, -- Odjel zaposlenika (FK -> department.id)
  office_id BIGINT UNSIGNED NOT NULL, -- Ordinacija zaposlenika (FK -> office.id)
  employment_date DATE NOT NULL, -- Datum zaposlenja
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_employee_code (employee_code),
  KEY idx_employee_specialization_id (specialization_id),
  KEY idx_employee_department_id (department_id),
  KEY idx_employee_office_id (office_id),
  CONSTRAINT fk_employee_specialization
    FOREIGN KEY (specialization_id) REFERENCES specialization (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_employee_department
    FOREIGN KEY (department_id) REFERENCES department (id)
    ON  DELETE RESTRICT,
  CONSTRAINT fk_employee_office
    FOREIGN KEY (office_id) REFERENCES office (id)
    ON  DELETE RESTRICT
);


-- Tablica: service_category -> kategorije usluga
CREATE TABLE service_category (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator kategorije (PK)
  code VARCHAR(50) NOT NULL, -- Sifra kategorije usluge
  name VARCHAR(100) NOT NULL, -- Naziv kategorije usluge
  category_id BIGINT UNSIGNED NULL DEFAULT NULL, -- Nadredena kategorija (self FK)
  description VARCHAR(500) NOT NULL DEFAULT '-', -- Opis kategorije usluge
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_service_category_code (code),
  KEY idx_service_category_code (code),
  CONSTRAINT fk_service_category_parent
    FOREIGN KEY (category_id) REFERENCES service_category (id)
    ON DELETE CASCADE
);

-- Tablica: service -> popis usluga
CREATE TABLE service (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator usluge (PK)
  code VARCHAR(50) NOT NULL, -- Sifra usluge
  name VARCHAR(200) NOT NULL, -- Naziv usluge
  category_id BIGINT UNSIGNED NOT NULL, -- Kategorija usluge (FK -> service_category.id)
  department_id BIGINT UNSIGNED NOT NULL, -- Odjel koji pruza uslugu (FK -> department.id)
  description VARCHAR(2000) NOT NULL DEFAULT '-', -- Opis usluge
  duration_min INT NOT NULL DEFAULT 0, -- Trajanje usluge u minutama
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_service_code (code),
  KEY idx_service_code (code),
  KEY idx_service_category_id (category_id),
  KEY idx_service_department_id (department_id),
  CONSTRAINT fk_service_category
    FOREIGN KEY (category_id) REFERENCES service_category (id)
     ON DELETE RESTRICT,
  CONSTRAINT fk_service_department
    FOREIGN KEY (department_id) REFERENCES department (id)
    ON DELETE RESTRICT
);

-- Tablica: service_price -> cjenik usluga kroz vrijeme
CREATE TABLE service_price (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator zapisa cjenika (PK)
  service_id BIGINT UNSIGNED NOT NULL, -- Usluga na koju se cijena odnosi (FK -> service.id)
  date_from DATE NOT NULL, -- Datum od kada cijena vrijedi
  date_to DATE NOT NULL DEFAULT '9999-12-31', -- Datum do kada cijena vrijedi
  price DECIMAL(18,2) NOT NULL, -- Iznos cijene
  currency CHAR(3) NOT NULL DEFAULT 'EUR', -- Valuta cijene (npr. EUR)
  tax_rate DECIMAL(5,2) NOT NULL DEFAULT 0, -- Porezna stopa 
  note VARCHAR(500) NOT NULL DEFAULT '-', -- Napomena uz cijenu
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_service_price_service_id (service_id),
  KEY idx_service_price_date_from (date_from),
  CONSTRAINT fk_service_price_service
    FOREIGN KEY (service_id) REFERENCES service (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Tablica: referral -> uputnice/zahtjevi
CREATE TABLE referral (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator uputnice (PK)
  patient_id BIGINT UNSIGNED NOT NULL, -- Pacijent na kojeg se uputnica odnosi (FK -> patient.id)
  referral_number VARCHAR(100) NOT NULL, -- Broj uputnice
  referral_date DATE NOT NULL, -- Datum uputnice
  description VARCHAR(1000) NOT NULL DEFAULT '-', -- Opis razloga uputnice
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_referral_patient_id (patient_id),
  CONSTRAINT fk_referral_patient
    FOREIGN KEY (patient_id) REFERENCES patient (id)
    ON DELETE CASCADE
) ;


-- Tablica: appointment_status -> statusi termina
CREATE TABLE appointment_status (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator statusa termina (PK)
  code VARCHAR(20) NOT NULL, -- Kod statusa termina
  name VARCHAR(100) NOT NULL, -- Naziv statusa termina
  description VARCHAR(500) NOT NULL DEFAULT '-', -- Opis statusa termina
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_appointment_status_code (code),
  KEY idx_appointment_status_code (code)
);

-- Tablica: employee_schedule -> raspored djelatnika
CREATE TABLE employee_schedule (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator rasporeda (PK)
  employee_id BIGINT UNSIGNED NOT NULL, -- Djelatnik u rasporedu (FK -> employee.id)
  schedule_date DATE NOT NULL, -- Datum rasporeda
  time_from TIME NOT NULL, -- Vrijeme pocetka dostupnosti
  time_to TIME NOT NULL, -- Vrijeme kraja dostupnosti
  note VARCHAR(500) NOT NULL DEFAULT '-', -- Napomena uz raspored
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_employee_schedule_employee_id (employee_id),
  KEY idx_employee_schedule_date (schedule_date),
  CONSTRAINT chk_employee_schedule_time_range CHECK (time_from <= time_to),
  CONSTRAINT fk_employee_schedule_employee
    FOREIGN KEY (employee_id) REFERENCES employee (id)
    ON DELETE RESTRICT
) ;

-- Tablica: appointment -> termini pacijenata
CREATE TABLE appointment (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator termina (PK)
  patient_id BIGINT UNSIGNED NOT NULL, -- Pacijent termina (FK -> patient.id)
  referral_id BIGINT UNSIGNED NULL, -- Uputnica povezana s terminom (FK -> referral.id)
  employee_id BIGINT UNSIGNED NOT NULL, -- Djelatnik koji vodi termin (FK -> employee.id)
  appointment_status_id BIGINT UNSIGNED NOT NULL, -- Status termina (FK -> appointment_status.id)
  appointment_datetime DATETIME NOT NULL, -- Datum i vrijeme termina
  estimated_duration_min INT NOT NULL DEFAULT 0, -- Procijenjeno trajanje termina
  arrival_reason VARCHAR(1000) NOT NULL DEFAULT '-', -- Razlog dolaska
  cancellation_reason VARCHAR(1000) NOT NULL DEFAULT '-', -- Razlog otkazivanja
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_appointment_patient_id (patient_id),
  KEY idx_appointment_referral_id (referral_id),
  KEY idx_appointment_employee_id (employee_id),
  KEY idx_appointment_status_id (appointment_status_id),
  KEY idx_appointment_datetime (appointment_datetime),
  CONSTRAINT fk_appointment_patient
    FOREIGN KEY (patient_id) REFERENCES patient (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_appointment_referral
    FOREIGN KEY (referral_id) REFERENCES referral (id)
     ON DELETE RESTRICT,
  CONSTRAINT fk_appointment_employee
    FOREIGN KEY (employee_id) REFERENCES employee (id)
     ON DELETE RESTRICT,
  CONSTRAINT fk_appointment_status
    FOREIGN KEY (appointment_status_id) REFERENCES appointment_status (id)
     ON DELETE RESTRICT
) ;



-- Tablica: examination_status -> statusi pregleda
CREATE TABLE examination_status (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator statusa pregleda (PK)
  code VARCHAR(20) NOT NULL, -- Kod statusa pregleda
  name VARCHAR(100) NOT NULL, -- Naziv statusa pregleda
  description VARCHAR(500) NOT NULL DEFAULT '-', -- Opis statusa pregleda
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_examination_status_code (code)
);

-- Tablica: examination -> provedeni pregledi
-- napomena: iako patient_id i employee_di možemo saznati iz appointment_id-a, ovo je jedan od primjera gdje bi možda bilo korisno zadržati vrijednosti zbog kompleksnih JOIN-ova u query-ima koji kasnije mogu biti skupi  
CREATE TABLE examination (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator pregleda (PK)
  appointment_id BIGINT UNSIGNED NOT NULL, -- Termin iz kojeg je pregled nastao (FK -> appointment.id)
  patient_id BIGINT UNSIGNED NOT NULL, -- Pacijent pregleda (FK -> patient.id)
  employee_id BIGINT UNSIGNED NOT NULL, -- Djelatnik koji je obavio pregled (FK -> employee.id)
  examination_status_id BIGINT UNSIGNED NOT NULL, -- Status pregleda (FK -> examination_status.id)
  examination_datetime DATETIME NOT NULL, -- Datum i vrijeme pregleda
  anamnesis TEXT NOT NULL, -- Anamneza
  conclusion TEXT NOT NULL, -- Zakljucak pregleda
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_examination_appointment_id (appointment_id),
  KEY idx_examination_patient_id (patient_id),
  KEY idx_examination_employee_id (employee_id),
  KEY idx_examination_status_id (examination_status_id),
  KEY idx_examination_datetime (examination_datetime),
  CONSTRAINT fk_examination_appointment
    FOREIGN KEY (appointment_id) REFERENCES appointment (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_examination_patient
    FOREIGN KEY (patient_id) REFERENCES patient (id)
     ON DELETE RESTRICT,
  CONSTRAINT fk_examination_employee
    FOREIGN KEY (employee_id) REFERENCES employee (id)
     ON DELETE RESTRICT,
  CONSTRAINT fk_examination_status
    FOREIGN KEY (examination_status_id) REFERENCES examination_status (id)
     ON DELETE RESTRICT
);

-- Tablica: examination_service -> stvarno obavljene usluge na pregledu
CREATE TABLE examination_service (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator zapisa (PK)
  examination_id BIGINT UNSIGNED NOT NULL, -- Pregled na kojem je usluga obavljena (FK -> examination.id)
  service_id BIGINT UNSIGNED NOT NULL, -- Obavljena usluga (FK -> service.id)
  quantity DECIMAL(18,2) NOT NULL DEFAULT 1, -- Kolicina obavljene usluge
  price DECIMAL(18,2) NOT NULL, -- Cijena usluge u trenutku obrade
  discount DECIMAL(5,2) NOT NULL DEFAULT 0, -- Popust 
  tax_rate DECIMAL(5,2) NOT NULL DEFAULT 0, -- Porezna stopa
  total_amount DECIMAL(18,2) NOT NULL DEFAULT 0, -- Ukupan iznos stavke
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_examination_service_examination_id (examination_id),
  KEY idx_examination_service_service_id (service_id),
  CONSTRAINT fk_examination_service_examination
    FOREIGN KEY (examination_id) REFERENCES examination (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_examination_service_service
    FOREIGN KEY (service_id) REFERENCES service (id)
     ON DELETE RESTRICT
);

-- Tablica: diagnosis -> sifrarnik dijagnoza
CREATE TABLE diagnosis (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator dijagnoze (PK)
  code VARCHAR(20) NOT NULL, -- Sifra dijagnoze
  name VARCHAR(500) NOT NULL, -- Naziv dijagnoze
  description VARCHAR(1000) NOT NULL DEFAULT '-', -- Opis dijagnoze
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_diagnosis_code (code)
) ;

-- Tablica: examination_diagnosis -> povezivanje pregleda i dijagnoza
CREATE TABLE examination_diagnosis (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator zapisa veze (PK)
  examination_id BIGINT UNSIGNED NOT NULL, -- Pregled (FK -> examination.id)
  diagnosis_id BIGINT UNSIGNED NOT NULL, -- Dijagnoza (FK -> diagnosis.id)
  primary_flag BIT(1) NOT NULL DEFAULT b'0', -- Oznaka primarne dijagnoze (1/0)
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_examination_diagnosis_examination_id (examination_id),
  KEY idx_examination_diagnosis_diagnosis_id (diagnosis_id),
  CONSTRAINT fk_examination_diagnosis_examination
    FOREIGN KEY (examination_id) REFERENCES examination (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_examination_diagnosis_diagnosis
    FOREIGN KEY (diagnosis_id) REFERENCES diagnosis (id)
    ON DELETE RESTRICT
) ;


-- Tablica: finding_type -> tipovi nalaza
CREATE TABLE finding_type (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator tipa nalaza (PK)
  code VARCHAR(20) NOT NULL, -- Kod tipa nalaza
  name VARCHAR(200) NOT NULL, -- Naziv tipa nalaza
  description VARCHAR(1000) NOT NULL DEFAULT '-', -- Opis tipa nalaza
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_finding_type_code (code)
);

-- Tablica: finding_status -> statusi nalaza
CREATE TABLE finding_status (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator statusa nalaza (PK)
  code VARCHAR(20) NOT NULL, -- Kod statusa nalaza
  name VARCHAR(100) NOT NULL, -- Naziv statusa nalaza
  description VARCHAR(500) NOT NULL DEFAULT '-', -- Opis statusa nalaza
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_finding_status_code (code)
);

-- Tablica: finding -> izdani nalazi
CREATE TABLE finding (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator nalaza (PK)
  patient_id BIGINT UNSIGNED NOT NULL, -- Pacijent nalaza (FK -> patient.id)
  employee_id BIGINT UNSIGNED NOT NULL, -- Djelatnik koji izdaje nalaz (FK -> employee.id)
  finding_type_id BIGINT UNSIGNED NOT NULL, -- Tip nalaza (FK -> finding_type.id)
  finding_status_id BIGINT UNSIGNED NOT NULL, -- Status nalaza (FK -> finding_status.id)
  examination_id BIGINT UNSIGNED NULL, -- Povezani pregled (FK -> examination.id)
  issued_at DATETIME NOT NULL, -- Vrijeme izdavanja nalaza
  summary VARCHAR(1000) NOT NULL DEFAULT '-', -- Sazetak nalaza
  note TEXT NOT NULL DEFAULT '-', -- Glavni tekst nalaza
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_finding_patient_id (patient_id),
  KEY idx_finding_type_id (finding_type_id),
  KEY idx_finding_status_id (finding_status_id),
  KEY idx_finding_examination_id (examination_id),
  KEY idx_finding_issued_at (issued_at),
  CONSTRAINT fk_finding_patient
    FOREIGN KEY (patient_id) REFERENCES patient (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_finding_type
    FOREIGN KEY (finding_type_id) REFERENCES finding_type (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_finding_status
    FOREIGN KEY (finding_status_id) REFERENCES finding_status (id)
     ON DELETE RESTRICT,
  CONSTRAINT fk_finding_examination
    FOREIGN KEY (examination_id) REFERENCES examination (id)
    ON DELETE RESTRICT
);

-- Tablica: lab_parameter -> laboratorijski parametri
CREATE TABLE lab_parameter (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator parametra (PK)
  code VARCHAR(20) NOT NULL, -- Sifra laboratorijskog parametra
  name VARCHAR(200) NOT NULL, -- Naziv laboratorijskog parametra
  description VARCHAR(1000) NOT NULL DEFAULT '-', -- Opis parametra
  unit VARCHAR(50) NOT NULL DEFAULT '-', -- Mjerna jedinica parametra
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_lab_parameter_code (code),
  KEY idx_lab_parameter_code (code)
);

-- Tablica: lab_result -> laboratorijski rezultati
CREATE TABLE lab_result (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator rezultata (PK)
  finding_id BIGINT UNSIGNED NOT NULL, -- Nalaz kojem rezultat pripada (FK -> finding.id)
  lab_parameter_id BIGINT UNSIGNED NOT NULL, -- Parametar za koji je rezultat izmjeren (FK -> lab_parameter.id)
  sampled_at DATETIME NULL, -- Vrijeme uzimanja uzorka
  measured_at DATETIME NULL, -- Vrijeme mjerenja
  result_text VARCHAR(1000) NOT NULL DEFAULT '-', -- Tekstualni rezultat
  result_num DECIMAL(18,6) NOT NULL DEFAULT 0, -- Numericka vrijednost rezultata
  reference_min DECIMAL(18,6) NOT NULL DEFAULT 0, -- Donja referentna granica
  reference_max DECIMAL(18,6) NOT NULL DEFAULT 0, -- Gornja referentna granica
  abnormal_flag SMALLINT NOT NULL DEFAULT 0, -- Oznaka odstupanja (npr. 0 normalno / 1 odstupanje)
  abnormal_description VARCHAR(255) NOT NULL DEFAULT '-', -- Opis odstupanja
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_lab_result_finding_id (finding_id),
  KEY idx_lab_result_lab_parameter_id (lab_parameter_id),
  CONSTRAINT fk_lab_result_finding
    FOREIGN KEY (finding_id) REFERENCES finding (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_lab_result_lab_parameter
    FOREIGN KEY (lab_parameter_id) REFERENCES lab_parameter (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Tablica: therapy -> terapija
CREATE TABLE therapy (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator preporuke (PK)
  examination_id BIGINT UNSIGNED NOT NULL, -- Pregled za koji je preporuka izdana (FK -> examination.id)
  patient_id BIGINT UNSIGNED NOT NULL, -- Pacijent preporuke (FK -> patient.id)
  employee_id BIGINT UNSIGNED NOT NULL, -- Djelatnik koji daje preporuku (FK -> employee.id)
  finding_id BIGINT UNSIGNED NULL, -- Nalaz povezan s preporukom (FK -> finding.id)
  recommended_at DATETIME NOT NULL, -- Vrijeme izdavanja preporuke
  recommendation_text TEXT NOT NULL, -- Tekst preporuke
  follow_up_required_flag BIT(1) NOT NULL DEFAULT b'0', -- Treba li kontrola (1/0)
  follow_up_date DATE NULL, -- Datum preporucene kontrole
  note VARCHAR(1000) NOT NULL DEFAULT '-', -- Napomena uz preporuku
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_therapy_examination_id (examination_id),
  KEY idx_therapy_patient_id (patient_id),
  KEY idx_therapy_employee_id (employee_id),
  KEY idx_therapy_finding_id (finding_id),
  CONSTRAINT fk_therapy_examination
    FOREIGN KEY (examination_id) REFERENCES examination (id)
    ON  DELETE RESTRICT,
  CONSTRAINT fk_therapy_patient
    FOREIGN KEY (patient_id) REFERENCES patient (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_therapy_employee
    FOREIGN KEY (employee_id) REFERENCES employee (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_therapy_finding
    FOREIGN KEY (finding_id) REFERENCES finding (id)
    ON DELETE RESTRICT
) ;

-- Tablica: recommended_medication -> preporuceni lijekovi
CREATE TABLE recommended_medication (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator zapisa lijeka (PK)
  therapy_id BIGINT UNSIGNED NOT NULL, -- Terapija kojoj lijek pripada (FK -> therapy.id)
  medication_name VARCHAR(200) NOT NULL, -- Naziv lijeka/preparata
  dosage VARCHAR(100) NOT NULL DEFAULT '-', -- Doziranje
  instruction VARCHAR(1000) NOT NULL DEFAULT '-', -- Uputa primjene
  duration_days INT NOT NULL DEFAULT 0, -- Trajanje primjene u danima
  note VARCHAR(500) NOT NULL DEFAULT '-', -- Napomena uz lijek
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_recommended_medication_therapy_id (therapy_id),
  CONSTRAINT fk_recommended_medication_therapy
    FOREIGN KEY (therapy_id) REFERENCES therapy (id)
    ON DELETE RESTRICT
) ;

-- Tablica: examination_attachment -> privitci vezani uz pregled
CREATE TABLE examination_attachment (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator privitka (PK)
  examination_id BIGINT UNSIGNED NOT NULL, -- Pregled kojem privitak pripada (FK -> examination.id)
  attachment_type VARCHAR(30) NOT NULL DEFAULT 'PDF', -- Vrsta privitka (report/image/consent/other)
  file_name VARCHAR(255) NOT NULL, -- Naziv datoteke
  mime_type VARCHAR(100) NOT NULL DEFAULT '-', -- MIME tip datoteke
  size_bytes BIGINT NOT NULL DEFAULT 0, -- Velicina datoteke u bajtovima
  file_path VARCHAR(500) NOT NULL, -- Putanja datoteke
  note VARCHAR(500) NOT NULL DEFAULT '-', -- Napomena uz privitak
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_examination_attachment_examination_id (examination_id),
  CONSTRAINT fk_examination_attachment_examination
    FOREIGN KEY (examination_id) REFERENCES examination (id)
    ON DELETE CASCADE
);

-- Tablica: payment_method -> nacini placanja
CREATE TABLE payment_method (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator nacina placanja (PK)
  code VARCHAR(50) NOT NULL , -- kod nacina placanja
  name VARCHAR(100) NOT NULL, -- Naziv nacina placanja
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_payment_method_code (code),
  KEY idx_payment_method_code (code)
);

-- Tablica: invoice_status -> statusi racuna
CREATE TABLE invoice_status (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator statusa racuna (PK)
  code VARCHAR(20) NOT NULL, -- Kod statusa racuna
  name VARCHAR(100) NOT NULL, -- Naziv statusa racuna
  description VARCHAR(500) NOT NULL DEFAULT '-', -- Opis statusa racuna
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_invoice_status_code (code)
);

-- Tablica: invoice -> zaglavlja racuna
CREATE TABLE invoice (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator racuna (PK)
  invoice_number VARCHAR(50) NOT NULL, -- Broj racuna
  patient_id BIGINT UNSIGNED NOT NULL, -- Pacijent/platitelj racuna (FK -> patient.id)
  status_id BIGINT UNSIGNED NOT NULL, -- Status racuna (FK -> invoice_status.id)
  examination_id BIGINT UNSIGNED NULL, -- Povezani pregled (FK -> examination.id)
  issue_date DATE NOT NULL, -- Datum izdavanja racuna
  due_date DATE NULL, -- Datum dospijeca racuna
  currency CHAR(3) NOT NULL DEFAULT 'EUR', -- Valuta racuna
  total_without_tax DECIMAL(18,2) NOT NULL DEFAULT 0, -- Ukupno bez poreza
  total_tax DECIMAL(18,2) NOT NULL DEFAULT 0, -- Ukupan porez
  total_discount DECIMAL(18,2) NOT NULL DEFAULT 0, -- Ukupan popust
  total_to_pay DECIMAL(18,2) NOT NULL DEFAULT 0, -- Konacan iznos za placanje
  note VARCHAR(1000) NOT NULL DEFAULT '-', -- Napomena uz racun
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  UNIQUE KEY uq_invoice_number (invoice_number),
  KEY idx_invoice_patient_id (patient_id),
  KEY idx_invoice_status_id (status_id),
  KEY idx_invoice_examination_id (examination_id),
  CONSTRAINT fk_invoice_patient
    FOREIGN KEY (patient_id) REFERENCES patient (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_invoice_status
    FOREIGN KEY (status_id) REFERENCES invoice_status (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_invoice_examination
    FOREIGN KEY (examination_id) REFERENCES examination (id)
    ON DELETE RESTRICT
);

-- Tablica: invoice_item -> stavke racuna
CREATE TABLE invoice_item (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator stavke racuna (PK)
  invoice_id BIGINT UNSIGNED NOT NULL, -- Racun kojem stavka pripada (FK -> invoice.id)
  service_id BIGINT UNSIGNED NOT NULL, -- Usluga koja se naplacuje (FK -> service.id)
  description VARCHAR(500) NOT NULL DEFAULT '-', -- Opis stavke
  quantity DECIMAL(18,2) NOT NULL DEFAULT 1, -- Kolicina stavke
  unit_price DECIMAL(18,2) NOT NULL DEFAULT 0, -- Jedinicna cijena stavke
  discount_rate DECIMAL(5,2) NOT NULL DEFAULT 0, -- Popust stavke (%)
  tax_rate DECIMAL(5,2) NOT NULL DEFAULT 0, -- Porezna stopa stavke (%)
  amount_without_tax DECIMAL(18,2) NOT NULL DEFAULT 0, -- Iznos stavke bez poreza
  amount_tax DECIMAL(18,2) NOT NULL DEFAULT 0, -- Iznos poreza stavke
  amount_total DECIMAL(18,2) NOT NULL DEFAULT 0, -- Ukupan iznos stavke
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_invoice_item_invoice_id (invoice_id),
  KEY idx_invoice_item_service_id (service_id),
  CONSTRAINT fk_invoice_item_invoice
    FOREIGN KEY (invoice_id) REFERENCES invoice (id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_invoice_item_service
    FOREIGN KEY (service_id) REFERENCES service (id)
    ON DELETE RESTRICT
);

-- Tablica: payment -> uplate po racunima
CREATE TABLE payment (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- Jedinstveni identifikator uplate (PK)
  invoice_id BIGINT UNSIGNED NOT NULL, -- Racun koji se placa (FK -> invoice.id)
  payment_method_id BIGINT UNSIGNED NOT NULL, -- Nacin placanja (FK -> payment_method.id)
  paid_at DATETIME NOT NULL, -- Datum i vrijeme uplate
  amount DECIMAL(18,2) NOT NULL DEFAULT 0, -- Iznos uplate
  transaction_reference VARCHAR(100) NOT NULL DEFAULT '-', -- Referenca transakcije
  note VARCHAR(1000) NOT NULL DEFAULT '-', -- Napomena uz uplatu
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Vrijeme kreiranja zapisa
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Vrijeme zadnje izmjene zapisa
  PRIMARY KEY (id),
  KEY idx_payment_invoice_id (invoice_id),
  KEY idx_payment_payment_method_id (payment_method_id),
  KEY idx_payment_paid_at (paid_at),
  CONSTRAINT fk_payment_invoice
    FOREIGN KEY (invoice_id) REFERENCES invoice (id)
      ON DELETE RESTRICT,
  CONSTRAINT fk_payment_payment_method
    FOREIGN KEY (payment_method_id) REFERENCES payment_method (id)
    ON DELETE RESTRICT
);

-- =========================================================
-- POVEZANOST TABLICA 
-- =========================================================
-- patient je povezan s: referral, appointment, examination, finding, therapy_recommendation, invoice
-- department je povezan s: office, employee, service, appointment
-- office je povezan s: employee, employee_schedule, appointment
-- specialization je povezan s: employee
-- employee je povezan s: employee_schedule, appointment, examination, finding, therapy_recommendation
-- service_category je povezan sa: service
-- service je povezan s: service_price, examination_service, invoice_item
-- referral je povezan s: appointment
-- appointment_status je povezan s: appointment
-- appointment je povezan s: examination
-- examination_status je povezan s: examination
-- examination je povezan s: finding, therapy_recommendation, invoice, examination_service, examination_diagnosis, examination_attachment
-- diagnosis je povezan s: examination_diagnosis
-- finding_type je povezan s: finding
-- finding_status je povezan s: finding
-- finding je povezan s: lab_result, therapy_recommendation
-- lab_parameter je povezan s: lab_result
-- therapy_recommendation je povezan s: recommended_medication
-- examination_attachment je povezan s: examination
-- payment_method je povezan s: payment
-- invoice_status je povezan s: invoice
-- invoice je povezan s: invoice_item, payment
