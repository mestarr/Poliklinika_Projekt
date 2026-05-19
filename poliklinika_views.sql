

USE poliklinika;


-- 1. Samo zakazani budući termini – recepcija mijenja vrijeme/status bez diranja prošlosti
DROP VIEW IF EXISTS v_termini_zakazani_buduci;
CREATE VIEW v_termini_zakazani_buduci AS
SELECT
    id,
    id_pacijent,
    id_zaposlenik,
    id_ordinacija,
    status_termina,
    vrijeme_odrzavanja,
    procjenjeno_trajanje_pregleda_minute,
    razlog_dolaska,
    razlog_otkazivanja,
    vrijeme_kreiranja,
    vrijeme_azuriranja
FROM termin_pacijenta
WHERE status_termina = 'ZAKAZAN'
  AND vrijeme_odrzavanja >= CURDATE()
WITH CASCADED CHECK OPTION;

-- 2. Aktivne usluge u cjeniku – deaktivacija samo izvan ovog prikaza
DROP VIEW IF EXISTS v_usluge_aktivne;
CREATE VIEW v_usluge_aktivne AS
SELECT
    id,
    sifra,
    naziv,
    opis,
    id_odjel,
    trajanje_pregleda_minute,
    aktivna,
    vrijeme_kreiranja,
    vrijeme_azuriranja
FROM usluga
WHERE aktivna = TRUE
WITH CASCADED CHECK OPTION;

-- 3. Računi izdani i čekaju uplatu – blagajna bilježi uplatu / storno izvan VIEW-a
DROP VIEW IF EXISTS v_racuni_cekaju_uplatu;
CREATE VIEW v_racuni_cekaju_uplatu AS
SELECT
    id,
    broj_racuna,
    id_pacijent,
    id_pregled,
    status_racuna,
    datum_izdavanja,
    datum_dospijeca,
    valuta,
    ukupno_bez_poreza,
    ukupni_porez,
    ukupni_popust,
    ukupno_za_placanje,
    napomena,
    vrijeme_kreiranja,
    vrijeme_azuriranja
FROM racun
WHERE status_racuna = 'IZDAN'
WITH CASCADED CHECK OPTION;

-- 4. Nalazi u radu (prije izdavanja) – liječnik uređuje sadržaj dok nije službeno izdan
DROP VIEW IF EXISTS v_nalazi_u_izradi;
CREATE VIEW v_nalazi_u_izradi AS
SELECT
    id,
    id_pregled,
    id_pacijent,
    id_zaposlenik,
    status_nalaza,
    izdano_u,
    sazetak,
    napomena,
    vrijeme_kreiranja,
    vrijeme_azuriranja
FROM nalaz
WHERE status_nalaza IN ('NACRT', 'UPISAN', 'VERIFIKACIJA')
WITH CASCADED CHECK OPTION;

-- 5. Otvoreni pregledi – zatvaranje pregleda ide na tablicu ili drugi status izvan VIEW-a
DROP VIEW IF EXISTS v_pregledi_otvoreni;
CREATE VIEW v_pregledi_otvoreni AS
SELECT
    id,
    id_termin_pacijenta,
    id_pacijent,
    id_zaposlenik,
    status_pregleda,
    vrijeme_odrzavanja_pregleda,
    anamneza,
    zakljucak,
    vrijeme_kreiranja,
    vrijeme_azuriranja
FROM pregled
WHERE status_pregleda = 'OTVOREN'
WITH LOCAL CHECK OPTION;

-- 6. Važeće cijene usluga – nove cijene s datumom u prošlosti ne smiju ući kroz VIEW
DROP VIEW IF EXISTS v_cijene_usluga_vazece;
CREATE VIEW v_cijene_usluga_vazece AS
SELECT
    id,
    id_usluga,
    datum_od,
    datum_do,
    iznos,
    valuta,
    porezna_stopa,
    napomena,
    vrijeme_kreiranja,
    vrijeme_azuriranja
FROM cijena_usluge
WHERE CURDATE() BETWEEN datum_od AND datum_do
WITH CASCADED CHECK OPTION;


