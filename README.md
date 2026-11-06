# Murdoku

Bouw van je eigen ruimte (huis, kantoor, tuin) een murdoku: een logische moordpuzzel op een plattegrond. Je kunt de puzzel online spelen, delen met een code of printen als PDF.

**Spelen en bouwen:** https://elian8or.github.io/murder-mystery-builder/ (werkt zodra GitHub Pages aanstaat, zie hieronder).

## Wat zit erin

Alles staat in één bestand, `index.html`: vanilla JavaScript en SVG, zonder build-stap en zonder externe bibliotheken.

- **Bouwen:**
  - zones (kamers, tuin, oprit) tekenen, met ondergronden, objecten en ramen in de muren;
  - verdachten en slachtoffer plaatsen;
  - aanwijzingen laten genereren in vier niveaus. De generator garandeert precies één oplossing die zonder gokken te vinden is.
- **Spelen:**
  - notities (klikken of slepen) en neerzetten door een vakje ingedrukt te houden, met automatische kruisjes;
  - hints die eerst op fouten wijzen en daarna uitleggen welke persoon je nu kunt neerzetten en waarom.
- **Delen:**
  - een puzzel, of een *ondergrond* (ruimte plus personen) waarmee een speler zelf een nieuwe puzzel maakt op elk niveau;
  - zonder site werkt dat met een lange code, op de site met een korte code.
- **PDF:** A4 liggend, de puzzel op één kant en eventueel de oplossing op een tweede pagina.

## GitHub Pages aanzetten (eenmalig)

1. Open de repository en ga naar **Settings → Pages**.
2. Kies bij **Source**: *Deploy from a branch*, met branch `main` en map `/ (root)`, en klik **Save**.
3. Na een minuut staat de pagina op `https://elian8or.github.io/murder-mystery-builder/`.

## Koppeling met een site (Lovable)

De site laadt deze pagina in een iframe:

- bouwen: `…/murder-mystery-builder/?mode=make`
- spelen: `…/murder-mystery-builder/?mode=play`

De site bewaart puzzels onder korte codes in een database. Een nieuwe versie van `index.html` pushen is genoeg; de site pakt hem vanzelf op.

- Prompt voor Lovable, inclusief het berichtenprotocol: [`docs/LOVABLE-SITE.md`](docs/LOVABLE-SITE.md)
- Databaseschema (Supabase): [`docs/supabase.sql`](docs/supabase.sql)
- Achtergrond bij solver en generator: [`docs/ONDERZOEK-solvers-en-generators.md`](docs/ONDERZOEK-solvers-en-generators.md)

## Losse parameters

| Adres | Wat het doet |
| --- | --- |
| `index.html` | Startscherm met de keuze Spelen of Bouwen |
| `?mode=make` | Direct naar bouwen (voor gebruik in een iframe) |
| `?mode=play` | Alleen spelen; wacht op een `murdoku:open`-bericht van de site |
| `#play=M1.…` | Speelt de puzzel of ondergrond uit een lange code |
