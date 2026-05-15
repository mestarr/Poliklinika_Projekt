USE poliklinika;

-- =========================================================
-- POLIKLINIKA - SVI SQL UPITI
-- Osnovni/jaki upiti + dodatni kompleksni upiti
-- =========================================================


-- =========================================================
-- A) OSNOVNI I JAKI UPITI
-- =========================================================

-- 1. Broj pacijenata po gradu
SELECT grad, COUNT(*) AS broj_pacijenata
FROM pacijent
GROUP BY grad
ORDER BY broj_pacijenata DESC, grad;

-- 2. Dobna struktura pacijenata
SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, datum_rodjenja, CURDATE()) < 18 THEN '0-17'
        WHEN TIMESTAMPDIFF(YEAR, datum_rodjenja, CURDATE()) BETWEEN 18 AND 39 THEN '18-39'
        WHEN TIMESTAMPDIFF(YEAR, datum_rodjenja, CURDATE()) BETWEEN 40 AND 64 THEN '40-64'
        ELSE '65+'
    END AS dobna_skupina,
    COUNT(*) AS broj_pacijenata
FROM pacijent
GROUP BY dobna_skupina
ORDER BY dobna_skupina;

-- 3. Odjeli s brojem ordinacija i usluga
SELECT
    o.id,
    o.naziv AS odjel,
    COUNT(DISTINCT ord.id) AS broj_ordinacija,
    COUNT(DISTINCT u.id) AS broj_usluga
FROM odjel o
LEFT JOIN ordinacija ord ON ord.id_odjel = o.id
LEFT JOIN usluga u ON u.id_odjel = o.id
GROUP BY o.id, o.naziv
ORDER BY broj_usluga DESC, broj_ordinacija DESC;

-- 4. Cjenik usluga po odjelima
SELECT
    o.naziv AS odjel,
    u.sifra,
    u.naziv AS usluga,
    u.trajanje_pregleda_minute,
    cu.iznos,
    cu.valuta,
    cu.porezna_stopa
FROM usluga u
JOIN odjel o ON o.id = u.id_odjel
JOIN cijena_usluge cu ON cu.id_usluga = u.id
WHERE u.aktivna = TRUE
  AND CURDATE() BETWEEN cu.datum_od AND cu.datum_do
ORDER BY o.naziv, u.naziv;

-- 5. Termini po statusu
SELECT status_termina, COUNT(*) AS broj_termina
FROM termin_pacijenta
GROUP BY status_termina
ORDER BY broj_termina DESC;

-- 6. Termini po mjesecu i statusu
SELECT
    DATE_FORMAT(vrijeme_odrzavanja, '%Y-%m') AS mjesec,
    status_termina,
    COUNT(*) AS broj_termina
FROM termin_pacijenta
GROUP BY DATE_FORMAT(vrijeme_odrzavanja, '%Y-%m'), status_termina
ORDER BY mjesec, status_termina;

-- 7. Najcesce trazene usluge u terminima
SELECT
    u.naziv AS usluga,
    o.naziv AS odjel,
    COUNT(tpu.id) AS broj_termina
FROM termin_pacijenta_usluga tpu
JOIN usluga u ON u.id = tpu.id_usluga
LEFT JOIN odjel o ON o.id = u.id_odjel
GROUP BY u.id, u.naziv, o.naziv
ORDER BY broj_termina DESC, usluga
LIMIT 20;

-- 8. Pregledi s pacijentom, lijecnikom i ordinacijom
SELECT
    pr.id AS id_pregled,
    p.ime AS ime_pacijenta,
    p.prezime AS prezime_pacijenta,
    z.ime AS ime_lijecnika,
    z.prezime AS prezime_lijecnika,
    ord.naziv AS ordinacija,
    pr.status_pregleda,
    pr.vrijeme_odrzavanja_pregleda