-- ---------------------------------------------------------
-- B) READ-ONLY VIEW-ovi – prikaz, izvještaji, korisnički sučelja
-- ---------------------------------------------------------

-- 7. Pacijent s dobom i punim imenom (npr. lista čekaonice)
DROP VIEW IF EXISTS v_pacijent_prikaz;
CREATE VIEW v_pacijent_prikaz AS
SELECT
    p.id,
    p.oib,
    p.mbo,
    CONCAT(p.ime, ' ', p.prezime) AS puno_ime,
    p.ime,
    p.prezime,
    p.spol,
    p.datum_rodjenja,
    TIMESTAMPDIFF(YEAR, p.datum_rodjenja, CURDATE()) AS godine,
    p.broj_mobitela,
    p.email_adresa,
    p.adresa_stanovanja,
    p.grad,
    p.biljeska
FROM pacijent p;

-- 8. Zaposlenik s ordinacijom i specijalizacijom (raspored, kartica liječnika)
DROP VIEW IF EXISTS v_zaposlenik_prikaz;
CREATE VIEW v_zaposlenik_prikaz AS
SELECT
    z.id,
    z.sifra,
    CONCAT(z.ime, ' ', z.prezime) AS puno_ime,
    z.titula,
    s.naziv AS specijalizacija,
    ord.naziv AS ordinacija,
    o.naziv AS odjel,
    z.email,
    z.telefon,
    z.datum_zaposlenja
FROM zaposlenik z
JOIN specijalizacija s ON s.id = z.id_specijalizacija
LEFT JOIN ordinacija ord ON ord.id = z.id_ordinacija
LEFT JOIN odjel o ON o.id = ord.id_odjel;

-- 9. Današnji termini s pacijentom, liječnikom i prostorom
DROP VIEW IF EXISTS v_termini_danas;
CREATE VIEW v_termini_danas AS
SELECT
    tp.id AS id_termina,
    tp.vrijeme_odrzavanja,
    tp.status_termina,
    tp.procjenjeno_trajanje_pregleda_minute,
    CONCAT(p.ime, ' ', p.prezime) AS pacijent,
    p.broj_mobitela,
    CONCAT(z.ime, ' ', z.prezime) AS lijecnik,
    ord.naziv AS ordinacija,
    o.naziv AS odjel,
    tp.razlog_dolaska
FROM termin_pacijenta tp
JOIN pacijent p ON p.id = tp.id_pacijent
LEFT JOIN zaposlenik z ON z.id = tp.id_zaposlenik
JOIN ordinacija ord ON ord.id = tp.id_ordinacija
JOIN odjel o ON o.id = ord.id_odjel
WHERE DATE(tp.vrijeme_odrzavanja) = CURDATE();

-- 10. Raspored djelatnika za sljedećih 7 dana
DROP VIEW IF EXISTS v_raspored_sljedecih_7_dana;
CREATE VIEW v_raspored_sljedecih_7_dana AS
SELECT
    rd.datum,
    rd.vrijeme_od,
    rd.vrijeme_do,
    CONCAT(z.ime, ' ', z.prezime) AS djelatnik,
    s.naziv AS specijalizacija,
    ord.naziv AS ordinacija,
    rd.biljeska
FROM raspored_djelatnika rd
JOIN zaposlenik z ON z.id = rd.id_djelatnik
JOIN specijalizacija s ON s.id = z.id_specijalizacija
LEFT JOIN ordinacija ord ON ord.id = z.id_ordinacija
WHERE rd.datum BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
ORDER BY rd.datum, rd.vrijeme_od;

-- 11. Aktualni cjenik po odjelima (samo aktivne usluge i važeća cijena)
DROP VIEW IF EXISTS v_cjenik_aktualni;
CREATE VIEW v_cjenik_aktualni AS
SELECT
    o.sifra AS sifra_odjela,
    o.naziv AS odjel,
    u.sifra AS sifra_usluge,
    u.naziv AS usluga,
    u.trajanje_pregleda_minute,
    cu.iznos,
    cu.valuta,
    cu.porezna_stopa,
    cu.datum_od,
    cu.datum_do
