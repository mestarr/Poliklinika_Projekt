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

Tablica `specialization` služi kao šifrarnik specijalizacija, dok tablica `employee` sadrži podatke o zaposlenicima. Svaki zaposlenik pripada određenoj specijalizaciji i jednoj ordinaciji; pripadajući odjel se dohvaća **preko ordinacije** (ordinacija → odjel), pa zaposlenik više ne nosi izravnu vezu na odjel. Time se izbjegla redundancija i mogućnost da odjel zaposlenika "razmigra" u odnosu na odjel ordinacije. Uz to, `employee_schedule` omogućuje vođenje rasporeda rada po datumima i vremenskim intervalima.

## 3.4. Usluge i cjenik

Tablice `service` i `service_price` služe za definiranje usluga koje poliklinika pruža. Svaka usluga pripada nekom odjelu i ima predviđeno trajanje. Cijene usluga vode se kroz posebnu tablicu `service_price`, što omogućuje praćenje promjena cijena kroz vrijeme. Ranija tablica `service_category` je uklonjena – hijerarhija usluga nije bila potrebna jer u praksi nema značajnih takvih grupiranja.

## 3.5. Uputnice i termini

Tablica `referral` služi za evidenciju uputnica, a `appointment` za naručivanje pacijenata na termin. Termin je povezan s pacijentom, eventualnom uputnicom, zaposlenikom, **konkretnom uslugom za koju se pacijent naručuje** i **ordinacijom u kojoj se termin održava** – time je termin samostalno informativan i neovisan o naknadnom dohvaćanju usluge/ordinacije preko zaposlenika. Status termina prati se stupcem `status` (vrijednosti `najavljen`, `odrzan`, `otkazan`, `nije_odrzan`) izravno na termin retku, bez zasebnog šifrarnika.

## 3.6. Pregledi i dijagnoze

Nakon termina slijedi pregled, koji se vodi u tablici `examination`. Pregled je povezan s terminom (preko kojeg se dohvaća pacijent) i sa zaposlenikom koji je pregled stvarno obavio – `id_zaposlenik` se u pregledu zadržava jer pregled može obaviti drugi liječnik od onoga planiranog u terminu (čime se čuva stvarno stanje pregleda). Pacijent se više ne duplicira na pregledu. Status pregleda prati se stupcem `status` (`u_tijeku`, `zavrsen`, `storniran`).

Dijagnoze su organizirane kroz tablicu `diagnosis`, a budući da jedan pregled može imati više dijagnoza, koristi se povezna tablica `examination_diagnosis`. Tablica `examination_service` ostaje **izvor istine za stvarno obavljene usluge** tijekom pregleda – iz nje proizlaze i kasnije stavke računa.

## 3.7. Nalazi i laboratorijski rezultati

Tablica `finding` služi za izdane nalaze. Nalaz je uvijek vezan na pacijenta i vrstu nalaza, a opcionalno na pregled (jer model podržava i nalaze koji nisu vezani uz pregled, npr. iz vanjskog laboratorija). Liječnik koji je nalaz izdao više se ne pohranjuje izravno u `finding` – dohvaća se preko pregleda kad pregled postoji. Status nalaza prati se stupcem `status` (`u_obradi`, `izdan`, `ponisten`).

Ako je riječ o laboratorijskim nalazima, detalji rezultata vode se kroz `lab_parameter` i `lab_result`.

## 3.8. Terapija i preporučeni lijekovi

Tablica `therapy` služi za preporuke i terapiju nakon pregleda. Povezana je sa svojim pregledom (obavezno) i po potrebi s nalazom. Pacijent i liječnik se više ne dupliciraju u `therapy` – oboje se dohvaća preko pripadajućeg pregleda.

Ako terapija uključuje više lijekova ili pripravaka, oni se vode u tablici `recommended_medication`.

## 3.9. Privitci

Tablica `attachment` omogućuje pohranu metapodataka o privicima (PDF, slike, izvješća…). Privitak se može vezati na **pregled, nalaz, uputnicu ili račun** – točno jedan vlasnik mora biti postavljen po retku, što je osigurano `CHECK` ograničenjem. Time se izbjeglo množenje specijaliziranih tablica privitaka po entitetu.

## 3.10. Računi i naplata

Financijski dio modela sastoji se od tablica `payment_method`, `invoice`, `invoice_item` i `payment`.

- `invoice` predstavlja zaglavlje računa; status računa prati se stupcem `status` (`izdan`, `placen`, `storniran`, `dospio`)
- `invoice_item` sadrži pojedine stavke računa i referencira `examination_service` (izvor istine za obavljenu uslugu); atributi cijene/popusta/poreza i dalje se kopiraju u stavku jer je izdani račun po zakonu **zamrznut** u trenutku izdavanja, neovisno o naknadnim promjenama pregleda
- `payment` evidentira uplate po računima
- `payment_method` definira načine plaćanja.

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

- jedan pacijent može imati više uputnica, termina, nalaza i računa (preglede, terapije i preporučene lijekove dohvaća se preko termina i pregleda)
- jedan odjel može imati više ordinacija i usluga
- jedna ordinacija pripada jednom odjelu, a u njoj može raditi više zaposlenika
- jedan zaposlenik pripada jednoj ordinaciji i može imati više termina i pregleda
- jedan termin pripada jednom pacijentu, jednom djelatniku, jednoj usluzi i jednoj ordinaciji, a može rezultirati pregledom
- jedan pregled može imati više dijagnoza i više obavljenih usluga (`examination_service`)
- jedan nalaz može imati više laboratorijskih rezultata; nalaz može (ali ne mora) biti vezan uz pregled
- jedna terapija obavezno proizlazi iz jednog pregleda i može imati više preporučenih lijekova
- jedan račun može imati više stavki i više uplata; stavke se vežu na obavljene usluge iz pregleda (`examination_service`)
- privitak je vezan na točno jedan od entiteta: pregled, nalaz, uputnicu ili račun.

Takve veze čine model dovoljno fleksibilnim za stvarni rad poliklinike, a istovremeno dovoljno strukturiranim za kasnije SQL upite, izvještavanje i nadogradnju sustava. 

## 6. Zaključak

Ovaj model baze podataka prikazuje **cjelovit informacijski sustav poliklinike** koji povezuje medicinsku evidenciju, organizaciju rada i financijsko poslovanje. Njegova najveća vrijednost je u tome što ne promatra samo jedan dio procesa, nego povezuje cijeli put pacijenta kroz ustanovu: od naručivanja i pregleda do nalaza, terapije i naplate. 

Zbog takve strukture baza je pogodna za izradu aplikacije koja bi podržavala svakodnevni rad poliklinike, olakšala pretragu podataka, smanjila administrativne pogreške i omogućila kvalitetnije praćenje zdravstvenih i poslovnih procesa. 
