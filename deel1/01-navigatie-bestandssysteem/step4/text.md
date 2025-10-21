# Stap 4: Schijfruimte controleren

Als systeembeheerder is het cruciaal om de schijfruimte in de gaten te houden. Het [`df`](https://man7.org/linux/man-pages/man1/df.1.html) commando (Disk Free) toont hoeveel ruimte beschikbaar is op alle gemounte bestandssystemen.

## Het df -h commando

We gebruiken [`df -h`](https://man7.org/linux/man-pages/man1/df.1.html) voor human-readable output:

```bash
df -h
```{{exec}}

## Wat zie je?

De output toont verschillende kolommen:
- **Filesystem**: Het bestandssysteem (bijv. `/dev/sda1`)
- **Size**: Totale grootte van het bestandssysteem
- **Used**: Gebruikte ruimte
- **Avail**: Beschikbare ruimte
- **Use%**: Percentage gebruikt
- **Mounted on**: Waar het bestandssysteem is gemount (bijv. `/`, `/home`)

## Waarom is dit belangrijk?

- **Monitoring**: Voorkom dat schijven vol raken
- **Capaciteitsplanning**: Weet wanneer je meer opslag nodig hebt
- **Troubleshooting**: Veel problemen ontstaan door volle schijven
- **Performance**: Volle schijven kunnen systeem vertragen

## Specifieke bestandssystemen bekijken

Je kunt ook specifieke directories controleren:

```bash
df -h /
```{{exec}}

```bash
df -h /home
```{{exec}}

## Opdracht

Voer [`df -h`](https://man7.org/linux/man-pages/man1/df.1.html) uit en let op:
1. Welk bestandssysteem heeft het hoogste gebruik percentage?
2. Hoeveel ruimte is er nog beschikbaar op de root (`/`) partitie?

Voer het commando uit om door te gaan naar de volgende stap.