FROM usluga u
LEFT JOIN odjel o ON o.id = u.id_odjel
JOIN cijena_usluge cu ON cu.id_usluga = u.id
WHERE u.aktivna = TRUE
  AND CURDATE() BETWEEN cu.datum_od AND cu.datum_do;

-- 12. Klinički zapis pregleda (termin, pacijent, liječnik, usluge)
DROP VIEW IF EXISTS v_pregled_klinicki_zapis;
CREATE VIEW v_pregled_klinicki_zapis AS
SELECT
    pr.id AS id_pregled,
    pr.vrijeme_odrzavanja_pregleda,
    pr.status_pregleda,
    CONCAT(pa.ime, ' ', pa.prezime) AS pacijent,
    pa.oib,
    CONCAT(z.ime, ' ', z.prezime) AS lijecnik,
    ord.naziv AS ordinacija,
    tp.vrijeme_odrzavanja AS vrijeme_termina,
    pr.anamneza,
    pr.zakljucak,
    GROUP_CONCAT(DISTINCT u.naziv ORDER BY u.naziv SEPARATOR '; ') AS obavljene_usluge,
    ROUND(SUM(pu.ukupni_iznos), 2) AS ukupno_usluga
FROM pregled pr
JOIN pacijent pa ON pa.id = pr.id_pacijent
LEFT JOIN zaposlenik z ON z.id = pr.id_zaposlenik
JOIN termin_pacijenta tp ON tp.id = pr.id_termin_pacijenta
JOIN ordinacija ord ON ord.id = tp.id_ordinacija
LEFT JOIN pregled_usluga pu ON pu.id_pregled = pr.id
LEFT JOIN usluga u ON u.id = pu.id_usluga
GROUP BY
    pr.id, pr.vrijeme_odrzavanja_pregleda, pr.status_pregleda,
    pa.ime, pa.prezime, pa.oib, z.ime, z.prezime,
    ord.naziv, tp.vrijeme_odrzavanja, pr.anamneza, pr.zakljucak;

-- 13. Povijest dijagnoza po pacijentu
DROP VIEW IF EXISTS v_pacijent_povijest_dijagnoza;
CREATE VIEW v_pacijent_povijest_dijagnoza AS
SELECT
    pa.id AS id_pacijent,
    CONCAT(pa.ime, ' ', pa.prezime) AS pacijent,
    pr.id AS id_pregled,
    pr.vrijeme_odrzavanja_pregleda,
    d.sifra,
    d.naziv AS dijagnoza,
    CASE WHEN pd.primarna_oznaka THEN 'primarna' ELSE 'sporedna' END AS vrsta_dijagnoze
FROM pacijent pa
JOIN pregled pr ON pr.id_pacijent = pa.id
JOIN pregled_dijagnoza pd ON pd.id_pregled = pr.id
JOIN dijagnoza d ON d.id = pd.id_dijagnoza
ORDER BY pa.id, pr.vrijeme_odrzavanja_pregleda DESC;

-- 14. Laboratorij – rezultati izvan referentnog raspona (hitna lista)
DROP VIEW IF EXISTS v_laboratorij_alarmi;
CREATE VIEW v_laboratorij_alarmi AS
SELECT
    n.id AS id_nalaz,
    CONCAT(pa.ime, ' ', pa.prezime) AS pacijent,
    n.izdano_u,
    lp.sifra AS sifra_parametra,
    lp.naziv AS parametar,
    lp.jedinica,
    lr.rezultat_broj,
    lr.referentni_min,
    lr.referentni_max,
    lr.opis_odstupanja,
    lr.uzorkovano_u,
    lr.izmjereno_u
FROM laboratorijski_rezultat lr
JOIN nalaz n ON n.id = lr.id_nalaz
JOIN pacijent pa ON pa.id = n.id_pacijent
LEFT JOIN laboratorijski_parametar lp ON lp.id = lr.id_laboratorijski_parametar
WHERE lr.oznaka_odstupanja <> 0;