FROM pregled pr
JOIN pacijent p ON p.id = pr.id_pacijent
LEFT JOIN zaposlenik z ON z.id = pr.id_zaposlenik
JOIN termin_pacijenta t ON t.id = pr.id_termin_pacijenta
JOIN ordinacija ord ON ord.id = t.id_ordinacija
ORDER BY pr.vrijeme_odrzavanja_pregleda DESC;

-- 9. Broj pregleda po zaposleniku
SELECT
    z.id,
    CONCAT(z.ime, ' ', z.prezime) AS zaposlenik,
    s.naziv AS specijalizacija,
    COUNT(pr.id) AS broj_pregleda
FROM zaposlenik z
JOIN specijalizacija s ON s.id = z.id_specijalizacija
LEFT JOIN pregled pr ON pr.id_zaposlenik = z.id
GROUP BY z.id, zaposlenik, s.naziv
ORDER BY broj_pregleda DESC, zaposlenik;

-- 10. Iskoristenost rasporeda po zaposleniku
SELECT
    z.id,
    CONCAT(z.ime, ' ', z.prezime) AS zaposlenik,
    COUNT(DISTINCT rd.id) AS broj_smjena,
    COUNT(DISTINCT t.id) AS broj_termina
FROM zaposlenik z
LEFT JOIN raspored_djelatnika rd ON rd.id_djelatnik = z.id
LEFT JOIN termin_pacijenta t
    ON t.id_zaposlenik = z.id
   AND DATE(t.vrijeme_odrzavanja) = rd.datum
GROUP BY z.id, zaposlenik
ORDER BY broj_termina DESC, broj_smjena DESC;

-- 11. Pregledi i obavljene usluge s iznosima
SELECT
    pr.id AS id_pregled,
    p.ime,
    p.prezime,
    u.naziv AS usluga,
    pu.kolicina,
    pu.cijena,
    pu.popust,
    pu.ukupni_iznos
FROM pregled_usluga pu
JOIN pregled pr ON pr.id = pu.id_pregled
JOIN pacijent p ON p.id = pr.id_pacijent
JOIN usluga u ON u.id = pu.id_usluga
ORDER BY pr.id, u.naziv;

-- 12. Ukupni iznos obavljenih usluga po odjelu
SELECT
    o.naziv AS odjel,
    COUNT(pu.id) AS broj_obavljenih_usluga,
    ROUND(SUM(pu.ukupni_iznos), 2) AS ukupni_iznos
FROM pregled_usluga pu
JOIN usluga u ON u.id = pu.id_usluga
JOIN odjel o ON o.id = u.id_odjel
GROUP BY o.id, o.naziv
ORDER BY ukupni_iznos DESC;

-- 13. Najcesce evidentirane dijagnoze
SELECT
    d.sifra,
    d.naziv,
    COUNT(pd.id) AS broj_pojavljivanja,
    SUM(CASE WHEN pd.primarna_oznaka THEN 1 ELSE 0 END) AS broj_primarnih
FROM pregled_dijagnoza pd
JOIN dijagnoza d ON d.id = pd.id_dijagnoza
GROUP BY d.id, d.sifra, d.naziv
ORDER BY broj_pojavljivanja DESC, broj_primarnih DESC
LIMIT 15;

-- 14. Sve dijagnoze za pojedini pregled
SELECT
    pr.id AS id_pregled,
    p.ime,
    p.prezime,
    d.sifra,
    d.naziv AS dijagnoza,
    CASE WHEN pd.primarna_oznaka THEN 'primarna' ELSE 'sporedna' END AS vrsta
FROM pregled_dijagnoza pd
JOIN pregled pr ON pr.id = pd.id_pregled
JOIN pacijent p ON p.id = pr.id_pacijent
JOIN dijagnoza d ON d.id = pd.id_dijagnoza
ORDER BY pr.id, pd.primarna_oznaka DESC, d.sifra;

-- 15. Nalazi s pacijentom i zaposlenikom
SELECT
    n.id AS id_nalaz,
    p.ime,
    p.prezime,
    z.ime AS ime_zaposlenika,
    z.prezime AS prezime_zaposlenika,
    n.status_nalaza,
    n.izdano_u,
    n.sazetak
