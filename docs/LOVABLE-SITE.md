# Murdoku-site in Lovable

Laatst bijgewerkt: 6 november 2026

De site bestaat uit twee lagen:

- **De motor:** `index.html` in de GitHub-repository `Elian8or/murder-mystery-builder`, gepubliceerd via GitHub Pages op `https://elian8or.github.io/murder-mystery-builder/`. Alle puzzellogica zit hierin: solver, generator, controle, hints, PDF en tekenen. Lovable hoeft daar niets van na te bouwen of te kopiëren.
- **De site:** Lovable bouwt de pagina's eromheen (home, maken, spelen) en de database die korte codes bewaart. De motor draait op die pagina's in een iframe vanaf GitHub Pages en praat met de site via berichten (`postMessage`). Push je een nieuwe versie naar GitHub, dan heeft de site die meteen.

## Stappen

1. **Zet GitHub Pages aan** voor `Elian8or/murder-mystery-builder`: Settings → Pages → Deploy from a branch → `main`, map `/ (root)` → Save. Controleer daarna of `https://elian8or.github.io/murder-mystery-builder/` het startscherm laat zien.
2. **Maak een project in Lovable** met Lovable Cloud aan (dat is de database, Supabase).
3. **Plak de prompt hieronder** in Lovable.
4. **Test de site:**
   - Maak bij Maken een voorbeeld en klik "Deel ondergrond". Je krijgt een korte code.
   - Ga naar Spelen, vul de code in, kies een niveau en klik "Maak puzzel".
   - Genereer bij Maken aanwijzingen en klik "Deel puzzel". Speel die code.

Lovable maakt bij "Connect to GitHub" altijd een eigen, nieuwe repository voor de site. Dat is prima: de site-code staat daar, de motor blijft in `murder-mystery-builder`.

---

## Prompt voor Lovable

```
Bouw een Nederlandstalige website voor murdoku-puzzels (een logische moordpuzzel op een plattegrond).
Alle puzzellogica zit al in een kant-en-klare pagina op GitHub Pages:
  MOTOR = "https://elian8or.github.io/murder-mystery-builder/"
Die pagina NIET nabouwen of kopiëren; de site laadt hem in een iframe en praat ermee via window.postMessage.
Zet MOTOR als constante in één configbestand. Het iframe krijgt geen sandbox-attribuut (de motor moet een
PDF kunnen downloaden) en wel allow="clipboard-write" (voor de kopieerknop van codes).

PAGINA'S
1. Home (/): korte uitleg (één alinea: zet verdachten en slachtoffer op een plattegrond, één per rij en
   kolom; de moordenaar is de enige die alleen met het slachtoffer in een zone was). Twee grote knoppen:
   "Spelen" en "Maken". Op de home staat ook direct een invoerveld "Heb je een code?" met knop "Spelen".
2. Maken (/maken): een iframe van MOTOR + "?mode=make" dat de hele ruimte onder de sitekop vult
   (breedte 100%, hoogte calc(100vh - hoogte kop), geen rand). Verder niets op deze pagina.
3. Spelen (/spelen): een invoerveld voor een code + knop. Codes zijn 6 tekens (letters en cijfers);
   hoofdletterongevoelig, spaties en streepjes negeren. Bij een geldige code naar /s/CODE.
   Uitzondering: begint de invoer met "M1." of "M0." (een lange code van buiten de site), toon dan direct
   een iframe met src MOTOR + "?mode=play#play=" + encodeURIComponent(invoer).
4. Speelpagina (/s/:code): haal de rij op uit tabel murdoku_codes (code = hoofdletters). Niet gevonden:
   vriendelijke melding "Deze code bestaat niet" + terug naar Spelen. Gevonden: iframe van
   MOTOR + "?mode=play", even groot als bij Maken. Roep daarna rpc count_play(code) één keer aan.

BERICHTEN MET HET IFRAME (alleen berichten accepteren waarvan event.origin "https://elian8or.github.io" is
en event.source het contentWindow van ons eigen iframe; type staat altijd in event.data.type; bij het
terugsturen targetOrigin "https://elian8or.github.io" gebruiken)
- Van iframe: { type: "murdoku:ready" }
  -> Op de speelpagina antwoord met iframe.contentWindow.postMessage(
     { type: "murdoku:open", mode: "play", data: rij.data, code: rij.code }, "*").
     Stuur dit pas na "murdoku:ready" (anders gaat het verloren).
- Van iframe: { type: "murdoku:publish", kind: "puzzle" | "board", title, level, persons, data }
  (komt zowel van Maken als van de speelpagina)
  -> roep supabase.rpc("publish_murdoku", { p_kind: kind, p_title: title, p_level: level,
     p_persons: persons, p_data: data }) aan; dat geeft de nieuwe code terug.
  -> Antwoord: { type: "murdoku:published", kind, code, url: window.location.origin + "/s/" + code }.
  -> Bij een fout: { type: "murdoku:publish-error", message: "<korte uitleg>" }.
  Het iframe toont de code zelf; de site hoeft niets te tonen.
- Van iframe: { type: "murdoku:solved", code, seconds } -> optioneel een toast "Opgelost!".

DATABASE (Lovable Cloud / Supabase). Maak deze migratie precies zo:

create table public.murdoku_codes (
  code text primary key,
  kind text not null check (kind in ('puzzle','board')),
  title text,
  level int,
  persons int,
  data jsonb not null,
  plays int not null default 0,
  created_at timestamptz not null default now()
);
alter table public.murdoku_codes enable row level security;
create policy "codes zijn openbaar leesbaar" on public.murdoku_codes for select using (true);

create or replace function public.publish_murdoku(p_kind text, p_title text, p_level int, p_persons int, p_data jsonb)
returns text language plpgsql security definer set search_path = public as $$
declare abc text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; c text;
begin
  if p_kind not in ('puzzle','board') then raise exception 'ongeldige soort'; end if;
  if octet_length(p_data::text) > 300000 then raise exception 'puzzel te groot'; end if;
  loop
    c := '';
    for i in 1..6 loop c := c || substr(abc, 1 + floor(random() * length(abc))::int, 1); end loop;
    begin
      insert into murdoku_codes(code, kind, title, level, persons, data)
      values (c, p_kind, left(coalesce(p_title, ''), 80), p_level, p_persons, p_data);
      return c;
    exception when unique_violation then
      -- code bestond al: nieuwe proberen
    end;
  end loop;
end $$;

create or replace function public.count_play(p_code text)
returns void language sql security definer set search_path = public as $$
  update murdoku_codes set plays = plays + 1 where code = upper(p_code);
$$;

grant execute on function public.publish_murdoku(text, text, int, int, jsonb) to anon, authenticated;
grant execute on function public.count_play(text) to anon, authenticated;

Geen inlog nodig: iedereen mag spelen en delen. Er is geen insert-policy; schrijven kan alleen via
publish_murdoku.

STIJL
Rustig en neutraal (de eigen stijl volgt later): lichte achtergrond, één donkergroene accentkleur
(#2f5d50), systeemlettertype, een smalle kop met het woord "Murdoku" en links naar Spelen en Maken.
Op telefoon: home en Spelen netjes, Maken mag melden dat het op een groter scherm het best werkt.
```