-- 15. Račun sa stanjem uplate (blagajna / potraživanja)
DROP VIEW IF EXISTS v_racun_stanje;
CREATE VIEW v_racun_stanje AS
SELECT
    r.id AS id_racun,
    r.broj_racuna,
    r.status_racuna,
    r.datum_izdavanja,
    r.datum_dospijeca,
    COALESCE(CONCAT(pa.ime, ' ', pa.prezime), '(preko pregleda)') AS pacijent_na_racunu,
    r.ukupno_za_placanje,
    COALESCE(SUM(u.iznos), 0) AS ukupno_placeno,
    ROUND(r.ukupno_za_placanje - COALESCE(SUM(u.iznos), 0), 2) AS preostalo_za_platiti,
    CASE
        WHEN r.datum_dospijeca IS NOT NULL
         AND r.datum_dospijeca < CURDATE()
         AND r.ukupno_za_placanje > COALESCE(SUM(u.iznos), 0)
        THEN 'dospjelo'
        WHEN r.ukupno_za_placanje > COALESCE(SUM(u.iznos), 0)
        THEN 'otvoreno'
        ELSE 'podmireno'
    END AS status_naplate
FROM racun r
LEFT JOIN pacijent pa ON pa.id = r.id_pacijent
LEFT JOIN uplata u ON u.id_racun = r.id
WHERE r.status_racuna <> 'STORNO'
GROUP BY
    r.id, r.broj_racuna, r.status_racuna, r.datum_izdavanja, r.datum_dospijeca,
    pa.ime, pa.prezime, r.ukupno_za_placanje;

-- 16. Dospjeli računi za opomene pacijentima
DROP VIEW IF EXISTS v_racuni_dospjeli;
CREATE VIEW v_racuni_dospjeli AS
SELECT *
FROM v_racun_stanje
WHERE status_naplate = 'dospjelo'
ORDER BY datum_dospijeca, preostalo_za_platiti DESC;

-- 17. Terapija s preporučenim lijekovima (ispis za pacijenta)
DROP VIEW IF EXISTS v_terapija_recept_prikaz;
CREATE VIEW v_terapija_recept_prikaz AS
SELECT
    t.id AS id_terapija,
    CONCAT(pa.ime, ' ', pa.prezime) AS pacijent,
    pr.vrijeme_odrzavanja_pregleda AS datum_pregleda,
    t.preporuceno_u,
    t.tekst_preporuke,
    t.potrebna_kontrola,
    t.datum_kontrole,
    pl.naziv_lijeka,
    pl.doziranje,
    pl.uputa,
    pl.trajanje_dana,
    pl.napomena AS napomena_lijek
FROM terapija t
JOIN pregled pr ON pr.id = t.id_pregled
JOIN pacijent pa ON pa.id = pr.id_pacijent
LEFT JOIN preporuceni_lijek pl ON pl.id_terapija = t.id;

-- 18. Termin s planiranim uslugama (priprema ordinacije)
DROP VIEW IF EXISTS v_termin_plan_usluga;
CREATE VIEW v_termin_plan_usluga AS
SELECT
    tp.id AS id_termina,
    tp.vrijeme_odrzavanja,
    tp.status_termina,
    CONCAT(pa.ime, ' ', pa.prezime) AS pacijent,
    u.sifra AS sifra_usluge,
    u.naziv AS planirana_usluga,
    o.naziv AS odjel_usluge,
    u.trajanje_pregleda_minute
FROM termin_pacijenta tp
JOIN pacijent pa ON pa.id = tp.id_pacijent
JOIN termin_pacijenta_usluga tpu ON tpu.id_termin_pacijenta = tp.id
JOIN usluga u ON u.id = tpu.id_usluga
LEFT JOIN odjel o ON o.id = u.id_odjel;