FROM nalaz n
JOIN pacijent p ON p.id = n.id_pacijent
LEFT JOIN zaposlenik z ON z.id = n.id_zaposlenik
ORDER BY n.izdano_u DESC;

-- 16. Laboratorijski rezultati s odstupanjem
SELECT
    n.id AS id_nalaz,
    p.ime,
    p.prezime,
    lp.naziv AS parametar,
    lr.rezultat_broj,
    lp.jedinica,
    lr.referentni_min,
    lr.referentni_max,
    lr.opis_odstupanja
FROM laboratorijski_rezultat lr
JOIN nalaz n ON n.id = lr.id_nalaz
JOIN pacijent p ON p.id = n.id_pacijent
LEFT JOIN laboratorijski_parametar lp ON lp.id = lr.id_laboratorijski_parametar
WHERE lr.oznaka_odstupanja <> 0
ORDER BY n.id, lp.naziv;

-- 17. Terapije i preporuceni lijekovi
SELECT
    t.id AS id_terapija,
    p.ime,
    p.prezime,
    t.preporuceno_u,
    t.tekst_preporuke,
    pl.naziv_lijeka,
    pl.doziranje,
    pl.trajanje_dana
FROM terapija t
JOIN pregled pr ON pr.id = t.id_pregled
JOIN pacijent p ON p.id = pr.id_pacijent
LEFT JOIN preporuceni_lijek pl ON pl.id_terapija = t.id
ORDER BY t.preporuceno_u DESC;

-- 18. Racuni s iznosima i statusom
SELECT
    r.broj_racuna,
    p.ime,
    p.prezime,
    r.status_racuna,
    r.datum_izdavanja,
    r.datum_dospijeca,
    r.ukupno_bez_poreza,
    r.ukupni_porez,
    r.ukupni_popust,
    r.ukupno_za_placanje
FROM racun r
LEFT JOIN pacijent p ON p.id = r.id_pacijent
ORDER BY r.datum_izdavanja DESC, r.broj_racuna;

-- 19. Racuni, uplate i otvoreni iznos
SELECT
    r.broj_racuna,
    r.status_racuna,
    r.ukupno_za_placanje,
    COALESCE(SUM(u.iznos), 0) AS ukupno_placeno,
    r.ukupno_za_placanje - COALESCE(SUM(u.iznos), 0) AS preostalo_za_platiti
FROM racun r
LEFT JOIN uplata u ON u.id_racun = r.id
GROUP BY r.id, r.broj_racuna, r.status_racuna, r.ukupno_za_placanje
ORDER BY preostalo_za_platiti DESC;

-- 20. Prihod po nacinu placanja
SELECT
    np.naziv AS nacin_placanja,
    COUNT(u.id) AS broj_uplata,
    ROUND(SUM(u.iznos), 2) AS ukupno_uplaceno
FROM uplata u
JOIN nacin_placanja np ON np.id = u.id_nacin_placanja
GROUP BY np.id, np.naziv
ORDER BY ukupno_uplaceno DESC;

-- 21. Prihod po mjesecu
SELECT
    DATE_FORMAT(placeno_u, '%Y-%m') AS mjesec,
    COUNT(*) AS broj_uplata,
    ROUND(SUM(iznos), 2) AS ukupno_uplaceno
FROM uplata
GROUP BY DATE_FORMAT(placeno_u, '%Y-%m')
ORDER BY mjesec;

-- 22. Pacijenti s vise pregleda
SELECT
    p.id,
    p.ime,
    p.prezime,
    COUNT(pr.id) AS broj_pregleda
FROM pacijent p
JOIN pregled pr ON pr.id_pacijent = p.id
GROUP BY p.id, p.ime, p.prezime
HAVING COUNT(pr.id) >= 2
ORDER BY broj_pregleda DESC, p.prezime;

-- 23. Termini bez pregleda
SELECT
    t.id AS id_termina,
    p.ime,
    p.prezime,
    t.status_termina,
    t.vrijeme_odrzavanja
