# Informacijski sustav poliklinike – opis modela baze podataka

## 1. O čemu se radi

Ova baza podataka predstavlja model **informacijskog sustava za upravljanje radom poliklinike**. Njezin cilj je objediniti najvažnije poslovne i medicinske procese na jednom mjestu: evidenciju pacijenata, organizaciju odjela i ordinacija, zaposlenike, naručivanje termina, provedbu pregleda, izdavanje nalaza i terapija te obračun i naplatu usluga. 

Model je organiziran tako da prati stvarni tijek rada u poliklinici: **pacijent dolazi u sustav, dobiva termin, obavlja pregled, po potrebi dobiva nalaz i terapiju, a zatim se usluga može obračunati kroz račun i uplatu**. Struktura se temelji na SQL tablicama i njihovim međusobnim vezama putem primarnih i stranih ključeva. 

Temeljne cjeline modela jasno su vidljive iz tablica `patient`, `department`, `office`, `employee`, `appointment`, `examination`, `finding`, `therapy`, `invoice` i `payment`, kao i iz pripadajućih šifrarnika i poveznica. 

## 2. Glavna svrha sustava

Sustav omogućuje:

- vođenje osnovnih podataka o pacijentima
- organizaciju odjela, ordinacija i zaposlenika
- raspored rada djelatnika i naručivanje pacijenata
- evidenciju obavljenih pregleda i dijagnoza
- izdavanje nalaza, laboratorijskih rezultata i terapije
- definiranje usluga i njihovih cijena
- izdavanje računa, stavki računa i evidentiranje uplata.

Drugim riječima, baza pokriva i **medicinski dio poslovanja** i **administrativno-financijski dio poslovanja** poliklinike. To se vidi iz odvojenih skupina tablica za pacijente i preglede, za nalaze i terapiju te za račune i plaćanja. 

## 3. Glavne cjeline baze

## 3.1. Pacijenti

Tablica `patient` sadrži osnovne podatke o pacijentu: OIB, MBO, ime, prezime, spol, datum rođenja, kontakt podatke i adresu. OIB i MBO su jedinstveni, što znači da se isti pacijent ne može duplicirati kroz te identifikatore. Tablica je temelj velikog dijela sustava jer se na nju vežu uputnice, termini, pregledi, nalazi, terapije i računi. 

## 3.2. Organizacijska struktura

Tablice `department` i `office` opisuju unutarnju organizaciju poliklinike. `department` predstavlja odjele ili organizacijske jedinice, a `office` pojedine ordinacije ili kabinete unutar tih odjela. Na taj se način sustav može logično podijeliti po specijalnostima i radnim prostorima. 

## 3.3. Zaposlenici i specijalizacije

Tablica `specialization` služi kao šifrarnik specijalizacija, dok tablica `employee` sadrži podatke o zaposlenicima. Svaki zaposlenik pripada određenoj specijalizaciji, odjelu i ordinaciji. Time se može pratiti tko radi u kojem dijelu poliklinike i koja je njegova stručna uloga u sustavu. Uz to, `employee_schedule` omogućuje vođenje rasporeda rada po datumima i vremenskim intervalima. 

## 3.4. Usluge i cjenik

Tablice `service_category`, `service` i `service_price` služe za definiranje usluga koje poliklinika pruža. Usluge su grupirane po kategorijama, povezane su s odjelima i imaju trajanje. Cijene usluga vode se kroz posebnu tablicu `service_price`, što omogućuje praćenje promjena cijena kroz vrijeme. 

## 3.5. Uputnice i termini

Tablica `referral` služi za evidenciju uputnica, a `appointment` za naručivanje pacijenata na termin. Termin je povezan s pacijentom, eventualnom uputnicom, zaposlenikom i statusom termina. Time se može pratiti kada je pacijent naručen, kod kojeg djelatnika i u kojem je statusu termin. Za statuse termina koristi se poseban šifrarnik `appointment_status`.

## 3.6. Pregledi i dijagnoze

Nakon termina slijedi pregled, koji se vodi u tablici `examination`. Pregled je povezan s terminom, pacijentom, djelatnikom i statusom pregleda. U njemu se čuvaju anamneza i zaključak pregleda. 

Dijagnoze su organizirane kroz tablicu `diagnosis`, a budući da jedan pregled može imati više dijagnoza, koristi se povezna tablica `examination_diagnosis`. Na taj način model podržava odnos više-prema-više između pregleda i dijagnoza. Tablica `examination_service` dodatno omogućuje evidentiranje stvarno obavljenih usluga tijekom pregleda. 