---

## Wat de motor verstuurt en ontvangt

| Bericht | Richting | Inhoud |
| --- | --- | --- |
| `murdoku:ready` | motor → site | De motor is geladen. `mode` is `make` of `play`. |
| `murdoku:open` | site → motor | `{ mode: 'play', data, code }` opent een puzzel of ondergrond. |
| `murdoku:publish` | motor → site | `{ kind, title, level, persons, data }`; de site maakt een code. |
| `murdoku:published` | site → motor | `{ kind, code, url }`; de motor toont de code met een kopieerknop. |
| `murdoku:publish-error` | site → motor | `{ message }` |
| `murdoku:opened` / `murdoku:solved` | motor → site | Ter informatie; `solved` geeft ook `seconds`. |

**Wat een code bevat (`data`).** De ruimte, zones, objecten, ondergronden, ramen en personen (naam, kleur, geslacht).

- **Puzzel:** daarnaast de aanwijzingen, het niveau en de oplossing. De oplossing is versluierd, zodat je hem niet direct kunt aflezen.
- **Ondergrond:** zonder aanwijzingen. Een speler kiest zelf een niveau en de motor maakt daar een nieuwe moord en nieuwe aanwijzingen bij. Die puzzel kan de speler ook weer delen of als PDF downloaden.

**Startscherm.** Los geopend toont de motor zelf een startscherm (Spelen of Bouwen). In de site (iframe met `?mode=make` of `?mode=play`) slaat hij dat over: daar doet de homepagina van de site die keuze.

**Wisselen tussen spelen en bouwen.** Los geopend heeft de motor knoppen "▶ Spelen" en "✎ Bouwen" in de kop. In de site zit hij met `?mode=play` vast in de speelmodus; wisselen gaat daar via de links in de sitekop.

**Zonder site.** Open je `https://elian8or.github.io/murder-mystery-builder/` (of `index.html` los), dan werkt alles ook, maar dan worden codes lang (ongeveer 1500 tekens, beginnend met `M1.`). Die plak je op het startscherm bij Spelen.