FROM termin_pacijenta t
JOIN pacijent p ON p.id = t.id_pacijent
LEFT JOIN pregled pr ON pr.id_termin_pacijenta = t.id
WHERE pr.id IS NULL
ORDER BY t.vrijeme_odrzavanja;

-- 24. Odjeli s najvecom prosjecnom cijenom usluge
SELECT
    o.naziv AS odjel,
    COUNT(u.id) AS broj_usluga,
    ROUND(AVG(cu.iznos), 2) AS prosjecna_cijena
FROM odjel o
JOIN usluga u ON u.id_odjel = o.id
JOIN cijena_usluge cu ON cu.id_usluga = u.id
WHERE CURDATE() BETWEEN cu.datum_od AND cu.datum_do
GROUP BY o.id, o.naziv
ORDER BY prosjecna_cijena DESC;

-- 25. Cjeloviti karton pacijenta kroz termine, preglede, nalaze i racune
SELECT
    p.id AS id_pacijent,
    p.ime,
    p.prezime,
    t.id AS id_termin,
    t.vrijeme_odrzavanja,
    pr.id AS id_pregled,
    n.id AS id_nalaz,
    r.broj_racuna,
    r.status_racuna,
    r.ukupno_za_placanje
FROM pacijent p
LEFT JOIN termin_pacijenta t ON t.id_pacijent = p.id
LEFT JOIN pregled pr ON pr.id_termin_pacijenta = t.id
LEFT JOIN nalaz n ON n.id_pregled = pr.id
LEFT JOIN racun r ON r.id_pregled = pr.id
ORDER BY p.id, t.vrijeme_odrzavanja;


-- =========================================================
-- B) DODATNI KOMPLEKSNI UPITI
-- =========================================================

-- 1. Pregled opterecenja odjela: termini, pregledi, realizacija, ukupni iznos i prosjecna naplata
WITH termini_po_odjelu AS (
    SELECT 
        o.id AS id_odjel,
        o.naziv AS odjel,
        COUNT(DISTINCT t.id) AS broj_termina,
        COUNT(DISTINCT pr.id) AS broj_pregleda,
        ROUND(COUNT(DISTINCT pr.id) / NULLIF(COUNT(DISTINCT t.id), 0) * 100, 2) AS postotak_realizacije
    FROM odjel o
    LEFT JOIN usluga u ON u.id_odjel = o.id
    LEFT JOIN termin_pacijenta_usluga tpu ON tpu.id_usluga = u.id
    LEFT JOIN termin_pacijenta t ON t.id = tpu.id_termin_pacijenta
    LEFT JOIN pregled pr ON pr.id_termin_pacijenta = t.id
    GROUP BY o.id, o.naziv
),
prihod_po_odjelu AS (
    SELECT 
        o.id AS id_odjel,
        ROUND(SUM(pu.ukupni_iznos), 2) AS ukupni_iznos_usluga,
        ROUND(AVG(pu.ukupni_iznos), 2) AS prosjecni_iznos_usluge
    FROM odjel o
    LEFT JOIN usluga u ON u.id_odjel = o.id
    LEFT JOIN pregled_usluga pu ON pu.id_usluga = u.id
    GROUP BY o.id
)
SELECT 
    t.odjel,
    t.broj_termina,
    t.broj_pregleda,
    t.postotak_realizacije,
    COALESCE(p.ukupni_iznos_usluga, 0) AS ukupni_iznos_usluga,
    COALESCE(p.prosjecni_iznos_usluge, 0) AS prosjecni_iznos_usluge
FROM termini_po_odjelu t
LEFT JOIN prihod_po_odjelu p ON p.id_odjel = t.id_odjel
ORDER BY ukupni_iznos_usluga DESC, broj_pregleda DESC;

