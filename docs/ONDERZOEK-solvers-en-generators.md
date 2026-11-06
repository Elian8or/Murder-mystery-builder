# Onderzoek: murdoku-solvers en aanwijzingengenerators

Laatst bijgewerkt: 5 november 2026

## Regels van murdoku (bedacht door Manuel Garand)

- Verdachten én slachtoffer staan op een raster, één persoon per rij en per kolom.
- Objecten bepalen waar iemand kan staan; sommige kun je op zitten/liggen (stoel, bed), andere blokkeren.
- "Naast" = direct links, rechts, boven of onder, én in dezelfde kamer.
- De dader is de enige persoon die alleen met het slachtoffer in een kamer staat.
- Typische aanwijzingen: bij een object ("naast een kassa"), een positie ("in de laatste kolom"), een relatie ("alleen met X"), een richting ("precies één rij boven Y"). Moeilijkere puzzels voegen thematische extra regels toe.

## Hoe generators voor dit soort puzzels gebouwd worden

Het patroon is bij zebra-/logic-grid-puzzels, Griductive, Puzzle Madness en onderzoeksbenchmarks (ZebraLogic, MultiZebraLogic) steeds hetzelfde:

1. **Begin bij een opgeloste wereld.** Eerst een geldige oplossing (wie staat waar), dan pas aanwijzingen.
2. **Maak een grote pool kandidaat-aanwijzingen** die waar zijn voor die oplossing (alle combinaties van persoon × aanwijzingstype × parameter). Alleen ware uitspraken komen in de pool.
3. **Kies tot er één oplossing is.** Voeg aanwijzingen toe (bij voorkeur de informatiefste) en laat de solver na elke toevoeging tellen hoeveel oplossingen er nog zijn. Stop bij precies één.
4. **Minimaliseer.** Haal aanwijzingen één voor één weg; blijft de oplossing uniek, dan was hij overbodig. Zo voelt de puzzel ontworpen in plaats van over-uitgelegd.
5. **Stuur de moeilijkheid** met gewogen keuze: simpele types (in kamer X, naast object Y) vaker voor makkelijke puzzels, negaties en relaties tussen personen vaker voor moeilijke.

## Twee soorten solver

- **Telsolver (backtracking):** probeert alle plaatsingen en telt oplossingen, met afbreken bij 2. Bij murdoku is dit een permutatie van kolommen over rijen: maximaal 10! ≈ 3,6 miljoen, maar met snoeien op geblokkeerde vakjes en aanwijzingen vrijwel direct in de browser. Dit bewijst uniciteit.
- **Menselijke solver:** past alleen stappen toe die een mens ook doet (rij/kolom wegstrepen, "enige plek voor X", object-unieke vakjes). Kan hij de puzzel zonder gokken oplossen, dan is hij eerlijk; het aantal en type stappen geeft een moeilijkheidsscore. Puzzle Madness waarschuwt dat puzzels die alleen met een computer-backtracker oplosbaar zijn niet prettig spelen.

## Plan voor stap 3 in de builder

- Telsolver in JS als basis (uniciteit).
- Aanwijzingstypes v1: in kamer X / niet in kamer X, naast object Y, op object Y, in rij/kolom n, in dezelfde rij of kolom als object Y, in dezelfde kamer als persoon Z, richting t.o.v. persoon Z.
- Generator volgens stap 1–5 hierboven; daarna menselijke solver voor de moeilijkheidsscore.
- Jij herformuleert de teksten; de checker blijft uniciteit bewaken.

## Bronnen

- AllThings.How — Murdoku explained (regels, definitie van "naast", aanwijzingstypes)
- Murdoku-fanstrategiegids (murdokufans.pages.dev) — oplosstrategie
- Lin e.a. (2025), ZebraLogic, arXiv:2502.01100 — genereren vanuit oplossing + minimaliseren met SAT-solver
- MultiZebraLogic (2025), arXiv:2511.03553 — toevoegen tot uniek, daarna overbodige aanwijzingen weghalen
- Griductive (dev.to) — kandidaat-pool, minimale set, moeilijkheidsscore
- Codemia — Algorithmically generate a Zebra puzzle
- Puzzle Madness — How we make Minesweeper (menselijke solver i.p.v. alleen backtracking)
