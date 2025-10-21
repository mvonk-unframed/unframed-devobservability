# Stap 4: Script executable maken

Een van de meest voorkomende taken is het executable maken van scripts. Scripts moeten uitvoerbaar zijn om te kunnen draaien, maar worden vaak zonder execute rechten aangeleverd.

## Huidige situatie controleren

Laten we eerst kijken naar de scripts in de scripts directory:

```bash
ls -l /home/student/scripts/
```{{exec}}

Je zult zien dat de scripts momenteel niet uitvoerbaar zijn (geen 'x' in de rechten).

## Probeer een script uit te voeren

Probeer het backup script uit te voeren:

```bash
/home/student/scripts/backup.sh
```{{exec}}

Je krijgt een "Permission denied" fout omdat het script niet uitvoerbaar is.

## Opdracht 1: Maak backup script executable

Maak het backup script uitvoerbaar voor de eigenaar:

```bash
chmod u+x /home/student/scripts/backup.sh
```{{exec}}

Nu kun je het script uitvoeren:

```bash
/home/student/scripts/backup.sh
```{{exec}}

## Opdracht 2: Maak alle scripts executable

Maak alle scripts in de scripts directory uitvoerbaar:

```bash
chmod u+x /home/student/scripts/*.sh
```{{exec}}

```bash
chmod u+x /home/student/scripts/*.py
```{{exec}}

## Opdracht 3: Gebruik numerieke chmod

Je kunt ook numerieke chmod gebruiken. Voor een script wil je meestal 755 (rwxr-xr-x):

```bash
chmod 755 /home/student/scripts/monitor.sh
```{{exec}}

Dit geeft:
- **Eigenaar**: read, write, execute (7)
- **Groep**: read, execute (5)
- **Anderen**: read, execute (5)

## Test alle scripts

Test nu alle scripts:

```bash
/home/student/scripts/backup.sh
```{{exec}}

```bash
/home/student/scripts/monitor.sh
```{{exec}}

```bash
/home/student/scripts/process_data.py
```{{exec}}

## Verificatie

Controleer de rechten van alle scripts:

```bash
ls -l /home/student/scripts/
```{{exec}}

Alle scripts zouden nu uitvoerbaar moeten zijn (met 'x' in de rechten).

## Beste praktijken voor scripts

- **755**: Voor scripts die anderen mogen uitvoeren
- **750**: Voor scripts die alleen groepsleden mogen uitvoeren  
- **700**: Voor persoonlijke scripts (alleen eigenaar)
- **644**: Voor scripts die nog niet klaar zijn (niet uitvoerbaar)

## Shebang lijn

Let op de eerste regel van scripts (shebang):
- `#!/bin/bash` - Voor bash scripts
- `#!/usr/bin/python3` - Voor Python scripts
- `#!/bin/sh` - Voor POSIX shell scripts

Deze lijn vertelt het systeem welke interpreter te gebruiken.

## Waarom is dit belangrijk?

- Scripts kunnen alleen draaien als ze uitvoerbaar zijn
- Beveiliging: Controleer welke scripts uitvoerbaar zijn
- Automatisering: Scripts moeten de juiste rechten hebben
- Deployment: Vaak vergeten stap bij het uitrollen van code

Voer alle chmod commando's uit en test de scripts om door te gaan naar de volgende stap.