-- 2. Top 10 pacijenata prema ukupnoj potrosnji, broju pregleda i broju razlicitih odjela
SELECT
    p.id AS id_pacijent,
    p.ime,
    p.prezime,
    p.grad,
    COUNT(DISTINCT pr.id) AS broj_pregleda,
    COUNT(DISTINCT o.id) AS broj_razlicitih_odjela,
    ROUND(COALESCE(SUM(r.ukupno_za_placanje), 0), 2) AS ukupno_zaduzeno,
    ROUND(COALESCE(SUM(upl.iznos), 0), 2) AS ukupno_placeno,
    ROUND(COALESCE(SUM(r.ukupno_za_placanje), 0) - COALESCE(SUM(upl.iznos), 0), 2) AS otvoreni_iznos
FROM pacijent p
LEFT JOIN pregled pr ON pr.id_pacijent = p.id
LEFT JOIN pregled_usluga pu ON pu.id_pregled = pr.id
LEFT JOIN usluga us ON us.id = pu.id_usluga
LEFT JOIN odjel o ON o.id = us.id_odjel
LEFT JOIN racun r ON r.id_pregled = pr.id
LEFT JOIN uplata upl ON upl.id_racun = r.id
GROUP BY p.id, p.ime, p.prezime, p.grad
HAVING ukupno_zaduzeno > 0
ORDER BY ukupno_zaduzeno DESC, broj_pregleda DESC
LIMIT 10;

-- 3. Pacijenti koji imaju pregled, nalaz, terapiju i racun u istom procesu
SELECT
    p.id AS id_pacijent,
    CONCAT(p.ime, ' ', p.prezime) AS pacijent,
    pr.id AS id_pregled,
    pr.vrijeme_odrzavanja_pregleda,
    n.id AS id_nalaz,
    n.status_nalaza,
    t.id AS id_terapija,
    r.broj_racuna,
    r.status_racuna,
    r.ukupno_za_placanje
FROM pacijent p
JOIN pregled pr ON pr.id_pacijent = p.id
JOIN nalaz n ON n.id_pregled = pr.id
JOIN terapija t ON t.id_pregled = pr.id
JOIN racun r ON r.id_pregled = pr.id
ORDER BY pr.vrijeme_odrzavanja_pregleda DESC;

-- 4. Prosjecno vrijeme od termina do pregleda po odjelu
SELECT
    o.naziv AS odjel,
    COUNT(pr.id) AS broj_pregleda,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, tp.vrijeme_odrzavanja, pr.vrijeme_odrzavanja_pregleda)), 2) AS prosjecno_kasnjenje_min,
    MIN(TIMESTAMPDIFF(MINUTE, tp.vrijeme_odrzavanja, pr.vrijeme_odrzavanja_pregleda)) AS minimalno_kasnjenje_min,
    MAX(TIMESTAMPDIFF(MINUTE, tp.vrijeme_odrzavanja, pr.vrijeme_odrzavanja_pregleda)) AS maksimalno_kasnjenje_min
FROM pregled pr
JOIN termin_pacijenta tp ON tp.id = pr.id_termin_pacijenta
JOIN termin_pacijenta_usluga tpu ON tpu.id_termin_pacijenta = tp.id
JOIN usluga u ON u.id = tpu.id_usluga
JOIN odjel o ON o.id = u.id_odjel
GROUP BY o.id, o.naziv
ORDER BY prosjecno_kasnjenje_min DESC;

-- 5. Usluge koje donose najveci prihod po mjesecu
WITH prihod_usluga AS (
    SELECT
        DATE_FORMAT(pr.vrijeme_odrzavanja_pregleda, '%Y-%m') AS mjesec,
        u.id AS id_usluga,
        u.naziv AS usluga,
        o.naziv AS odjel,
        COUNT(pu.id) AS broj_obavljanja,
        ROUND(SUM(pu.ukupni_iznos), 2) AS prihod
    FROM pregled_usluga pu
    JOIN pregled pr ON pr.id = pu.id_pregled
    JOIN usluga u ON u.id = pu.id_usluga
    JOIN odjel o ON o.id = u.id_odjel
    GROUP BY DATE_FORMAT(pr.vrijeme_odrzavanja_pregleda, '%Y-%m'), u.id, u.naziv, o.naziv
),
rangirano AS (
    SELECT
        prihod_usluga.*,
        ROW_NUMBER() OVER (PARTITION BY mjesec ORDER BY prihod DESC) AS rang_u_mjesecu
    FROM prihod_usluga
)
SELECT *
FROM rangirano
WHERE rang_u_mjesecu <= 5
ORDER BY mjesec, rang_u_mjesecu;