## 3.7. Nalazi i laboratorijski rezultati

Tablica `finding` služi za izdane nalaze. Nalaz je povezan s pacijentom, djelatnikom, vrstom nalaza, statusom nalaza i po potrebi s pregledom. Za vrste i statuse nalaza koriste se tablice `finding_type` i `finding_status`. 

Ako je riječ o laboratorijskim nalazima, detalji rezultata vode se kroz `lab_parameter` i `lab_result`. Tako sustav može pratiti ne samo postojanje nalaza, nego i pojedinačne izmjerene laboratorijske vrijednosti, referentne granice i eventualna odstupanja. 

## 3.8. Terapija i preporučeni lijekovi

Tablica `therapy` služi za preporuke i terapiju nakon pregleda. Povezana je s pregledom, pacijentom, djelatnikom i po potrebi nalazom. U njoj se pohranjuju tekst preporuke, informacija treba li kontrola i datum eventualne kontrole. 

Ako terapija uključuje više lijekova ili pripravaka, oni se vode u tablici `recommended_medication`, gdje se za svaki lijek mogu navesti naziv, doziranje, upute i trajanje primjene. 

## 3.9. Privitci uz pregled

Tablica `examination_attachment` omogućuje pohranu metapodataka o privicima vezanim uz pregled, primjerice PDF dokumentima, slikama, izvješćima ili drugim datotekama. Time model podržava i dokumentacijsku stranu rada poliklinike. 

## 3.10. Računi i naplata

Financijski dio modela sastoji se od tablica `payment_method`, `invoice_status`, `invoice`, `invoice_item` i `payment`. 

- `invoice` predstavlja zaglavlje računa
- `invoice_item` sadrži pojedine stavke računa
- `payment` evidentira uplate po računima
- `payment_method` definira načine plaćanja
- `invoice_status` definira status računa.

Ova cjelina omogućuje da se nakon obavljenih usluga pacijentu izda račun, da se na račun dodaju stavke usluga te da se evidentira jedna ili više uplata. 

## 4. Osnovni tok podataka kroz sustav

Najjednostavniji način razumijevanja modela je promatrati tipičan tok rada:

1. U sustav se evidentira pacijent.
2. Pacijent može dobiti uputnicu.
3. Pacijentu se zakazuje termin kod određenog djelatnika.
4. Iz termina nastaje pregled.
5. Tijekom pregleda mogu se evidentirati dijagnoze i obavljene usluge.
6. Na temelju pregleda može se izdati nalaz.
7. Po potrebi se propisuje terapija i lijekovi.
8. Nakon pružene usluge može se izdati račun.
9. Račun se zatim može djelomično ili u cijelosti platiti.

Ovaj poslovni tok odgovara glavnim vezama između tablica `patient`, `referral`, `appointment`, `examination`, `finding`, `therapy`, `invoice` i `payment`. 

## 5. Najvažnije veze među tablicama

Najvažnije logičke veze mogu se sažeti ovako:

- jedan pacijent može imati više uputnica, termina, pregleda, nalaza, terapija i računa
- jedan odjel može imati više ordinacija, zaposlenika i usluga
- jedna ordinacija pripada jednom odjelu, ali u njoj može raditi više zaposlenika
- jedan zaposlenik može imati više termina, pregleda, nalaza i preporuka
- jedan termin pripada jednom pacijentu i jednom djelatniku, a može rezultirati jednim ili više pregleda, ovisno o poslovnim pravilima sustava
- jedan pregled može imati više dijagnoza i više obavljenih usluga
- jedan nalaz može imati više laboratorijskih rezultata
- jedna terapija može imati više preporučenih lijekova
- jedan račun može imati više stavki i više uplata.

Takve veze čine model dovoljno fleksibilnim za stvarni rad poliklinike, a istovremeno dovoljno strukturiranim za kasnije SQL upite, izvještavanje i nadogradnju sustava. 

## 6. Zaključak

Ovaj model baze podataka prikazuje **cjelovit informacijski sustav poliklinike** koji povezuje medicinsku evidenciju, organizaciju rada i financijsko poslovanje. Njegova najveća vrijednost je u tome što ne promatra samo jedan dio procesa, nego povezuje cijeli put pacijenta kroz ustanovu: od naručivanja i pregleda do nalaza, terapije i naplate. 

Zbog takve strukture baza je pogodna za izradu aplikacije koja bi podržavala svakodnevni rad poliklinike, olakšala pretragu podataka, smanjila administrativne pogreške i omogućila kvalitetnije praćenje zdravstvenih i poslovnih procesa. 
