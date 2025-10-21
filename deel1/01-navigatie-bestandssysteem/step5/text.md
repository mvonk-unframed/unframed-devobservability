# Stap 5: Directory grootte bepalen

Terwijl `df` de totale schijfruimte toont, helpt het `du` commando (Disk Usage) je om te zien hoeveel ruimte specifieke directories en bestanden gebruiken.

## Het du -sh commando

We gebruiken `du -sh` voor een overzichtelijke weergave:

- **`-s`**: Summary - toon alleen het totaal voor elke directory
- **`-h`**: Human-readable formaat (KB, MB, GB)

## Opdracht 1: Controleer de grootte van directories

Ga eerst terug naar je home directory:

```bash
cd ~
```{{exec}}

Bekijk de grootte van alle directories in je home:

```bash
du -sh *
```{{exec}}

## Opdracht 2: Vergelijk verschillende directories

Bekijk specifieke directories:

```bash
du -sh downloads
```{{exec}}

```bash
du -sh documents
```{{exec}}

```bash
du -sh projects
```{{exec}}

## Opdracht 3: Gedetailleerde analyse

Voor een meer gedetailleerde weergave van de projects directory:

```bash
du -h projects/
```{{exec}}

## Waarom is dit belangrijk?

- **Ruimte management**: Vind welke directories de meeste ruimte gebruiken
- **Cleanup**: Identificeer grote bestanden die je kunt verwijderen
- **Monitoring**: Houd groei van directories in de gaten
- **Troubleshooting**: Vind de oorzaak van schijfruimte problemen

## Bonus tip

Om de grootste directories te vinden, combineer `du` met `sort`:

```bash
du -sh * | sort -hr
```{{exec}}

Dit sorteert de output van groot naar klein!

Voer `du -sh *` uit om door te gaan naar de finish.