-- 6. Zaposlenici po ucinku: pregledi, prihod, prosjecna vrijednost pregleda
SELECT
    z.id AS id_zaposlenik,
    CONCAT(z.ime, ' ', z.prezime) AS zaposlenik,
    s.naziv AS specijalizacija,
    COUNT(DISTINCT pr.id) AS broj_pregleda,
    COUNT(DISTINCT p.id) AS broj_pacijenata,
    ROUND(COALESCE(SUM(pu.ukupni_iznos), 0), 2) AS ukupna_vrijednost_usluga,
    ROUND(COALESCE(SUM(pu.ukupni_iznos), 0) / NULLIF(COUNT(DISTINCT pr.id), 0), 2) AS prosjek_po_pregledu
FROM zaposlenik z
JOIN specijalizacija s ON s.id = z.id_specijalizacija
LEFT JOIN pregled pr ON pr.id_zaposlenik = z.id
LEFT JOIN pacijent p ON p.id = pr.id_pacijent
LEFT JOIN pregled_usluga pu ON pu.id_pregled = pr.id
GROUP BY z.id, zaposlenik, s.naziv
ORDER BY ukupna_vrijednost_usluga DESC, broj_pregleda DESC;

-- 7. Odstupanja laboratorijskih nalaza po parametrima
SELECT
    lp.sifra,
    lp.naziv AS laboratorijski_parametar,
    lp.jedinica,
    COUNT(lr.id) AS broj_mjerenja,
    SUM(CASE WHEN lr.oznaka_odstupanja <> 0 THEN 1 ELSE 0 END) AS broj_odstupanja,
    ROUND(SUM(CASE WHEN lr.oznaka_odstupanja <> 0 THEN 1 ELSE 0 END) / COUNT(lr.id) * 100, 2) AS postotak_odstupanja,
    ROUND(AVG(lr.rezultat_broj), 2) AS prosjecni_rezultat
FROM laboratorijski_parametar lp
JOIN laboratorijski_rezultat lr ON lr.id_laboratorijski_parametar = lp.id
GROUP BY lp.id, lp.sifra, lp.naziv, lp.jedinica
ORDER BY postotak_odstupanja DESC, broj_mjerenja DESC;

-- 8. Pacijenti s abnormalnim laboratorijskim nalazima i propisanom terapijom
SELECT DISTINCT
    p.id AS id_pacijent,
    CONCAT(p.ime, ' ', p.prezime) AS pacijent,
    n.id AS id_nalaz,
    lp.naziv AS parametar,
    lr.rezultat_broj,
    lr.opis_odstupanja,
    t.id AS id_terapija,
    t.tekst_preporuke
FROM laboratorijski_rezultat lr
JOIN laboratorijski_parametar lp ON lp.id = lr.id_laboratorijski_parametar
JOIN nalaz n ON n.id = lr.id_nalaz
JOIN pacijent p ON p.id = n.id_pacijent
JOIN terapija t ON t.id_nalaz = n.id
WHERE lr.oznaka_odstupanja <> 0
ORDER BY pacijent, n.id;

-- 9. Racuni koji nisu u potpunosti placeni
SELECT
    r.id AS id_racun,
    r.broj_racuna,
    p.ime,
    p.prezime,
    r.status_racuna,
    r.datum_izdavanja,
    r.datum_dospijeca,
    r.ukupno_za_placanje,
    COALESCE(SUM(u.iznos), 0) AS ukupno_placeno,
    ROUND(r.ukupno_za_placanje - COALESCE(SUM(u.iznos), 0), 2) AS otvoreno,
    CASE
        WHEN r.datum_dospijeca < CURDATE() 
             AND r.ukupno_za_placanje > COALESCE(SUM(u.iznos), 0)
        THEN 'dospjelo'
        WHEN r.ukupno_za_placanje > COALESCE(SUM(u.iznos), 0)
        THEN 'otvoreno'
        ELSE 'placeno'
    END AS status_naplate