-- 19. Realizacija: termin bez pregleda ili s pregledom (kontrola no-show / protokola)
DROP VIEW IF EXISTS v_termin_realizacija;
CREATE VIEW v_termin_realizacija AS
SELECT
    tp.id AS id_termina,
    tp.vrijeme_odrzavanja,
    tp.status_termina,
    CONCAT(pa.ime, ' ', pa.prezime) AS pacijent,
    pr.id AS id_pregled,
    pr.status_pregleda,
    CASE
        WHEN tp.status_termina IN ('OTKAZAN', 'NEMA_DOLASKA') THEN 'neuspješan_termin'
        WHEN pr.id IS NULL AND tp.status_termina = 'ZAVRSEN' THEN 'završen_bez_pregleda'
        WHEN pr.id IS NULL THEN 'nema_pregleda'
        WHEN pr.status_pregleda = 'ZAVRSEN' THEN 'realiziran'
        ELSE 'u_tijeku'
    END AS status_protokola
FROM termin_pacijenta tp
JOIN pacijent pa ON pa.id = tp.id_pacijent
LEFT JOIN pregled pr ON pr.id_termin_pacijenta = tp.id;

-- 20. Stavke računa s opisom usluge (ispis / revizija)
DROP VIEW IF EXISTS v_stavka_racuna_detalj;
CREATE VIEW v_stavka_racuna_detalj AS
SELECT
    sr.id AS id_stavka,
    r.broj_racuna,
    r.status_racuna,
    sr.opis,
    sr.kolicina,
    sr.jedinicna_cijena,
    sr.stopa_popusta,
    sr.stopa_poreza,
    sr.ukupan_iznos,
    COALESCE(u.naziv, pu_usl.naziv) AS naziv_usluge,
    CASE
        WHEN sr.id_pregled_usluga IS NOT NULL THEN 'iz_pregleda'
        WHEN sr.id_usluga IS NOT NULL THEN 'izravno'
        ELSE 'ostalo'
    END AS izvor_stavke
FROM stavka_racuna sr
JOIN racun r ON r.id = sr.id_racun
LEFT JOIN usluga u ON u.id = sr.id_usluga
LEFT JOIN pregled_usluga pu ON pu.id = sr.id_pregled_usluga
LEFT JOIN usluga pu_usl ON pu_usl.id = pu.id_usluga;

-- 21. Uplate s načinom plaćanja (dnevnik blagajne)
DROP VIEW IF EXISTS v_uplate_dnevnik;
CREATE VIEW v_uplate_dnevnik AS
SELECT
    u.id AS id_uplate,
    u.placeno_u,
    u.iznos,
    u.referenca_transakcije,
    np.naziv AS nacin_placanja,
    r.broj_racuna,
    r.status_racuna,
    COALESCE(CONCAT(pa.ime, ' ', pa.prezime), '(vezano uz pregled)') AS pacijent
FROM uplata u
JOIN nacin_placanja np ON np.id = u.id_nacin_placanja
JOIN racun r ON r.id = u.id_racun
LEFT JOIN pacijent pa ON pa.id = r.id_pacijent;

-- 22. Mjesečni prihod po odjelu (menadžment)
DROP VIEW IF EXISTS v_prihod_po_odjelu_mjesec;
CREATE VIEW v_prihod_po_odjelu_mjesec AS
SELECT
    o.sifra AS sifra_odjela,
    o.naziv AS odjel,
    DATE_FORMAT(pr.vrijeme_odrzavanja_pregleda, '%Y-%m') AS mjesec,
    COUNT(DISTINCT pr.id) AS broj_pregleda,
    COUNT(pu.id) AS broj_stavki_usluga,
    ROUND(SUM(pu.ukupni_iznos), 2) AS prihod
FROM odjel o
JOIN usluga us ON us.id_odjel = o.id
JOIN pregled_usluga pu ON pu.id_usluga = us.id
JOIN pregled pr ON pr.id = pu.id_pregled
WHERE pr.status_pregleda = 'ZAVRSEN'
GROUP BY o.sifra, o.naziv, DATE_FORMAT(pr.vrijeme_odrzavanja_pregleda, '%Y-%m');