FROM racun r
LEFT JOIN pacijent p ON p.id = r.id_pacijent
LEFT JOIN uplata u ON u.id_racun = r.id
GROUP BY r.id, r.broj_racuna, p.ime, p.prezime, r.status_racuna, r.datum_izdavanja, r.datum_dospijeca, r.ukupno_za_placanje
HAVING otvoreno > 0
ORDER BY status_naplate, otvoreno DESC;

-- 10. Mjesecni financijski pregled: izdani racuni, uplate i otvoreni iznos
WITH racuni_mj AS (
    SELECT
        DATE_FORMAT(datum_izdavanja, '%Y-%m') AS mjesec,
        COUNT(*) AS broj_racuna,
        ROUND(SUM(ukupno_za_placanje), 2) AS ukupno_zaduzeno
    FROM racun
    GROUP BY DATE_FORMAT(datum_izdavanja, '%Y-%m')
),
uplate_mj AS (
    SELECT
        DATE_FORMAT(placeno_u, '%Y-%m') AS mjesec,
        COUNT(*) AS broj_uplata,
        ROUND(SUM(iznos), 2) AS ukupno_placeno
    FROM uplata
    GROUP BY DATE_FORMAT(placeno_u, '%Y-%m')
)
SELECT
    r.mjesec,
    r.broj_racuna,
    r.ukupno_zaduzeno,
    COALESCE(u.broj_uplata, 0) AS broj_uplata,
    COALESCE(u.ukupno_placeno, 0) AS ukupno_placeno,
    ROUND(r.ukupno_zaduzeno - COALESCE(u.ukupno_placeno, 0), 2) AS razlika
FROM racuni_mj r
LEFT JOIN uplate_mj u ON u.mjesec = r.mjesec
ORDER BY r.mjesec;

-- 11. Pacijenti koji su imali vise razlicitih specijalizacija
SELECT
    p.id AS id_pacijent,
    CONCAT(p.ime, ' ', p.prezime) AS pacijent,
    COUNT(DISTINCT s.id) AS broj_specijalizacija,
    GROUP_CONCAT(DISTINCT s.naziv ORDER BY s.naziv SEPARATOR ', ') AS specijalizacije
FROM pacijent p
JOIN pregled pr ON pr.id_pacijent = p.id
LEFT JOIN zaposlenik z ON z.id = pr.id_zaposlenik
LEFT JOIN specijalizacija s ON s.id = z.id_specijalizacija
GROUP BY p.id, pacijent
HAVING COUNT(DISTINCT s.id) >= 2
ORDER BY broj_specijalizacija DESC, pacijent;

-- 12. Pregledi bez nalaza, terapije ili racuna
SELECT
    pr.id AS id_pregled,
    p.ime,
    p.prezime,
    pr.vrijeme_odrzavanja_pregleda,
    CASE WHEN n.id IS NULL THEN 'nema nalaz' ELSE 'ima nalaz' END AS nalaz_status,
    CASE WHEN t.id IS NULL THEN 'nema terapiju' ELSE 'ima terapiju' END AS terapija_status,
    CASE WHEN r.id IS NULL THEN 'nema racun' ELSE 'ima racun' END AS racun_status
FROM pregled pr
JOIN pacijent p ON p.id = pr.id_pacijent
LEFT JOIN nalaz n ON n.id_pregled = pr.id
LEFT JOIN terapija t ON t.id_pregled = pr.id
LEFT JOIN racun r ON r.id_pregled = pr.id
WHERE n.id IS NULL OR t.id IS NULL OR r.id IS NULL
ORDER BY pr.vrijeme_odrzavanja_pregleda DESC;

-- 13. Analiza no-show i otkazanih termina po odjelu
SELECT
    o.naziv AS odjel,
    COUNT(DISTINCT tp.id) AS ukupno_termina,
    SUM(CASE WHEN tp.status_termina = 'OTKAZAN' THEN 1 ELSE 0 END) AS broj_otkazanih,
    SUM(CASE WHEN tp.status_termina = 'NEMA_DOLASKA' THEN 1 ELSE 0 END) AS broj_nedolazaka,
    ROUND(SUM(CASE WHEN tp.status_termina IN ('OTKAZAN','NEMA_DOLASKA') THEN 1 ELSE 0 END) / COUNT(DISTINCT tp.id) * 100, 2) AS postotak_neuspjelih
FROM termin_pacijenta tp
JOIN termin_pacijenta_usluga tpu ON tpu.id_termin_pacijenta = tp.id
JOIN usluga u ON u.id = tpu.id_usluga
JOIN odjel o ON o.id = u.id_odjel
GROUP BY o.id, o.naziv
ORDER BY postotak_neuspjelih DESC, ukupno_termina DESC;

-- 14. Usporedba planiranog trajanja termina i stvarnog trajanja obavljenih usluga
SELECT
    tp.id AS id_termina,
    p.ime,
    p.prezime,
    tp.procjenjeno_trajanje_pregleda_minute AS planirano_minuta,
    SUM(u.trajanje_pregleda_minute) AS zbroj_trajanja_usluga,
    SUM(u.trajanje_pregleda_minute) - tp.procjenjeno_trajanje_pregleda_minute AS razlika_minuta
FROM termin_pacijenta tp
JOIN pacijent p ON p.id = tp.id_pacijent
JOIN termin_pacijenta_usluga tpu ON tpu.id_termin_pacijenta = tp.id
JOIN usluga u ON u.id = tpu.id_usluga
GROUP BY tp.id, p.ime, p.prezime, tp.procjenjeno_trajanje_pregleda_minute
ORDER BY ABS(razlika_minuta) DESC;

-- 15. Sveobuhvatni prikaz pacijenta: zadnji termin, zadnji pregled, zadnji nalaz i zadnji racun
WITH zadnji_termin AS (
    SELECT 
        id_pacijent,
        MAX(vrijeme_odrzavanja) AS zadnji_termin
    FROM termin_pacijenta
    GROUP BY id_pacijent
),
zadnji_pregled AS (
    SELECT 
        id_pacijent,
        MAX(vrijeme_odrzavanja_pregleda) AS zadnji_pregled
    FROM pregled
    GROUP BY id_pacijent
),
zadnji_nalaz AS (
    SELECT 
        id_pacijent,
        MAX(izdano_u) AS zadnji_nalaz
    FROM nalaz
    GROUP BY id_pacijent
),
financije AS (
    SELECT
        r.id_pacijent,
        ROUND(SUM(r.ukupno_za_placanje), 2) AS ukupno_racuni,
        ROUND(COALESCE(SUM(u.iznos), 0), 2) AS ukupno_uplate
    FROM racun r
    LEFT JOIN uplata u ON u.id_racun = r.id
    GROUP BY r.id_pacijent
)
SELECT
    p.id AS id_pacijent,
    CONCAT(p.ime, ' ', p.prezime) AS pacijent,
    p.grad,
    zt.zadnji_termin,
    zp.zadnji_pregled,
    zn.zadnji_nalaz,
    COALESCE(f.ukupno_racuni, 0) AS ukupno_racuni,
    COALESCE(f.ukupno_uplate, 0) AS ukupno_uplate,
    ROUND(COALESCE(f.ukupno_racuni, 0) - COALESCE(f.ukupno_uplate, 0), 2) AS otvoreno
FROM pacijent p
LEFT JOIN zadnji_termin zt ON zt.id_pacijent = p.id
LEFT JOIN zadnji_pregled zp ON zp.id_pacijent = p.id
LEFT JOIN zadnji_nalaz zn ON zn.id_pacijent = p.id
LEFT JOIN financije f ON f.id_pacijent = p.id
ORDER BY otvoreno DESC, pacijent;
